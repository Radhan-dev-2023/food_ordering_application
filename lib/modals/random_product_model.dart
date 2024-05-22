import 'dart:convert';

class Restaurant {
  String? address;
  String? contactNo;
  String? description;
  String? descriptionBrief;
  String? image;
  String? ratings;
  String? name;
  Map<Object?, Object?>? dishes;

  Restaurant({
    this.address,
    this.contactNo,
    this.description,
    this.descriptionBrief,
    this.image,
    this.ratings,
    this.name,
    this.dishes,
  });

  factory Restaurant.fromJson(String key, Map<String, dynamic> json) {
    return Restaurant(
      address: json['Restaurants Address'],
      contactNo: json['Restaurants Contactno'],
      description: json['Restaurants Description'],
      descriptionBrief: json['Restaurants Descriptionbrief'],
      image: json['Restaurants Image'],
      ratings: json['Restaurants Ratings'],
      name: json['Restaurants name'],
      dishes:
          (json['dishes'] as Map<Object?, Object?>?)?.cast<String, dynamic>(),
    );
  }


}

class Dish {
  String? bufferTime;
  String? dishesGst;
  String? image;
  String? name;
  String? price;
  String? type;
  String? preparationTime;
  bool? isEnable;
  bool isAddedToCart;
  String? restaurantname;
  String? rrestaurantname;
  int? quantity;





  Dish(
    {

    this.bufferTime,
    this.dishesGst,
    this.image,
    this.name,
    this.price,
    this.type,
    this.preparationTime,
    this.isEnable,
    this.isAddedToCart =false,
      this.restaurantname,
      this.rrestaurantname,
      //required this.quantity,
      this.quantity,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(

      bufferTime: json['Buffer Time'],
      dishesGst: json['Dishes Gst'],
      image: json['Dishes Image'],
      name: json['Dishes name'],
      price: json['Dishes price'],
      type: json['Dishes type'],
      preparationTime: json['Preperation Time'],
      isEnable: json['isEnable'],
      restaurantname: json['restaurantName'],
        rrestaurantname: json['rrestaurantName'],
      quantity: json['quantity']??0,

    );
  }

  // Convert cart item to JSON for storage

  Map<String, dynamic> toJson() => {
        'Dishes name': name,
        'isEnable': isEnable,
        'Dishes price': price,
        'dishesGst': dishesGst,
        'Dishes type': type,
        'Dishes Image': image,
        'Buffer Time': bufferTime,
        'Preperation Time': preparationTime,
    'restaurantName':restaurantname,
    'rrestaurantName':rrestaurantname,
    'quantity' :quantity

      };
}

class DishList {
  final List<Dish> dish;

  DishList({required this.dish});

  factory DishList.fromJson(List<dynamic> json) {
    List<Dish> dishList =
        json.map((restaurantsJson) => Dish.fromJson(restaurantsJson)).toList();

    return DishList(dish: dishList);
  }
}


