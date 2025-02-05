import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:petco/models/product.dart';

class ProductService {
  static const String supabaseUrl = "https://ljpnsbcmphwsvmltnohv.supabase.co"; // Replace with your Supabase project URL
  static const String bucketPath = "/storage/v1/object/public/Storage/"; // Public storage path

  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://caf5-2402-4000-b2c0-be4e-8d59-5f6b-26b4-c0eb.ngrok-free.app/api/app/products'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        List<Product> products = data.map<Product>((productJson) {
          // Extract the image name from the JSON (assuming it's in `pro_image_url`)
          String imageName = productJson['pro_image_url']?.split('/').last ?? 'default.png';

          return Product(
            id: productJson['id'] ?? 0,
            name: productJson['pro_name'] ?? 'Unknown Product',
            price: double.tryParse(productJson['pro_price']?.toString() ?? '0.0') ?? 0.0,
            imageUrl: "$supabaseUrl$bucketPath$imageName", // Construct Supabase image URL
          );
        }).toList();

        return products;
      } else {
        print('Server error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }
}