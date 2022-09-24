import 'dart:convert';
import 'package:flutter/material.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import '../models/http_exceptions.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  final String? authToken;
  final String? userId;

  Products(this.authToken, this.userId, this._items);

  var _showFavorites = false;

  List<Product> get items {
    if (_showFavorites) {
      return _items.where((prodItem) => prodItem.isFav).toList();
    }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFav).toList();
  }

  // void showFavorites() {
  //   _showFavorites = true;
  // }

  // void showAll() {
  //   _showFavorites = false;
  // }

  Product findById(String id) {
    return items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId' : '';
    var url = Uri.parse(
        'https://myproj123-66ad1-default-rtdb.firebaseio.com/prod.json?auth=$authToken&$filterString"');

    try {
      final response = await http.get(url);
      // print(json.decode(response.body) );
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return;
      }
      url = Uri.parse(
          'https://myproj123-66ad1-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            title: prodData['title'],
            price: prodData['price'],
            isFav:
                favoriteData == null ? false : favoriteData[prodId] ?? false));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void>? addProduct(Product product) async {
    final url = Uri.parse(
        'https://myproj123-66ad1-default-rtdb.firebaseio.com/prod.json?auth=$authToken');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId
          }));

      final newProduct = Product(
          description: product.description,
          id: json.decode(response.body)['name'],
          imageUrl: product.imageUrl,
          price: product.price,
          title: product.title);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
    // print(json.decode(response.body));
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final pindex = _items.indexWhere((element) => element.id == id);
    if (pindex >= 0) {
      final url = Uri.parse(
          'https://myproj123-66ad1-default-rtdb.firebaseio.com/prod/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[pindex] = newProduct;
      notifyListeners();
    } else {
      print('..');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://myproj123-66ad1-default-rtdb.firebaseio.com/prod/$id.json?auth=$authToken');
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    Product? existingPriduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingPriduct);
      notifyListeners();
      throw HttpException('Could Not delete Product');
    }
    existingPriduct = null;
  }
}
