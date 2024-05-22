import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/WhislistScreen.dart';
import '../modals/random_product_model.dart';

Future<void> addToWish(
    BuildContext context, Dish item, Restaurant? restaurant) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Set<String> wishlistItems =
      prefs.getStringList('whish_items')?.toSet() ?? {};

  // Include restaurant name in the item data
  Map<String, dynamic> itemData = item.toJson();
  itemData['restaurantName'] = restaurant?.name ?? "Unknown Restaurant";

  // Set initial quantity to 1
  itemData['quantity'] = 1;

  if (wishlistItems.isNotEmpty) {
    if (restaurant != null &&
        wishlistItems.any((existingItem) {
          Map<String, dynamic> decodedItem = jsonDecode(existingItem);
          return decodedItem['restaurantName'] == restaurant.name;
        })) {
      // The selected restaurant name matches the restaurant name of existing items
      wishlistItems.add(jsonEncode(itemData));
      await prefs.setStringList('whish_items', wishlistItems.toList());
      if (wishlistItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wishlist is empty'),
          ),
        );
      }
    } else {
      // The selected restaurant name doesn't match existing items
      bool replaceAll = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('ALLDINE',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.orange)),
            content: const Text('Choosing the foods in different restaurants',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            actions: [
              TextButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text('Replace All',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ),
              TextButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('Cancel',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ),
            ],
          );
        },
      );

      if (replaceAll == true) {
        wishlistItems.clear();
        wishlistItems.add(jsonEncode(itemData));
        await prefs.setStringList('whish_items', wishlistItems.toList());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => WhislistScreen(),
          ),
        );
      }
    }
  } else {
    wishlistItems.add(jsonEncode(itemData));
    await prefs.setStringList('whish_items', wishlistItems.toList());
  }
}