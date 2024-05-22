import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modals/random_product_model.dart';

const String key_ = 'favorite_items';

Future<void> addToFavorites(Dish item, Restaurant restaurant) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Set<String> cartItems = prefs.getStringList(key_)?.toSet() ?? {};


  Map<String, dynamic> itemData = item.toJson();
  itemData['restaurantName'] = restaurant.name;
  print('#############################${restaurant.name}');

  cartItems.add(jsonEncode(itemData));
  await prefs.setStringList(key_, cartItems.toList());
}