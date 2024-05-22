import 'dart:convert';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../modals/random_product_model.dart';
import 'FoodDetailsScreen.dart';
import 'HomeScreen.dart';

class ScreenCart extends StatefulWidget {
  const ScreenCart({
    super.key,

  });


  @override
  State<ScreenCart> createState() => _ScreenCartState();
}

class _ScreenCartState extends State<ScreenCart> {
  final String _key = 'cart_items';
  double totalPrice = 0.0;
  double totaldishesGstPrice = 0.0;

  Future<void> removeFromCart(Dish item) async {
    print('Removing from Cart: ${item.name}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList(_key) ?? [];

    // Find the index of the item to be removed
    int indexToRemove = cartItems.indexWhere((jsonString) =>
    Dish
        .fromJson(json.decode(jsonString))
        .name == item.name);

    if (indexToRemove != -1) {
      // If the item is found, remove it
      cartItems.removeAt(indexToRemove);
      await prefs.setStringList(_key, cartItems);

      setState(() {
        print('setState called after removing ${item.name}');
      });

      print('Removed from Cart: ${item.name}');
    } else {
      print('Item not found in cart: ${item.name}');
    }
  }

  Future<List<Dish>> getCartItems({String? restaurantName}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList(_key) ?? [];
    List<Dish> tempList = cartItems.map((jsonString) {
      print("jsonString${jsonString}");
      return Dish.fromJson(json.decode(jsonString));
    }).toList();

    totalPrice = tempList.fold(
      0.0,
          (previousValue, element) =>
      double.parse(element.price ?? '0.0') + previousValue,
    );

    return tempList;
  }

  @override
  void initState() {
    getCartItems().then((value) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.orange,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: InkWell(
          child: const Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(
                builder: (context) => HomeScreen(frommyorders: true,)));
          },
        ),
        backgroundColor: Colors.orange,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.0),
          child: Text(
            'My Cart',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Builder(builder: (context) {
        return FutureBuilder<List<Dish>>(
          future: getCartItems(),
          builder: (BuildContext context, AsyncSnapshot<List<Dish>> snapshot) {
            print('snapshot-----$snapshot');
            if (snapshot.hasData) {
              if (snapshot.data?.isEmpty ?? true) {
                return Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 70),
                      const Icon(
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
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()),
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
                );
              } else {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 8.0),
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: snapshot.data?.length,
                            itemBuilder: (context, index) {
                              //final product = widget.restaurant;
                              return SingleChildScrollView(
                                child: Card(
                                  color: Colors.grey.shade200,
                                  elevation: 4.0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                              width:
                                              MediaQuery
                                                  .sizeOf(context)
                                                  .width *
                                                  0.2,
                                              height: MediaQuery
                                                  .sizeOf(context)
                                                  .height *
                                                  0.12,
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                snapshot.data?[index].image ??
                                                    "",
                                                fit: BoxFit.cover,
                                              )),
                                        ),
                                        SizedBox(
                                          width: MediaQuery
                                              .sizeOf(context)
                                              .width *
                                              0.5,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  // widget.restaurantItem?.name??"",
                                                  snapshot.data?[index].name ??
                                                      "",
                                                  maxLines: 1,
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: MediaQuery
                                                      .sizeOf(context)
                                                      .height *
                                                      0.02,
                                                ),
                                                Text(
                                                  '₹${snapshot.data?[index]
                                                      .price ?? ""}',
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: MediaQuery
                                                      .sizeOf(context)
                                                      .height *
                                                      0.01,
                                                ),
                                                Text(
                                                  snapshot.data?[index]
                                                      .restaurantname ??
                                                      "ABCDEF",
                                                  //widget.restaurant?.name??"",
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(10))),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (
                                                    BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                      "ALLDINE",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.orange,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    content: const Text(
                                                        "Dishes Removed from Cart",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                            fontWeight:
                                                            FontWeight.bold)),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                            backgroundColor:
                                                            Colors.orange,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    7))),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          "OK",
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              color: Colors
                                                                  .black),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                              print(
                                                  'Delete button pressed for item: ${snapshot
                                                      .data![index].name}');
                                              getCartItems().then((cartItems) {
                                                if (index >= 0 &&
                                                    index < cartItems.length) {
                                                  Dish itemToRemove =
                                                  cartItems[index];
                                                  removeFromCart(itemToRemove)
                                                      .then((value) {
                                                    setState(() {

                                                    });
                                                  });
                                                }
                                              });
                                            },
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.black,
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                );
              }
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          },
        );
      }),
    );
  }
}
