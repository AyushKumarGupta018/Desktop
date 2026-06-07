import 'dart:convert';
import 'dart:math';

//import 'package:deskprint/main.dart';
import 'package:deskprint/screens/printing_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final bool isFirstTime;
  final bool isReturning;

  const LoginScreen({
    super.key,
    this.isFirstTime = false,
    this.isReturning = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cafeIdController = TextEditingController();
  final _cafeNameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  // ADD THESE NEW VARIABLES:
  bool _isNewUser = true;
  // Firebase REST API configuration
  final String _firebaseProjectId = 'creatingmyapp-defa0';
  final String _firebaseApiKey = 'AIzaSyAYsFc-uSy3uh77MqM3Cp5LOIOlwREskYE';

  // ADD THIS initState method after your variables:
  @override
  void initState() {
    super.initState();
    _isNewUser = widget.isFirstTime;
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String idToken;

      if (_isNewUser || widget.isFirstTime) {
        // CREATE NEW ACCOUNT
        final authResponse = await http.post(
          Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_firebaseApiKey',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _emailController.text.trim(),
            'password': _passwordController.text.trim(),
            'returnSecureToken': true,
          }),
        );

        if (authResponse.statusCode != 200) {
          final error = jsonDecode(authResponse.body);
          String errorMessage =
              error['error']['message'] ?? 'Account creation failed';

          // Handle specific error cases
          if (errorMessage.contains('EMAIL_EXISTS')) {
            errorMessage =
                'An account with this email already exists. Try "Existing Café" instead.';
          } else if (errorMessage.contains('WEAK_PASSWORD')) {
            errorMessage = 'Password should be at least 6 characters long.';
          } else if (errorMessage.contains('INVALID_EMAIL')) {
            errorMessage = 'Please enter a valid email address.';
          }

          throw Exception(errorMessage);
        }

        final authData = jsonDecode(authResponse.body);
        idToken = authData['idToken'];
      } else {
        // SIGN IN TO EXISTING ACCOUNT
        final authResponse = await http.post(
          Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_firebaseApiKey',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _emailController.text.trim(),
            'password': _passwordController.text.trim(),
            'returnSecureToken': true,
          }),
        );

        if (authResponse.statusCode != 200) {
          final error = jsonDecode(authResponse.body);
          String errorMessage = error['error']['message'] ?? 'Sign in failed';

          // Handle specific error cases
          if (errorMessage.contains('EMAIL_NOT_FOUND')) {
            errorMessage =
                'No account found with this email. Try "New Café" instead.';
          } else if (errorMessage.contains('INVALID_PASSWORD')) {
            errorMessage = 'Incorrect password. Please try again.';
          } else if (errorMessage.contains('USER_DISABLED')) {
            errorMessage = 'This account has been disabled.';
          }

          throw Exception(errorMessage);
        }

        final authData = jsonDecode(authResponse.body);
        idToken = authData['idToken'];
      }

      // Generate or use existing café ID
      final cafeId = _cafeIdController.text.trim().isEmpty
          ? _generateCafeId()
          : _cafeIdController.text.trim();

      final cafeName = _cafeNameController.text.trim().isEmpty
          ? 'Café ${cafeId.toUpperCase()}'
          : _cafeNameController.text.trim();

      // Store café information in Firestore via REST API
      final cafeData = {
        'cafeId': cafeId,
        'name': cafeName,
        'owner': _emailController.text.trim(),
        'lastLogin': DateTime.now().toIso8601String(),
        'active': true,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final firestoreResponse = await http.patch(
        Uri.parse(
          'https://firestore.googleapis.com/v1/projects/$_firebaseProjectId/databases/(default)/documents/cafes/$cafeId?access_token=$idToken',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fields': _convertToFirestoreFormat(cafeData)}),
      );

      if (firestoreResponse.statusCode != 200) {
        throw Exception('Failed to save café information');
      }

      // Save login credentials locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cafe_id', cafeId);
      await prefs.setString('cafe_name', cafeName);
      await prefs.setString('owner_email', _emailController.text.trim());
      await prefs.setString('id_token', idToken);

      // Navigate to dashboard
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PrintingDashboard()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFirebaseHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Firebase Setup Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'To use this app, you need a Firebase account:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('1. Go to console.firebase.google.com'),
              Text('2. Create a new project or use existing'),
              Text('3. Enable Authentication with Email/Password'),
              Text('4. Enable Firestore Database'),
              Text('5. Use the same email/password here'),
              SizedBox(height: 12),
              Text(
                'The app will automatically configure your café settings.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _convertToFirestoreFormat(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    for (final entry in data.entries) {
      if (entry.value is String) {
        result[entry.key] = {'stringValue': entry.value};
      } else if (entry.value is bool) {
        result[entry.key] = {'booleanValue': entry.value};
      } else if (entry.value is int) {
        result[entry.key] = {'integerValue': entry.value.toString()};
      } else {
        result[entry.key] = {'stringValue': entry.value.toString()};
      }
    }
    return result;
  }

  String _generateCafeId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      6,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isFirstTime ? 'Set Up Your Café' : 'Café Desktop - Login',
        ),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!widget.isFirstTime) ...[
                  Icon(Icons.local_cafe, size: 80, color: Colors.brown[700]),
                  const SizedBox(height: 32),
                ],

                if (widget.isFirstTime) ...[
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'First Time Setup',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create your Firebase account first at firebase.google.com, then use those credentials here to set up your café.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Toggle between new user and existing user
                if (!widget.isFirstTime) ...[
                  ToggleButtons(
                    isSelected: [_isNewUser, !_isNewUser],
                    onPressed: (index) {
                      setState(() {
                        _isNewUser = index == 0;
                        _errorMessage = null;
                      });
                    },
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('New Café'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Existing Café'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    helperText: 'Your Firebase account email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    helperText: 'Your Firebase account password',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                if (_isNewUser) ...[
                  TextField(
                    controller: _cafeNameController,
                    decoration: const InputDecoration(
                      labelText: 'Café Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                      helperText: 'Enter your café name',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: _cafeIdController,
                  decoration: InputDecoration(
                    labelText: _isNewUser
                        ? 'Café ID (leave empty to auto-generate)'
                        : 'Existing Café ID',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.store),
                    helperText: _isNewUser
                        ? 'Leave empty for new café'
                        : 'Enter your existing café ID',
                  ),
                ),
                const SizedBox(height: 24),

                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[800]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[800]),
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[700],
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isNewUser ? 'Create Café' : 'Login',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                if (widget.isFirstTime) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _showFirebaseHelp(context),
                    child: const Text('Need help with Firebase setup?'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
