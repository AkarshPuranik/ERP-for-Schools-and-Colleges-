import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:school_erp/screens/Teacher_screens.dart/teacher_create_account.dart';
import 'package:school_erp/screens/Teacher_screens.dart/teacher_home_screen.dart';
import 'package:school_erp/screens/login_screens/signup_screen.dart';
import 'package:school_erp/screens/student_screens/home_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool? _selectedDoctor;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _enrollmentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool isStudent = true;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (isStudent) {
        var snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('enrollment_number', isEqualTo: _enrollmentController.text.trim())
            .get();

        print("Student Snapshot: ${snapshot.docs}");

        if (snapshot.docs.isNotEmpty) {
          var email = snapshot.docs.first.get('email');
          UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: _passwordController.text.trim(),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Enrollment number not found")),
          );
        }
      } else {
        try {
          UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          var teacherSnapshot = await FirebaseFirestore.instance
              .collection('teachers')
              .where('email', isEqualTo: _emailController.text.trim())
              .get();

          print("Teacher Snapshot: ${teacherSnapshot.docs}");

          if (teacherSnapshot.docs.isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TeacherHomeScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Teacher not found")),
            );
            await _auth.signOut();
          }
        } catch (e) {
          if (e is FirebaseAuthException) {
            if (e.code == 'invalid-email') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Invalid email")),
              );
            } else if (e.code == 'wrong-password') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Wrong password")),
              );
            } else if (e.code == 'user-not-found') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User not found")),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Login failed: $e")),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("An error occurred: $e")),
            );
          }
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Account Type'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDoctor = true;
                          isStudent = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedDoctor == true ? Colors.blue : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          children: [
                            ZoomIn(
                              duration: Duration(seconds: 2),
                              child: Image.asset(
                                'assets/download.png',
                                height: 120.0, // Adjusted height
                                width: 120.0,  // Adjusted width
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            const Text(
                              'Student',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_selectedDoctor == true)
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.check, color: Colors.white, size: 15),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDoctor = false;
                          isStudent = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedDoctor == false ? Colors.blue : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          children: [
                            ZoomIn(
                              duration: Duration(seconds: 2),
                              child: Image.asset(
                                'assets/8065183.png',
                                height: 120.0, // Adjusted height
                                width: 120.0,  // Adjusted width
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            const Text(
                              'Teacher',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_selectedDoctor == false)
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.check, color: Colors.white, size: 15),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              if (_selectedDoctor != null) ...[
                FadeInLeft(
                  duration: Duration(seconds: 2),
                  child: TextFormField(
                    controller: isStudent ? _enrollmentController : _emailController,
                    decoration: InputDecoration(
                      labelText: isStudent ? 'Enrollment Number' : 'Email',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                FadeInRight(
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                ZoomIn(
                  duration: Duration(seconds: 2),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 135, 180, 236),
                        ),
                        foregroundColor: MaterialStateProperty.all(Colors.black)),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: LoadingIndicator(
                        indicatorType: Indicator.ballPulse,
                        colors: [Colors.red, Colors.green, Colors.blue],
                        strokeWidth: 2,
                        backgroundColor: Colors.transparent,
                      ),
                    )
                        : const Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
