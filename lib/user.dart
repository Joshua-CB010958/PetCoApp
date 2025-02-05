import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For handling File type
import 'package:shared_preferences/shared_preferences.dart'; // For storing data locally
import 'dart:convert'; // For JSON parsing

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  File? _profileImage;
  String? _name;
  String? _email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  // Method to retrieve user information from SharedPreferences
  Future<void> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data'); // Retrieve stored user data

    if (userDataString != null) {
      final userData = json.decode(userDataString); // Decode the JSON string
      setState(() {
        _name = userData['name'];
        _email = userData['email'];
        _isLoading = false;
      });
    } else {
      // Handle case where user data is not available
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to pick an image from the camera
  Future<void> _changeProfilePhoto() async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        setState(() {
          _profileImage = File(pickedImage.path); // Update profile image
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: MediaQuery.of(context).size.height * 0.02,
        ),
        child: Center(
          child: OrientationBuilder(
            builder: (context, orientation) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image Section
                  CircleAvatar(
                    radius: orientation == Orientation.portrait ? 90 : 120,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!) // Display captured image
                        : const AssetImage('assets/user_avatar.png') as ImageProvider, // Default avatar
                    child: _profileImage == null
                        ? const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    )
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Button to change profile photo
                  ElevatedButton(
                    onPressed: _changeProfilePhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: orientation == Orientation.portrait ? 40 : 60,
                        vertical: orientation == Orientation.portrait ? 10 : 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Change Profile Photo'),
                  ),
                  const SizedBox(height: 20),

                  // User Information
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else ...[
                    const Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    Text(_name ?? 'No Name'),
                    const SizedBox(height: 10),

                    const Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    Text(_email ?? 'No Email'),
                    const SizedBox(height: 20),
                  ],

                  // Edit Profile and Logout Buttons
                  ElevatedButton(
                    onPressed: () {
                      // Add edit functionality here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: orientation == Orientation.portrait ? 40 : 60,
                        vertical: orientation == Orientation.portrait ? 10 : 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Edit'),
                  ),
                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () async {
                      // Clear the token and user data, then navigate to the login page
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('auth_token');
                      await prefs.remove('user_data');
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}