import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  String _enrollmentNumber = '';
  String _profileImageUrl = '';
  File? _profileImage; // Profile image file

  // Controllers for user input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _enrollmentController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final ImagePicker _picker = ImagePicker(); // Image picker
  User? _currentUser; // Firebase user
  bool _isLoading = false; // Loading state

  String? _selectedClass; // Selected class
  String? _selectedSection; // Selected section

  final List<String> classes =
      List.generate(12, (index) => (index + 1).toString());
  final List<String> sections = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser(); // Fetch the current authenticated user
  }

  @override
  void dispose() {
    // Dispose of the controllers
    _nameController.dispose();
    _enrollmentController.dispose();
    _dobController.dispose();
    _contactController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      await _fetchUserData(); // Fetch user profile data from Firestore
    }
  }

  Future<void> _fetchUserData() async {
    if (_currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('profile_history')
            .doc(_currentUser!.uid) // Using UID as document ID
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;

          setState(() {
            _userName = userData['name'] ?? 'NA';
            _enrollmentNumber = userData['enrollmentNumber'] ?? 'Not available';
            _profileImageUrl = userData['profileImageUrl'] ?? '';

            // Populate text fields
            _nameController.text = userData['name'] ?? '';
            _enrollmentController.text = userData['enrollmentNumber'] ?? '';
            _selectedClass = userData['class'] ?? '';
            _selectedSection = userData['section'] ?? '';
            _dobController.text = userData['dateOfBirth'] ?? '';
            _contactController.text = userData['contactNumber'] ?? '';
            _fatherNameController.text = userData['fatherName'] ?? '';
            _motherNameController.text = userData['motherName'] ?? '';
            _addressController.text = userData['address'] ?? '';
          });
        } else {
          print("No document found for the current user.");
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${_currentUser!.uid}.jpg');
      await storageRef.putFile(_profileImage!);
      String downloadUrl = await storageRef.getDownloadURL();

      setState(() {
        _profileImageUrl = downloadUrl; // Set the download URL
      });
    } catch (e) {
      print("Error uploading profile image: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _storeUserProfile() async {
    if (_currentUser == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Upload profile image if selected
      if (_profileImage != null) {
        await _uploadProfileImage();
      }

      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('profile_history')
          .doc(_currentUser!.uid); // Using UID as document ID

      // Store updated profile data
      await userDocRef.set({
        'name': _nameController.text,
        'enrollmentNumber': _enrollmentController.text,
        'section': _selectedSection,
        'dateOfBirth': _dobController.text,
        'contactNumber': _contactController.text,
        'fatherName': _fatherNameController.text,
        'motherName': _motherNameController.text,
        'address': _addressController.text,
        'class': _selectedClass,
        'profileImageUrl': _profileImageUrl,
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error storing student data: $e");
    }
  }

  bool _validateFields() {
    if (_nameController.text.isEmpty ||
        _enrollmentController.text.isEmpty ||
        _selectedClass == null ||
        _selectedSection == null ||
        _dobController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _fatherNameController.text.isEmpty ||
        _motherNameController.text.isEmpty ||
        _addressController.text.isEmpty) {
      return false;
    }
    return true;
  }

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you want to save your changes?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User cancels
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                Navigator.pushReplacementNamed(
                    context, '/home'); // User confirms
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  // Extracted date picker dialog
  Future<void> _showDatePickerDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Date of Birth'),
          content: Container(
            width: double.maxFinite,
            height: 350, // Adjust height if needed to fit your layout
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.single,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                setState(() {
                  if (args.value != null) {
                    DateTime selectedDate = args.value;
                    _dobController.text = selectedDate
                        .toLocal()
                        .toString()
                        .split(' ')[0]; // Formatting as YYYY-MM-DD
                  }
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile image
              GestureDetector(
                onTap: () async {
                  final ImageSource? source = await showDialog<ImageSource>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Select Image Source"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(ImageSource.camera);
                            },
                            child: const Text("Camera"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(ImageSource.gallery);
                            },
                            child: const Text("Gallery"),
                          ),
                        ],
                      );
                    },
                  );

                  if (source != null) {
                    final XFile? image =
                        await _picker.pickImage(source: source);
                    setState(() {
                      if (image != null) {
                        _profileImage = File(image.path);
                      } else {
                        _profileImage = null;
                      }
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? Image.file(_profileImage!).image
                      : _profileImageUrl.isNotEmpty
                          ? NetworkImage(_profileImageUrl)
                          : null,
                  child: _profileImage != null
                      ? null
                      : _profileImageUrl.isNotEmpty
                          ? null
                          : Icon(Icons.add_a_photo, size: 30),
                ),
              ),

              const SizedBox(height: 20),

              // Text fields and dropdowns for profile
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _enrollmentController,
                decoration: const InputDecoration(
                  labelText: 'Enrollment Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Dropdown for Class
              DropdownButtonFormField<String>(
                value: _selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                ),
                items: classes.map((String classItem) {
                  return DropdownMenuItem<String>(
                    value: classItem,
                    child: Text(classItem),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedClass = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Dropdown for Section
              DropdownButtonFormField<String>(
                value: _selectedSection,
                decoration: const InputDecoration(
                  labelText: 'Section',
                  border: OutlineInputBorder(),
                ),
                items: sections.map((String sectionItem) {
                  return DropdownMenuItem<String>(
                    value: sectionItem,
                    child: Text(sectionItem),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSection = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Date of Birth field
              TextField(
                controller: _dobController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                ),
                onTap: _showDatePickerDialog, // Show date picker on tap
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _fatherNameController,
                decoration: const InputDecoration(
                  labelText: 'Father Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _motherNameController,
                decoration: const InputDecoration(
                  labelText: 'Mother Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (_validateFields()) {
                    final confirmed = await _showConfirmationDialog();
                    if (confirmed == true) {
                      _storeUserProfile(); // Store user profile data
                    }
                  } else {
                    // Show an error message if validation fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 42, 134, 209),
                    foregroundColor: Colors.white),
                child: _isLoading
                    ? const CircularProgressIndicator() // Show loading indicator
                    : const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
