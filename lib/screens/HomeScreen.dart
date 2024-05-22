
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/LoginScreen.dart';
import '../Screens/edit_profile_screen.dart';
import '../modals/random_product_model.dart';
import 'AboutScreen.dart';
import 'FavoritesScreen.dart';
import 'FoodDetailsScreen.dart';
import 'Help Screen.dart';
import 'MessagingService.dart';
import 'ReportScreen.dart';
import 'Screen_Cart.dart';
import 'WhislistScreen.dart';

class HomeScreen extends StatefulWidget {
  final Dish? dish;
  final Restaurant? restaurant;
  final bool? frommyorders;

  const HomeScreen({super.key, this.dish, this.restaurant, this.frommyorders});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _messagingService = MessagingService();
  late bool isFavorite;
  final firebaseauth = FirebaseAuth.instance;

  final auth = FirebaseDatabase.instance;
  late Restaurant restaurantItem;
  final ref = FirebaseDatabase.instance.ref('restaurants');
  final GlobalKey<ScaffoldState> _keys = GlobalKey();

  @override
  void initState() {
    super.initState();
    MessagingService().init(context);
    isopeneddrawers();
  }

  void isopeneddrawers() async {
    if (widget.frommyorders == true) {
      await Future.delayed(Duration.zero);
      _keys.currentState!.openDrawer();
    }
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'ALLDINE',
          style: TextStyle(
              fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to exit the app',
          style: TextStyle(
              fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7))),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'No',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7))),
            onPressed: () {
              SystemNavigator.pop();
            },
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    ).then((value) {
      if (value == true) {
        return true;
      } else {
        return false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    print('ref-----------${ref}');
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          key: _keys,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: FutureBuilder<String>(
              future: getGreetingWithName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  String greetingWithName = snapshot.data!;
                  return Text(
                    greetingWithName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  );
                }
              },
            ),
            centerTitle: false,
            automaticallyImplyLeading: true,
            backgroundColor: Colors.orange,
            shadowColor: Colors.white70,
            actions: [

              const Icon(
                Icons.currency_exchange_rounded,
                size: 25,
                color: Colors.black,
              ), SizedBox(width: MediaQuery.sizeOf(context).width*0.03,),
            ],
          ),
          drawer: Drawer(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8, bottom: 8, top: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ListTile(
                    title: const Text(
                      "ALLDINE \n\nWELCOME'S YOU",
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {},
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 2.0,
                    height: 1.0,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.account_circle_rounded,
                      color: Colors.orange,
                    ),
                    title: const Text(
                      "Profile",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.brown,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Edit_ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.shopping_cart,
                      color: Colors.orange,
                    ),
                    title: const Text(
                      "My Cart",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.brown,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ScreenCart()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.favorite,
                      color: Colors.orange,
                    ),
                    title: const Text(
                      "Favorites",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.brown,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FavoriteScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.history_edu_outlined,
                      color: Colors.orange,
                    ),
                    title: const Text(
                      "My Whishlist",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.brown,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WhislistScreen()));
                    },
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 2.0,
                    height: 2.0,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.info,
                      color: Colors.orange,
                    ),
                    title: const Text(
                      "About",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.brown,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.report_gmailerrorred,
                      color: Colors.orange,
                    ),
                    title: const Text(
                      "Report",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.brown,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ReportScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.help,
                      color: Colors.orange,
                    ),
                    title: const Text(
                      "Help",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.brown,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HelpScreen()));
                    },
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 2.0,
                    height: 2.0,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.orange,
                    ),
                    title: const Text(
                      "Logout",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.brown,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      firebaseauth.signOut().whenComplete(() =>
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MobileLogin())));
                    },
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              const OfferSlider(),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.009),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 178),
                child: Text(
                  "Explore Restaurants",
                  style: TextStyle(
                    fontSize: 20 * textScaleFactor,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.02,
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseDatabase.instance.ref('restaurants').onValue,
                  builder: (context, snapshot) {
                    List<Restaurant> restaurant = [];
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        (snapshot.data!).snapshot.value != null) {
                      final myMessages = Map<dynamic, dynamic>.from(
                          (snapshot.data!).snapshot.value
                              as Map<dynamic, dynamic>);
                      myMessages.forEach((key, value) {
                        final currentMessage = Map<String, dynamic>.from(value);
                        restaurant.add(Restaurant(
                          address: currentMessage['Restaurants Address'],
                          contactNo: currentMessage['Restaurants Contactno'],
                          description:
                              currentMessage['Restaurants Description'],
                          descriptionBrief:
                              currentMessage['Restaurants Descriptionbrief'],
                          image: currentMessage['Restaurants Image'],
                          ratings: currentMessage['Restaurants Ratings'],
                          name: currentMessage['Restaurants name'],
                          dishes: currentMessage['dishes'],
                        ));
                      });
                      return ListView.builder(
                        // physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: restaurant.length,
                        itemBuilder: (context, index) {
                          return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Column(children: [
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.03,
                                ),
                                InkWell(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  FoodDetailsScreen(
                                                    index: index,
                                                    databaseRef: ref,
                                                    restaurantItem:
                                                        restaurant[index],
                                                  )));
                                    },
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        child: Container(
                                          color: Colors.white,
                                          padding: const EdgeInsets.all(8),
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Stack(
                                                  children: [
                                                    CachedNetworkImage(
                                                      imageUrl: restaurant[
                                                                  index]
                                                              .image ??
                                                          "https://cdn3.vectorstock.com/i/1000x1000/58/87/loading-icon-load-white-background-vector-27845887.jpg",
                                                      width: MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
                                                          0.45,
                                                      height: MediaQuery.sizeOf(
                                                                  context)
                                                              .height *
                                                          0.20,
                                                      fit: BoxFit.fill,
                                                      placeholder: (context,
                                                              url) =>
                                                          const CircularProgressIndicator(
                                                              color: Colors
                                                                  .orange),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                        Icons.error,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                    width: MediaQuery.sizeOf(
                                                                context)
                                                            .width *
                                                        0.02),
                                                Expanded(
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                      // const SizedBox(height: 3),
                                                      Text(
                                                        restaurant[index]
                                                                .name ??
                                                            "Loading",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          color: Colors.orange,
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height:
                                                              MediaQuery.sizeOf(
                                                                          context)
                                                                      .height *
                                                                  0.01),
                                                      Text(
                                                        restaurant[index]
                                                                .description ??
                                                            "Loading",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 17,
                                                        ),
                                                      ),

                                                      SizedBox(
                                                          height:
                                                              MediaQuery.sizeOf(
                                                                          context)
                                                                      .height *
                                                                  0.01),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                              Icons.phone,
                                                              size: 20,
                                                              color: Colors
                                                                  .orangeAccent),
                                                          SizedBox(
                                                            width: MediaQuery
                                                                        .sizeOf(
                                                                            context)
                                                                    .width *
                                                                0.02,
                                                          ),
                                                          Text(
                                                              restaurant[index]
                                                                      .contactNo ??
                                                                  "",
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                      .black))
                                                        ],
                                                      ),
                                                      SizedBox(
                                                          height:
                                                              MediaQuery.sizeOf(
                                                                          context)
                                                                      .height *
                                                                  0.01),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons.location_on,
                                                            color:
                                                                Colors.orange,
                                                            size: 24,
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery
                                                                        .sizeOf(
                                                                            context)
                                                                    .width *
                                                                0.02,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              restaurant[index]
                                                                      .address ??
                                                                  "Loading",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                          height:
                                                              MediaQuery.sizeOf(
                                                                          context)
                                                                      .height *
                                                                  0.01),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .access_time_rounded,
                                                            color:
                                                                Colors.orange,
                                                            size: 24,
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery
                                                                        .sizeOf(
                                                                            context)
                                                                    .width *
                                                                0.02,
                                                          ),
                                                          Text(
                                                            restaurant[index]
                                                                    .ratings ??
                                                                "Loading",
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery
                                                                        .sizeOf(
                                                                            context)
                                                                    .width *
                                                                0.05,
                                                          ),
                                                        ],
                                                      ),
                                                    ]))
                                              ]),
                                        )))
                              ]));
                        },
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          )),
    );
  }

  Future<String> getGreetingWithName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedName = prefs.getString('fullName');
    final now = DateTime.now();
    String timeGreeting = "Good Morning";
    if (now.hour >= 12 && now.hour < 17) {
      timeGreeting = "Good Afternoon";
    } else if (now.hour >= 17) {
      timeGreeting = "Good Evening";
    }

    String truncatedName = savedName != null
        ? savedName.substring(0, savedName.length > 8 ? 8 : savedName.length)
        : '';
    return savedName != null ? "$timeGreeting $truncatedName!" : timeGreeting;
  }
}

