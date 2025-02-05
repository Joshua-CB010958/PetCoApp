// lib/models/cart_item.dart
class CartItem {
  final String name; // Name of the product
  final double price; // Price of the product
  final String image; // Image URL of the product
  int quantity; // Quantity of the product in the cart

  CartItem({
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  double get totalPrice => quantity * price;
}
