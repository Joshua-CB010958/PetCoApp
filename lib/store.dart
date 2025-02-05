import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'offline.dart'; // Import the offline page
import 'service.dart';
import 'user.dart';
import 'order.dart';
import 'ProductService.dart';
import 'package:petco/models/product.dart';
import 'package:petco/models/cart_item.dart'; // Import CartItem
import 'package:petco/globals/globals.dart'; // Import the global cart list

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Check if none of the results indicate an active connection
      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        _showOfflinePage(); // Navigate to OfflinePage
      } else {
        _dismissOfflinePage(); // Navigate back to StorePage
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Show the OfflinePage when offline
  void _showOfflinePage() {
    if (!_isOffline) {
      setState(() {
        _isOffline = true;
      });
      // Navigate to the OfflinePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OfflinePage()), // Replace with your OfflinePage
      );
    }
  }

  // Dismiss the OfflinePage and go back to the StorePage when online
  void _dismissOfflinePage() {
    if (_isOffline) {
      setState(() {
        _isOffline = false;
      });
      // Navigate back to the StorePage if the device is online
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StorePage()), // Replace with your StorePage
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Store'),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.miscellaneous_services), text: 'Services'),
              Tab(icon: Icon(Icons.shopping_cart), text: 'Orders'),
              Tab(icon: Icon(Icons.person), text: 'User'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            StorePageContent(),
            ServicePage(),
            OrderPage(),
            UserPage(),
          ],
        ),
      ),
    );
  }
}

class StorePageContent extends StatefulWidget {
  @override
  _StorePageContentState createState() => _StorePageContentState();
}

class _StorePageContentState extends State<StorePageContent> {
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = ProductService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products available.'));
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final product = snapshot.data![index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(
                              name: product.name,
                              price: '\$${product.price.toStringAsFixed(2)}',
                              imageUrl: product.imageUrl,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.network(product.imageUrl, fit: BoxFit.cover),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Add the product to the cart
                                      _addToCart(product);
                                    },
                                    child: const Text('Add to Cart'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(Product product) {
    // Check if the item already exists in the cart
    final existingItem = cart.firstWhere(
          (item) => item.name == product.name,
      orElse: () => CartItem(name: '', price: 0, image: ''),
    );

    if (existingItem.name.isNotEmpty) {
      // If the item exists, increase the quantity
      existingItem.quantity++;
    } else {
      // If the item doesn't exist, add it to the cart
      cart.add(CartItem(
        name: product.name,
        price: product.price,
        image: product.imageUrl,
      ));
    }

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final String name;
  final String price;
  final String imageUrl;

  const ProductDetailPage({
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(imageUrl),
            const SizedBox(height: 20),
            Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(price, style: TextStyle(fontSize: 20, color: Colors.green)),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add the product to the cart
                  _addToCart(context);
                },
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(BuildContext context) {
    // Create a CartItem from the Product
    final cartItem = CartItem(
      name: name,
      price: double.parse(price.replaceAll('\$', '')),
      image: imageUrl,
    );

    // Check if the item already exists in the cart
    final existingItem = cart.firstWhere(
          (item) => item.name == name,
      orElse: () => CartItem(name: '', price: 0, image: ''),
    );

    if (existingItem.name.isNotEmpty) {
      // If the item exists, increase the quantity
      existingItem.quantity++;
    } else {
      // If the item doesn't exist, add it to the cart
      cart.add(cartItem);
    }

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name added to cart!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}