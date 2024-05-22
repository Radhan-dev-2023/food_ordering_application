import 'dart:convert';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../Screens/HomeScreen.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;

import '../modals/random_product_model.dart';
import 'NotificationWidget.dart';

DateTime scheduleTime = DateTime.now();

class WhislistScreen extends StatefulWidget {
  WhislistScreen({super.key, this.product, this.restaurant});

  final Dish? product;
  final Restaurant? restaurant;
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController cookinginstructionscontroller =
      TextEditingController();
  final TextEditingController mobilecontroller = TextEditingController();
  final TextEditingController timecontroller = TextEditingController();

  @override
  State<WhislistScreen> createState() => _WhislistScreenState();
}

class _WhislistScreenState extends State<WhislistScreen> {
  static final String key = 'whish_items';
  List<Dish> orderItems = [];
  bool isTextFieldVisible = false;

  double totalPrice = 0.0;
  double totalminutes = 0.0;

  String userName = '';
  String cookingInstructions = '';
  String mobilenumber = '';
  String preperationTime = '';
  String immediateorders = '';
  int quantity = 1;

  bool isFieldsVisible = false;

//  int _counter = 0;

  Future<void> removeFromWhislist(Dish item) async {
    print('Removing from Whislist: ${item.name}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList('whish_items') ?? [];

    // Find the index of the item to be removed
    int indexToRemove = cartItems.indexWhere((jsonString) =>
        Dish.fromJson(json.decode(jsonString)).name == item.name);

    if (indexToRemove != -1) {
      // If the item is found, remove it from both the list and shared preferences
      cartItems.removeAt(indexToRemove);
      await prefs.setStringList('whish_items', cartItems);

      print('Removed from Cart: ${item.name}');
    } else {
      print('Item not found in cart: ${item.name}');
    }
  }

  Future<List<Dish>> getWhislistItems(
      {String? restaurantName, String? preprationTime}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList('whish_items') ?? [];
    List<Dish> templList = cartItems.map((jsonString) {
      print("jsonString${jsonString}");
      return Dish.fromJson(json.decode(jsonString));
    }).toList();

    totalPrice = templList.fold(
      0.0,
      (previousValue, element) =>
          double.parse(element.price ?? '0.0') + previousValue,
    );

    totalminutes = await getTotalPreparationTime(templList);
    print("totalminutes======${totalminutes}");


    return templList;
  }



  Future<double> getTotalPreparationTime(List<Dish> items) async {
    // Find the highest preparation time among all items
    int maxPreparationTime = items
        .map((item) => int.tryParse(item.preparationTime ?? "0") ?? 0)
        .reduce((max, time) => max > time ? max : time);

    // Calculate total preparation time considering only the highest preparation time
    double totalMinutes = items
        .map((item) => int.tryParse(item.preparationTime ?? "0") ?? 0)
        .fold(0, (previousValues, time) => time == maxPreparationTime ? time + previousValues : previousValues);

    return totalMinutes;
  }

  // Future<void> saveOrderToDatabase(
  //   List<Dish> orderItems,
  //   String userName,
  //   String cookingInstructions,
  //   String mobilenumber,
  //   String preparationTime,
  //   String immediateorders,
  //   int quantity,
  // ) async {
  //   final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  //
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   // String? storedUserId = prefs.getString('userId');
  //
  //   // DatabaseReference userOrdersRef =
  //   //   databaseReference.child("users").child(storedUserId!).child("orders");
  //   DatabaseReference receivedOrdersRef = databaseReference.child("orders");
  //   DatabaseReference TotalOrderref = databaseReference.child("totalorders");
  //
  //   DateTime currentDateTime = DateTime.now();
  //   // orderItems = await getWhislistItems(restaurantName: '');
  //   List<Map<String, dynamic>> orderDetails = [];
  //   for (Dish dish in orderItems) {
  //     //  String orderKey = userOrdersRef.push().key ?? '';
  //
  //     orderDetails.add({
  //       'dishName': dish.name ?? "",
  //       'dishPrice': dish.price ?? "",
  //       'orderDateTime': currentDateTime.toIso8601String(),
  //       'userName': userName,
  //       'cookingInstructions': cookingInstructions,
  //       'mobilenumber': mobilenumber,
  //       'dishImage': dish.image ?? "",
  //       'restaurantName': dish.restaurantname ?? "",
  //       'preperationTime': dish.preparationTime ?? "",
  //       'immeditateorders': immediateorders,
  //       'quantity': dish.quantity ?? 1,
  //     });
  //   }
  //   print("$orderDetails{orderDetails}");
  //   // await userOrdersRef.child(orderKey).set(orderDetails).onError((error, stackTrace) {
  //   //   print('@@@@@@@@@@@@@@@@@${error}');
  //   // });
  //
  //   // Save the order in the second path
  //   await receivedOrdersRef
  //       .child(orderDetails[0]["restaurantName"])
  //       .push()
  //       .set(orderDetails)
  //       .then((value) {
  //     print('################################}');
  //   }).onError((error, stackTrace) {
  //     //  print('@@@@@@@@@@@@@@@@@${error}');
  //   });
  //   await TotalOrderref.child(orderDetails[0]["restaurantName"])
  //       .push()
  //       .set(orderDetails)
  //       .then((value) {
  //     print('################################}');
  //   }).onError((error, stackTrace) {
  //     print('@@@@@@@@@@@@@@@@@${error}');
  //   });
  // }

  Future<void> saveOrderToDatabase(
      List<Dish> orderItems,
      String userName,
      String cookingInstructions,
      String mobilenumber,
      String preparationTime,
      String immediateorders,
      int quantity,
      ) async {
    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    DatabaseReference receivedOrdersRef = databaseReference.child("orders");
    DatabaseReference TotalOrderref = databaseReference.child("totalorders");

    DateTime currentDateTime = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30)); // Adjusting to IST

