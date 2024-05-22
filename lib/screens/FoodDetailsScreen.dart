import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/alert_dialog.dart';
import '../helpers/customHeightSizedBox.dart';
import '../helpers/customWidthSizedBox.dart';
import '../modals/random_product_model.dart';
import '../view/addToCart.dart';
import '../view/addToFavorites.dart';
import '../view/addToWish.dart';
import 'HomeScreen.dart';

import 'Screen_Cart.dart';
import 'WhislistScreen.dart';

class FoodDetailsScreen extends StatefulWidget {
  FoodDetailsScreen({
    super.key,
    required this.index,
    required this.databaseRef,
    required this.restaurantItem,
    this.dish,
    this.restaurant,
  });

  Restaurant restaurantItem;
  final int index;
  final DatabaseReference databaseRef;
  final Dish? dish;
  final Restaurant? restaurant;

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  // final _messagingService = MessagingService();
  static final String key = 'whish_items';

  Color buttonColor = Colors.orange;
  String? dishTypeflag;
  static final String keyFavorites = 'favorite_items';
  bool isFavorite = false;






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(

          padding: const EdgeInsets.symmetric(horizontal: 13.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customHeightSizedBox(context,heightFactor: 0.02),
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 38.0),
                    child: CachedNetworkImage(
                      imageUrl: widget.restaurantItem.image ??
                          "https://cdn3.vectorstock.com/i/1000x1000/58/87/loading-icon-load-white-background-vector-27845887.jpg",
                      width: MediaQuery.sizeOf(context).width * 1,
                      fit: BoxFit.fill,
                      height: MediaQuery.sizeOf(context).height * 0.3,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(color: Colors.orange),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        size: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 13,
                    top: 55,
                    child: Container(
                      height: MediaQuery.sizeOf(context).height * 0.07,
                      width: MediaQuery.sizeOf(context).width * 0.09,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.grey.shade300),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()));
                        },
                        child:
                            const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              customHeightSizedBox(context,heightFactor: 0.02),
              Text(
                widget.restaurantItem.name ?? "",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            customHeightSizedBox(context,heightFactor: 0.02),
              Text(
                widget.restaurantItem.descriptionBrief ?? "",
                maxLines: 3,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    fontSize: 17),
              ),
              customHeightSizedBox(context,heightFactor: 0.03),
              Row(
                children: [
                  customWidthSizedBox(context,widthFactor: 0.01),
                  const Icon(
                    Icons.punch_clock,
                    size: 25,
                    color: Colors.orange,
                  ),
                  customWidthSizedBox(context,widthFactor: 0.03),
                  Text(
                    widget.restaurantItem.ratings ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              customHeightSizedBox(context,heightFactor: 0.04),
              Row(
                children: [
                  SizedBox(width: MediaQuery.sizeOf(context).width * 0.01),
                  const Icon(Icons.phone, size: 23, color: Colors.orange),
                  customWidthSizedBox(context,widthFactor: 0.03),
                  Text(
                    widget.restaurantItem.contactNo ?? "",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )
                ],
              ),
              customHeightSizedBox(context,heightFactor: 0.04),
              Row(
                children: [
                  customWidthSizedBox(context,widthFactor: 0.03),
                  const Icon(Icons.restaurant, size: 25, color: Colors.orange),
                  customWidthSizedBox(context,widthFactor: 0.03),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.7,
                    child: Text(
                      widget.restaurantItem.address ?? "",
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  )
                ],
              ),
              customHeightSizedBox(context,heightFactor: 0.05),
              Row(
                children: [
                  TextButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dishTypeflag == "veg"
                            ? Colors.green
                            : const Color(0xFFE5B80B),
                      ),
                      onPressed: () {
                        setState(() {
                          dishTypeflag = dishTypeflag == "veg" ? null : "veg";
                         // widget.restaurantItem.dishes?.clear();

                        });
                      },
                      child: const Text(
                        "Veg",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      )),
                  SizedBox(width: MediaQuery.sizeOf(context).width * 0.1),
                  TextButton(
                      style: ElevatedButton.styleFrom(
                        // primary: Colors.green,
                        backgroundColor: dishTypeflag == "non-veg"
                            ? Colors.red
                            : const Color(0xFFE5B80B),
                      ),
                      onPressed: () {
                        setState(() {
                          dishTypeflag =
                              dishTypeflag == "non-veg" ? null : "non-veg";
                        });
                      },
                      child: const Text(
                        "Non-Veg",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      )),
                ],
              ),
              customHeightSizedBox(context,heightFactor: 0.03),
              const Text(
                "Foods for you",
                style: TextStyle(
                  fontSize: 25,
                  height: 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              customHeightSizedBox(context,heightFactor: 0.01),
              GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 2.0,
                      childAspectRatio: 0.7),
                  padding: const EdgeInsets.all(8.0),
                  itemCount: widget.restaurantItem.dishes?.length ?? 0,
                  itemBuilder: (context, int index) {
                    final dishKey =
                        widget.restaurantItem.dishes?.keys.elementAt(index);
                    final dishValue = widget.restaurantItem.dishes?[dishKey];

                    Map<String, dynamic> dishData =
                        (dishValue as Map<Object?, Object?>?)
                                ?.cast<String, dynamic>() ??
                            {};

                    var dish = Dish.fromJson(dishData);

                    if ((dish.isEnable ?? true) &&
                        ((dishTypeflag == null) || (dish.type == dishTypeflag))) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(alignment: Alignment.topRight, children: [
                                CachedNetworkImage(
                                  imageUrl: dish.image ??
                                      "https://cdn3.vectorstock.com/i/1000x1000/58/87/loading-icon-load-white-background-vector-27845887.jpg",
                                  width: MediaQuery.sizeOf(context).width * 0.4,
                                  //fit: BoxFit.fitWidth,
                                  fit: BoxFit.fill,
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.13,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(
                                          color: Colors.orange),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                    Icons.error,
                                    size: 20,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await addToFavorites(
                                        dish, widget.restaurantItem);
                                    if (mounted) {
                                      setState(() {
                                        isFavorite = !isFavorite;
                                      });

                                      Future.delayed(
                                          const Duration(milliseconds: 500),
                                          () {
                                        if (mounted) {
                                          setState(() {
                                            isFavorite = !isFavorite;
                                          });
                                        }
                                      });

                                      if (mounted && isFavorite) {
                                        showMyDialog(context,"Added to Favorites");
                                      }
                                    }
                                  },
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                )
                              ]),
                              customHeightSizedBox(context,heightFactor: 0.009),
                              Text(
                                dish.name ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "₹  ${dish.price ?? ""}",
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    IconButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                buttonColor),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14.0),
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        await addToCart(
                                            dish, widget.restaurantItem);
                                        if (mounted) {
                                          setState(() {
                                            buttonColor = Colors.orange;
                                          });

                                          Future.delayed(
                                              const Duration(milliseconds: 500),
                                              () {
                                            if (mounted) {
                                              setState(() {
                                                buttonColor =
                                                    Colors.orangeAccent;
                                              });
                                            }
                                          });

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.orange,
                                              content: Center(
                                                child: Column(
                                                  children: [
                                                    const Text(
                                                      'Product added to cart!',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.redAccent,
                                                      ),
                                                      child: const Text(
                                                        'Go To Cart',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  const ScreenCart()),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.shopping_cart,
                                        //size: 20,
                                        color: Colors.black,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              customHeightSizedBox(context,heightFactor: 0.009),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.4,
                                height:
                                    MediaQuery.sizeOf(context).height * 0.05,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.orange),
                                    shape: MaterialStateProperty.all<
                                        OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    print(
                                        "widget.restaurantItem${widget.restaurantItem.name}");
                                    await addToWish(
                                        context, dish, widget.restaurantItem);
                                  },
                                  child: const Text(
                                    "Order Now",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

//
