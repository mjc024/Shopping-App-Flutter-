import 'package:flutter/foundation.dart';
// import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFav;
  void _setStatus(bool newVal) {
    isFav = newVal;
    notifyListeners();
  }

  Product(
      {required this.description,
      required this.id,
      required this.imageUrl,
      this.isFav = false,
      required this.price,
      required this.title});

  Future<void> toggleFav(String token, String userId) async {
    final oldStatus = isFav;
    isFav = !isFav;
    notifyListeners();
    final url = Uri.parse(
        'https://myproj123-66ad1-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token');
    try {
      final response = await http.put(url,
          body: json.encode(
            isFav,
          ));
      if (response.statusCode >= 400) {
        _setStatus(oldStatus);
      }
    } catch (error) {
      _setStatus(oldStatus);
    }
  }
}