    List<Map<String, dynamic>> orderDetails = [];
    for (Dish dish in orderItems) {
      orderDetails.add({
        'dishName': dish.name ?? "",
        'dishPrice': dish.price ?? "",
        'orderDateTime': DateFormat('dd/MM/yy HH:mm').format(currentDateTime),
        'userName': userName,
        'cookingInstructions': cookingInstructions,
        'mobilenumber': mobilenumber,
        'dishImage': dish.image ?? "",
        'restaurantName': dish.restaurantname ?? "",
        'preperationTime': dish.preparationTime ?? "",
        'immeditateorders': immediateorders,
        'quantity': dish.quantity ?? 1,
      });
    }

    await receivedOrdersRef
        .child(orderDetails[0]["restaurantName"])
        .push()
        .set(orderDetails)
        .then((value) {
      print('Order saved successfully');
    }).onError((error, stackTrace) {
      print('Error saving order: $error');
    });

    await TotalOrderref.child(orderDetails[0]["restaurantName"])
        .push()
        .set(orderDetails)
        .then((value) {
      print('Total order saved successfully');
    }).onError((error, stackTrace) {
      print('Error saving total order: $error');
    });
  }

  Future<void> sendPushNotifications() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('admin/fcmToken').get();
    if (snapshot.exists) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.subscribeToTopic('all');

      List<Map<String, dynamic>> messages = [
        {
          'notification': {
            'body': 'Order has been received',
            'title': 'AllDine',
            'subtitle': 'Food Name Restaurant Name',
          },
          'data': {},
          'to': '${snapshot.value}',
        },
      ];

      for (int i = 0; i < messages.length; i++) {
        await Future.delayed(Duration(minutes: i * 1), () async {
          var response = await http.post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization':
                  'key=${'AAAA0KkgjcA:APA91bEBKRcraT3vHA6kvi18NfoMcz72JzRGyM3-LSbuksxSpNFVuC_sJDY9hi0DoTFr1SlKOmUZTU1hlXvJPB7hrLlwQsnoKF2UV8qbqa_XFtFjb1JKxpSEPUbt7QIa3ILFbX8dlTbQ'}',
            },
            body: jsonEncode(messages[i]),
          );

          print(
              'Sent notification ${i + 1} with status code: ${response.statusCode}');
          print('Response content: ${response.body}');
        });
      }
    } else {
      print('No data available.');
    }
  }

  @override
  void initState() {
    super.initState();
    getWhislistItems().then((value) {
      orderItems = value;
      setState(() {});
    });
    NotificationWidget.init();
    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: InkWell(
            child: Icon(Icons.arrow_back),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomeScreen(
                            frommyorders: true,
                          )));
            },
          ),
          backgroundColor: Colors.orange,
          title: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0),
            child: Text(
              'My Whishlist',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        body:
            Column(
          children: [
            if (orderItems.isNotEmpty) ...[
              Expanded(
                child: SingleChildScrollView(
                  child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 8.0),
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: orderItems.length,
                      itemBuilder: (context, index) {
                        var c = 0;
                        final item = orderItems[index];
                        double price = double.tryParse(item?.price ?? '') ?? 0;
                        return Card(
                          //color: Colors.grey.shade100,
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.2,
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.12,
                                      child: CachedNetworkImage(
                                        imageUrl: orderItems[index].image ?? "",
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 0.4,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          orderItems[index].name ?? "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.02,
                                        ),
                                        Text(
                                          // '₹ ${((double.tryParse(snapshot.data?[index].price ?? "0") ?? 1) * (_counter ?? 1).toDouble()).toString()}',
                                          '₹ ${((double.tryParse(orderItems[index].price ?? "0") ?? 1) * (orderItems[index].quantity ?? 1)).toString()}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.01,
                                        ),
                                        Text(
                                          orderItems[index].restaurantname ??
                                              "ABCDEF",
                                          // "ASDFFJKSLLALKDFasdfgkhlhlhlhlh;g;g;g;",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.01,
                                        ),
                                        Text(
                                          '⏱ ${orderItems[index].preparationTime ?? "ABCDEF"} mins',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.orange),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              orderItems[index].quantity =
                                                  orderItems[index].quantity! +
                                                      1;
                                              totalPrice = totalPrice +
                                                  int.parse(orderItems[index]
                                                      .price
                                                      .toString());
                                              // c = orderItems[index].quantity!;
                                              // quantity=c;
                                              // orderItems[index].quantity++;
                                              print(
                                                  "!!!!!!!!!!!!!!${orderItems[index].quantity}");
                                              // int currentQuantity = orderItems[index].quantity ?? 0;
                                              // orderItems[index].quantity = currentQuantity + 1;
                                            });
                                          },
                                          icon: Icon(Icons.add),
                                        ),
                                        Text(
                                          '${orderItems[index].quantity}',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.orange),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              int currentQuantity =
                                                  orderItems[index].quantity ??
                                                      0;
                                              if (currentQuantity > 0) {
                                                orderItems[index].quantity =
                                                    currentQuantity - 1;
                                                totalPrice = totalPrice -
                                                    int.parse(orderItems[index]
                                                        .price
                                                        .toString());
                                                // quantity =
                                                //     orderItems[index].quantity;
                                                removeFromWhislist(item);
                                                if (currentQuantity == 1) {
                                                  orderItems.removeAt(index);
                                                }
                                              }

                                              //quantity=c;
                                            });
                                          },
                                          icon: Icon(Icons.remove),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(48.0),
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.sizeOf(context).height * 0.060,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext) {
                          return StatefulBuilder(builder: (context, setter) {
                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.01,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(9.0),
                                        child: TextField(
                                          keyboardType: TextInputType.name,
                                          controller: widget.namecontroller,
                                          onChanged: (value) {
                                            widget.namecontroller.text = value;
                                          },
                                          decoration: InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.grey,
                                                  width: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.grey,
                                                  width: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            hintText: '  Enter Your Name',
                                            filled: true,
                                            fillColor: Colors.blueGrey
                                                .withOpacity(0.1),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(9.0),
                                        child: TextField(
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9]')),
                                            LengthLimitingTextInputFormatter(
                                                10),
                                          ],
                                          keyboardType: TextInputType.phone,
                                          controller: widget.mobilecontroller,
                                          onChanged: (value) {
                                            widget.mobilecontroller.text =
                                                value;
                                          },
                                          decoration: InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.grey,
                                                  width: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.grey,
                                                  width: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            hintText:
                                                '  Enter Your Contact Number',
                                            filled: true,
                                            fillColor: Colors.blueGrey
                                                .withOpacity(0.1),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(9.0),
                                        child: TextField(
                                          keyboardType: TextInputType.multiline,
                                          controller: widget
                                              .cookinginstructionscontroller,
                                          onChanged: (value) {
                                            widget.cookinginstructionscontroller
                                                .text = value;
                                          },
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.grey,
                                                  width: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.grey,
                                                  width: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            hintText:
                                                '  Enter Your Cooking Instructions (If needed)',
                                            filled: true,
                                            fillColor: Colors.blueGrey
                                                .withOpacity(0.1),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.006),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: isTextFieldVisible
                                                ? Icon(Icons.close)
                                                : Icon(Icons.add),
                                            onPressed: () {
                                              setter(() {
                                                isTextFieldVisible =
                                                    !isTextFieldVisible;
                                                if (!isTextFieldVisible) {
                                                  widget.timecontroller.clear();
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),

                                      Visibility(
                                        visible: isTextFieldVisible,
                                        child: Padding(
                                          padding: EdgeInsets.all(9.0),
                                          child: TextField(
                                            keyboardType:
                                                TextInputType.number,
                                            controller: widget.timecontroller,
                                            onChanged: (value) {
                                              widget.timecontroller.text =
                                                  value;
                                            },
                                            maxLines: 1,
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                    width: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                    width: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              hintText:
                                                  '  Enter the Timing of ready order in (minutes)',
                                              filled: true,
                                              fillColor: Colors.blueGrey
                                                  .withOpacity(0.1),
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.009),
                                      Divider(
                                        height: 5,
                                        color: Colors.grey.shade500,
                                        thickness: 1,
                                      ),
                                      SizedBox(
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.02),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.07),
                                          const Text(
                                            "Total:",
                                            style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 20),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.1),
                                          Text(
                                            "₹ ${totalPrice
                                            //+ totalGstPrice
                                            }",
                                            style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.02),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.07),
                                          const Text(
                                            "Timing:",
                                            style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 20),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.06),
                                          Text(
                                            "⏱ ${totalminutes
                                            //+ totalGstPrice
                                            } minutes",
                                            style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.07),
                                      SizedBox(
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.05,
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                0.9,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                          onPressed: () async {
                                            userName =
                                                widget.namecontroller.text;
                                            cookingInstructions = widget
                                                .cookinginstructionscontroller
                                                .text;
                                            mobilenumber =
                                                widget.mobilecontroller.text;
                                            print('userName: $userName');
                                            print(
                                                'cookingInstructions: $cookingInstructions');
                                            print(
                                                'mobilenumber: $mobilenumber');

                                            if (userName.isEmpty) {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text('ALLDINE',
                                                      style: TextStyle(
                                                          fontSize: 22,
                                                          color: Colors.orange,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  content: const Text(
                                                      'Please enter your name.',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('OK',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              return;
                                            }

                                            if (mobilenumber.isEmpty ||
                                                mobilenumber.length > 10 ||
                                                mobilenumber.length < 10) {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text('ALLDINE',
                                                      style: TextStyle(
                                                          fontSize: 22,
                                                          color: Colors.orange,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  content: const Text(
                                                      'Please Enter your Mobile Number.',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  actions: [
                                                    TextButton(
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.orange,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7))),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('OK',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              return;
                                            }
                                            print(
                                                "orderitems3333333333${orderItems.length}");
                                            try {
                                              print('@@@@@@@@${quantity}');
                                              // Call the saveOrderToDatabase function
                                              await saveOrderToDatabase(
                                                orderItems,
                                                userName,
                                                cookingInstructions,
                                                mobilenumber,
                                                preperationTime,
                                                immediateorders,
                                                quantity,
                                              );

                                              print('Order saved successfully');
                                            } catch (error) {
                                              print(
                                                  'Failed to save order: $error');
                                            }

                                            // Clear text fields

                                            widget.namecontroller.clear();
                                            widget.cookinginstructionscontroller
                                                .clear();

                                            // Reset total price

                                            totalPrice = 0;
                                            // totalGstPrice = 0;

                                            // Close the bottom sheet
                                            Navigator.pop(context);

                                            showSuccessDialog(context);

                                            await sendPushNotifications();

                                            await NotificationWidget
                                                .showScheduleNotification(
                                                    title: 'ALLDINE',
                                                    body:
                                                        'Your Food order is ready in 15 minutes',
                                                    scheduleTime: DateTime.now()
                                                        .add(Duration(
                                                            minutes:
                                                                totalminutes
                                                                    .toInt())));
                                          },
                                          child: const Text(
                                            "ORDER NOW",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.06,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          });
                        },
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'PLACE ORDER',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 70),
                    Icon(
                      Icons.remove_shopping_cart,
                      size: 350,
                      color: Colors.orange,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Cart is Empty !',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      },
                      child: const Text(
                        'Continue Ordering',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ],
        ));
  }



  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "ALLDINE",
          style: TextStyle(
            fontSize: 18,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Your order has been placed successfully",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            onPressed: () async {
              // Clear data from shared preferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // Close the dialog
              Navigator.of(ctx).pop();

              // Update the state to clear order items
              setState(() {
                orderItems.clear();
              });
            },
            child: const Text(
              "CLOSE",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }


}
