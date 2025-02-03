import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'service.dart';
import 'user.dart';
import 'order.dart';
import 'package:petco/models/cart_item.dart';
import 'package:petco/globals/globals.dart';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Listen to connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        _showOfflineSnackbar();
      } else {
        _dismissOfflineSnackbar();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _showOfflineSnackbar() {
    if (!_isOffline) {
      setState(() {
        _isOffline = true;
      });
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: const Text('You are offline. Please check your internet connection.'),
          duration: const Duration(days: 1), // Keep showing until dismissed
        ),
      );
    }
  }

  void _dismissOfflineSnackbar() {
    if (_isOffline) {
      setState(() {
        _isOffline = false;
      });
      _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
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
            StorePageContent(), // Content of the store page
            ServicePage(),     // The new ServicesPage
            OrderPage(),      // Replace with OrdersPage
            UserPage(),      // Replace with UserPage
          ],
        ),
      ),
    );
  }
}

class StorePageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: MediaQuery.of(context).size.height * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for products',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Featured Products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: OrientationBuilder(
              builder: (context, orientation) {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: orientation == Orientation.portrait ? 0.75 : 1.0,
                  ),
                  itemCount: 4, // Replace with dynamic item count if needed
                  itemBuilder: (context, index) {
                    final productName = index % 2 == 0 ? 'Dog Food' : 'Dog Toys';
                    final productPrice = index % 2 == 0 ? '\$24.99' : '\$14.99';
                    final productImage = index % 2 == 0
                        ? 'https://via.placeholder.com/150/000000/FFFFFF/?text=Dog+Food'
                        : 'https://via.placeholder.com/150/FF0000/FFFFFF/?text=Dog+Toys';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(
                              name: productName,
                              price: productPrice,
                              image: productImage,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(10)),
                                child: Image.network(
                                  productImage,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    productPrice,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
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
}

class ProductDetailPage extends StatefulWidget {
  final String name;
  final String price;
  final String image;

  const ProductDetailPage({
    Key? key,
    required this.name,
    required this.price,
    required this.image,
  }) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1; // Default quantity
  late double _price; // Parsed price
  late double _totalPrice; // Total price

  @override
  void initState() {
    super.initState();
    _price = double.parse(widget.price.replaceAll('\$', ''));
    _totalPrice = _price;
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
      _totalPrice = _quantity * _price;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        _totalPrice = _quantity * _price;
      });
    }
  }

  void _addToCart() {
    // Check if item already exists in the cart
    final existingItem = cart.firstWhere(
          (item) => item.name == widget.name,
      orElse: () => CartItem(name: '', price: 0, image: ''),
    );

    if (existingItem.name.isNotEmpty) {
      setState(() {
        existingItem.quantity += _quantity;
      });
    } else {
      cart.add(CartItem(
        name: widget.name,
        price: _price,
        image: widget.image,
        quantity: _quantity,
      ));
    }

    // Navigate to Order Page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrderPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isPortrait
            ? Column(
          children: _buildProductDetails(context),
        )
            : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildProductDetails(context),
        ),
      ),
    );
  }

  List<Widget> _buildProductDetails(BuildContext context) {
    return [
      Expanded(
        child: Image.network(
          widget.image,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(width: 20),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '\$${_price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _decrementQuantity,
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '$_quantity',
                  style: const TextStyle(fontSize: 20),
                ),
                IconButton(
                  onPressed: _incrementQuantity,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Total: \$${_totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _addToCart,
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
