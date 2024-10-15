import 'package:flutter/material.dart';
import 'package:shift_master/screens/loading_screen_dart.dart';
import 'package:shift_master/services/firebase_service.dart';
import 'package:shift_master/utils/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }
    try {
      await _firebaseService.register(
        _emailController.text,
        _passwordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
      );
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.signInWithGoogle();
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
        // Wrap the Scaffold with LoadingOverlay
        isLoading: _isLoading,
        loadingMessage: 'Creating account...',
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    const Text(
                      'Shift Master',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Register your new account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 60, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                        _firstNameController, "First Name", Icons.person),
                    const SizedBox(height: 16),
                    _buildTextField(
                        _lastNameController, "Last Name", Icons.person),
                    const SizedBox(height: 16),
                    _buildTextField(_emailController, "Email", Icons.email),
                    const SizedBox(height: 16),
                    _buildTextField(_passwordController, "Password", Icons.lock,
                        isPassword: true),
                    const SizedBox(height: 16),
                    _buildTextField(_confirmPasswordController,
                        "Confirm Password", Icons.lock,
                        isPassword: true),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              "SIGN UP",
                              style: TextStyle(color: AppTheme.textColor2),
                            ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Sign up with:",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Image.asset('assets/images/google.png',
                              width: 30, height: 30),
                          onPressed: _signInWithGoogle,
                        ),
                        IconButton(
                          icon: Image.asset('assets/images/linkedin.png',
                              width: 30, height: 30),
                          onPressed: () {
                            // TODO: Implement Linkedin sign-up
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        "Already have an account? Sign In",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: isPassword,
    );
  }
}
