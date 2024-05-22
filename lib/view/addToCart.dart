import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modals/random_product_model.dart';

const String _key = 'cart_items';

Future<void> addToCart(Dish item, Restaurant restaurant) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Set<String> cartItems = prefs.getStringList(_key)?.toSet() ?? {};

  Map<String, dynamic> itemData = item.toJson();
  itemData['restaurantName'] = restaurant.name;
  if (kDebugMode) {
    print('#############################${restaurant.name}');
  }

  cartItems.add(jsonEncode(itemData));
  await prefs.setStringList(_key, cartItems.toList());
}