class OfferSlider extends StatelessWidget {
  const OfferSlider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260.0,
      child: ImageSlideshow(
        indicatorBackgroundColor: Colors.white,
        indicatorColor: Colors.orange,
        height: 300,
        autoPlayInterval: 3000,
        indicatorRadius: 5,
        isLoop: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(1),
            child: Image.network(
              "https://media.istockphoto.com/id/1498243668/photo/tasty-cheeseburger-with-lettuce-cheddar-cheese-tomato-and-pickles-burger-bun-with-sesame.webp?b=1&s=170667a&w=0&k=20&c=hn0NNDGgZAQZ6qEBwO5mhku7OAIy0TKEg6Zgg8n4LTI=",
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(1),
            child: Image.network(
                "https://www.seema.com/wp-content/uploads/2023/03/Best-Indian-Restaurants-in-the-USA.jpg"),
          ),
          Padding(
            padding: const EdgeInsets.all(1),
            child: Image.network(
                "https://st4.depositphotos.com/1000589/30118/i/450/depositphotos_301181378-stock-photo-assorted-indian-food-on-black.jpg"),
          ),
          Padding(
            padding: const EdgeInsets.all(1),
            child: Image.network(
                "https://hindustanlive.net/wp-content/uploads/2021/07/84-1-2.jpg"),
          ),
          Padding(
            padding: const EdgeInsets.all(1),
            child: Image.network(
                "https://www.eligasht.co.uk/Blog/wp-content/uploads/2019/09/INDIAN-FOOD.jpg"),
          ),
        ],
      ),
    );
  }
}
