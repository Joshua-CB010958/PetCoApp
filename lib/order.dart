import 'package:flutter/material.dart';
import 'package:petco/globals/globals.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String? currentLocation;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _userlocctrl = TextEditingController();

  Future<void> _getUserCurrentLoc() async {
    try {
      // Fetch current location
      Position position = await _determinePosition();

      // Get the place based on the position
      _getPlace(position);

    } catch (e) {
      // Show error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error while fetching location')),
      );
    }
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw 'Location permission denied';
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  void _getPlace(Position pos) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    Placemark placeMark = placemarks[0];

    String name = placeMark.name ?? "";
    String subLocality = placeMark.subLocality ?? "";
    String locality = placeMark.locality ?? "";
    String administrativeArea = placeMark.administrativeArea ?? "";
    String postalCode = placeMark.postalCode ?? "";
    String country = placeMark.country ?? "";

    String address = "$name, $subLocality,\n$locality, $postalCode,\n$administrativeArea, $country";
    _userlocctrl.text = address;

    setState(() {
      currentLocation = address;
    });
  }

  void _showAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Delivery Address'),
        content: TextField(
          controller: _addressController,
          decoration: const InputDecoration(
            hintText: 'Enter your address',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                currentLocation = _addressController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      cart.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    double totalAmount = cart.fold(0, (sum, item) => sum + item.totalPrice);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Location Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (currentLocation != null)
                    Text(
                      currentLocation!,
                      style: TextStyle(color: textColor),
                    ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _getUserCurrentLoc,
                        icon: const Icon(Icons.location_on),
                        label: const Text('Use Current Location'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _showAddressDialog,
                        icon: const Icon(Icons.edit_location),
                        label: const Text('Enter Address'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Existing Order Summary Section
          Text(
            'Order Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 10),
          ...List.generate(cart.length, (index) {
            final item = cart[index];
            return ListTile(
              leading: Image.network(item.image, width: 50),
              title: Text(item.name, style: TextStyle(color: textColor)),
              subtitle: Text('Quantity: ${item.quantity}', style: TextStyle(color: textColor)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(color: textColor),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeItem(index),
                  ),
                ],
              ),
            );
          }),
          const Divider(),
          Text(
            'Total: \$${totalAmount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle checkout or payment logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.white : Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                'Complete Purchase',
                style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.black : Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}