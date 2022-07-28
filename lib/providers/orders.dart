import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;

  Orders(this.authToken, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.https('first-app-61a2a-default-rtdb.firebaseio.com',
        '/orders.json', {"auth": authToken});
    // final response = await http.get(url);
    // print(json.decode(response.body));
    // final List<OrderItem> loadedOrders = [];
    // final extractedData = json.decode(response.body) as Map<String, dynamic>;
    // extractedData.forEach((orderId, orderData) {
    //   loadedOrders.add(OrderItem(
    //     id: orderId,
    //     amount: orderData['amount'],
    //     dateTime: DateTime.parse(orderData['dateTime']),
    //     products:
    //         (orderData['products'] as List<dynamic>).map((item) => CartItem(
    //               id: item['id'],
    //               price: item['price'],
    //               quantity: item['quantity'],
    //               title: item['title'],
    //             )),
    //   ));
    // });
    // _orders = loadedOrders;
    // notifyListeners();

    try {
      final response = await http.get(url);
      final List<OrderItem> loadedOrders = [];
      final extractedData = json.decode(response.body) ??
          // ignore: unnecessary_cast
          <String, dynamic>{} as Map<String, dynamic>;

      if (extractedData == <String, dynamic>{}) {
        return;
      }

      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
            id: orderId,
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>)
                .map((item) => CartItem(
                      id: item['id'],
                      price: item['price'],
                      quantity: item['quantity'],
                      title: item['title'],
                    ))
                .toList()));
      });

      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https('first-app-61a2a-default-rtdb.firebaseio.com',
        '/orders.json', {"auth": authToken});
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((cartProd) => {
                    'id': cartProd.id,
                    'title': cartProd.title,
                    'quantity': cartProd.quantity,
                    'price': cartProd.price,
                  })
              .toList(),
        }));
    _orders.insert(
      0,
      OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          dateTime: timestamp,
          products: cartProducts),
    );
    notifyListeners();
  }
}
