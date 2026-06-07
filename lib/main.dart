import 'package:deskprint/screens/auth_wrapper.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:crypto/crypto.dart';
// import 'package:pdf/pdf.dart';
// import 'package:printing/printing.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'dart:math';
// import 'dart:async';
// import 'package:image/image.dart' as img;
//import 'package:pdf/widgets.dart' as pw;

enum LoginState { firstTime, returningUser, loggedIn }

void main() {
  runApp(const CafeDesktopApp());
}

class CafeDesktopApp extends StatelessWidget {
  const CafeDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Café Desktop Printing System',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// STEP 2: REPLACE your existing AuthWrapper class (around line 30) with this:
// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<LoginState>(
//       future: _checkLoginState(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Initializing Café System...'),
//                 ],
//               ),
//             ),
//           );
//         }

//         final loginState = snapshot.data ?? LoginState.firstTime;

//         switch (loginState) {
//           case LoginState.loggedIn:
//             return const PrintingDashboard();
//           case LoginState.returningUser:
//             return const LoginScreen(isReturning: true);
//           case LoginState.firstTime:
//             return const WelcomeScreen();
//         }
//       },
//     );
//   }

//   Future<LoginState> _checkLoginState() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cafeId = prefs.getString('cafe_id');
//     final ownerEmail = prefs.getString('owner_email');
//     final hasSeenWelcome = prefs.getBool('has_seen_welcome') ?? false;

//     if (cafeId != null && ownerEmail != null) {
//       return LoginState.loggedIn;
//     } else if (hasSeenWelcome) {
//       return LoginState.returningUser;
//     } else {
//       return LoginState.firstTime;
//     }
//   }
// }

// // STEP 3: ADD this new WelcomeScreen class BEFORE your LoginScreen class (around line 60)
// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.brown[400]!, Colors.brown[700]!],
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.local_cafe, size: 120, color: Colors.white),
//                 const SizedBox(height: 24),
//                 const Text(
//                   'Welcome to Café Desktop',
//                   style: TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Your complete printing solution for cafés',
//                   style: TextStyle(fontSize: 18, color: Colors.white70),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 48),
//                 _buildFeatureCard(
//                   Icons.qr_code_scanner,
//                   'QR Code Printing',
//                   'Customers scan QR codes to print documents instantly',
//                 ),
//                 const SizedBox(height: 16),
//                 _buildFeatureCard(
//                   Icons.cloud_sync,
//                   'Cloud Synchronization',
//                   'Automatic backup and sync across devices',
//                 ),
//                 const SizedBox(height: 16),
//                 _buildFeatureCard(
//                   Icons.print,
//                   'Automated Printing',
//                   'Print jobs are processed automatically',
//                 ),
//                 const SizedBox(height: 48),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton(
//                     onPressed: () => _continueToSetup(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.brown[700],
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       'Get Started',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextButton(
//                   onPressed: () => _showExistingUserDialog(context),
//                   child: const Text(
//                     'Already have an account?',
//                     style: TextStyle(color: Colors.white70),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFeatureCard(IconData icon, String title, String description) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.white, size: 32),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   description,
//                   style: const TextStyle(color: Colors.white70, fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _continueToSetup(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('has_seen_welcome', true);

//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(
//         builder: (context) => const LoginScreen(isFirstTime: true),
//       ),
//     );
//   }

//   void _showExistingUserDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Existing User'),
//         content: const Text(
//           'If you already have a café account, you can log in with your existing credentials.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _continueToSetup(context);
//             },
//             child: const Text('Continue to Login'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class LoginScreen extends StatefulWidget {
//   final bool isFirstTime;
//   final bool isReturning;

//   const LoginScreen({
//     super.key,
//     this.isFirstTime = false,
//     this.isReturning = false,
//   });

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _cafeIdController = TextEditingController();
//   final _cafeNameController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;
//   // ADD THESE NEW VARIABLES:
//   bool _isNewUser = true;
//   // Firebase REST API configuration
//   final String _firebaseProjectId = 'creatingmyapp-defa0';
//   final String _firebaseApiKey = 'AIzaSyAYsFc-uSy3uh77MqM3Cp5LOIOlwREskYE';

//   // ADD THIS initState method after your variables:
//   @override
//   void initState() {
//     super.initState();
//     _isNewUser = widget.isFirstTime;
//   }

//   Future<void> _login() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       String idToken;

//       if (_isNewUser || widget.isFirstTime) {
//         // CREATE NEW ACCOUNT
//         final authResponse = await http.post(
//           Uri.parse(
//             'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_firebaseApiKey',
//           ),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             'email': _emailController.text.trim(),
//             'password': _passwordController.text.trim(),
//             'returnSecureToken': true,
//           }),
//         );

//         if (authResponse.statusCode != 200) {
//           final error = jsonDecode(authResponse.body);
//           String errorMessage =
//               error['error']['message'] ?? 'Account creation failed';

//           // Handle specific error cases
//           if (errorMessage.contains('EMAIL_EXISTS')) {
//             errorMessage =
//                 'An account with this email already exists. Try "Existing Café" instead.';
//           } else if (errorMessage.contains('WEAK_PASSWORD')) {
//             errorMessage = 'Password should be at least 6 characters long.';
//           } else if (errorMessage.contains('INVALID_EMAIL')) {
//             errorMessage = 'Please enter a valid email address.';
//           }

//           throw Exception(errorMessage);
//         }

//         final authData = jsonDecode(authResponse.body);
//         idToken = authData['idToken'];
//       } else {
//         // SIGN IN TO EXISTING ACCOUNT
//         final authResponse = await http.post(
//           Uri.parse(
//             'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_firebaseApiKey',
//           ),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             'email': _emailController.text.trim(),
//             'password': _passwordController.text.trim(),
//             'returnSecureToken': true,
//           }),
//         );

//         if (authResponse.statusCode != 200) {
//           final error = jsonDecode(authResponse.body);
//           String errorMessage = error['error']['message'] ?? 'Sign in failed';

//           // Handle specific error cases
//           if (errorMessage.contains('EMAIL_NOT_FOUND')) {
//             errorMessage =
//                 'No account found with this email. Try "New Café" instead.';
//           } else if (errorMessage.contains('INVALID_PASSWORD')) {
//             errorMessage = 'Incorrect password. Please try again.';
//           } else if (errorMessage.contains('USER_DISABLED')) {
//             errorMessage = 'This account has been disabled.';
//           }

//           throw Exception(errorMessage);
//         }

//         final authData = jsonDecode(authResponse.body);
//         idToken = authData['idToken'];
//       }

//       // Generate or use existing café ID
//       final cafeId = _cafeIdController.text.trim().isEmpty
//           ? _generateCafeId()
//           : _cafeIdController.text.trim();

//       final cafeName = _cafeNameController.text.trim().isEmpty
//           ? 'Café ${cafeId.toUpperCase()}'
//           : _cafeNameController.text.trim();

//       // Store café information in Firestore via REST API
//       final cafeData = {
//         'cafeId': cafeId,
//         'name': cafeName,
//         'owner': _emailController.text.trim(),
//         'lastLogin': DateTime.now().toIso8601String(),
//         'active': true,
//         'createdAt': DateTime.now().toIso8601String(),
//       };

//       final firestoreResponse = await http.patch(
//         Uri.parse(
//           'https://firestore.googleapis.com/v1/projects/$_firebaseProjectId/databases/(default)/documents/cafes/$cafeId?access_token=$idToken',
//         ),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'fields': _convertToFirestoreFormat(cafeData)}),
//       );

//       if (firestoreResponse.statusCode != 200) {
//         throw Exception('Failed to save café information');
//       }

//       // Save login credentials locally
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('cafe_id', cafeId);
//       await prefs.setString('cafe_name', cafeName);
//       await prefs.setString('owner_email', _emailController.text.trim());
//       await prefs.setString('id_token', idToken);

//       // Navigate to dashboard
//       if (mounted) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const PrintingDashboard()),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString().replaceFirst('Exception: ', '');
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _showFirebaseHelp(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Firebase Setup Help'),
//         content: const SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'To use this app, you need a Firebase account:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 12),
//               Text('1. Go to console.firebase.google.com'),
//               Text('2. Create a new project or use existing'),
//               Text('3. Enable Authentication with Email/Password'),
//               Text('4. Enable Firestore Database'),
//               Text('5. Use the same email/password here'),
//               SizedBox(height: 12),
//               Text(
//                 'The app will automatically configure your café settings.',
//                 style: TextStyle(fontStyle: FontStyle.italic),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Got it'),
//           ),
//         ],
//       ),
//     );
//   }

//   Map<String, dynamic> _convertToFirestoreFormat(Map<String, dynamic> data) {
//     final result = <String, dynamic>{};
//     for (final entry in data.entries) {
//       if (entry.value is String) {
//         result[entry.key] = {'stringValue': entry.value};
//       } else if (entry.value is bool) {
//         result[entry.key] = {'booleanValue': entry.value};
//       } else if (entry.value is int) {
//         result[entry.key] = {'integerValue': entry.value.toString()};
//       } else {
//         result[entry.key] = {'stringValue': entry.value.toString()};
//       }
//     }
//     return result;
//   }

//   String _generateCafeId() {
//     const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
//     final random = Random();
//     return List.generate(
//       6,
//       (index) => chars[random.nextInt(chars.length)],
//     ).join();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.isFirstTime ? 'Set Up Your Café' : 'Café Desktop - Login',
//         ),
//         backgroundColor: Colors.brown[700],
//         foregroundColor: Colors.white,
//         automaticallyImplyLeading: false,
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(32),
//             constraints: const BoxConstraints(maxWidth: 500),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if (!widget.isFirstTime) ...[
//                   Icon(Icons.local_cafe, size: 80, color: Colors.brown[700]),
//                   const SizedBox(height: 32),
//                 ],

//                 if (widget.isFirstTime) ...[
//                   Card(
//                     color: Colors.blue[50],
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           Icon(
//                             Icons.info_outline,
//                             color: Colors.blue[700],
//                             size: 32,
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'First Time Setup',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blue[700],
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           const Text(
//                             'Create your Firebase account first at firebase.google.com, then use those credentials here to set up your café.',
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                 ],

//                 // Toggle between new user and existing user
//                 if (!widget.isFirstTime) ...[
//                   ToggleButtons(
//                     isSelected: [_isNewUser, !_isNewUser],
//                     onPressed: (index) {
//                       setState(() {
//                         _isNewUser = index == 0;
//                         _errorMessage = null;
//                       });
//                     },
//                     children: const [
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         child: Text('New Café'),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         child: Text('Existing Café'),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                 ],

//                 TextField(
//                   controller: _emailController,
//                   decoration: const InputDecoration(
//                     labelText: 'Email',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.email),
//                     helperText: 'Your Firebase account email',
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: _passwordController,
//                   decoration: const InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.lock),
//                     helperText: 'Your Firebase account password',
//                   ),
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 16),

//                 if (_isNewUser) ...[
//                   TextField(
//                     controller: _cafeNameController,
//                     decoration: const InputDecoration(
//                       labelText: 'Café Name',
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.business),
//                       helperText: 'Enter your café name',
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                 ],

//                 TextField(
//                   controller: _cafeIdController,
//                   decoration: InputDecoration(
//                     labelText: _isNewUser
//                         ? 'Café ID (leave empty to auto-generate)'
//                         : 'Existing Café ID',
//                     border: const OutlineInputBorder(),
//                     prefixIcon: const Icon(Icons.store),
//                     helperText: _isNewUser
//                         ? 'Leave empty for new café'
//                         : 'Enter your existing café ID',
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 if (_errorMessage != null)
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     margin: const EdgeInsets.only(bottom: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.red[100],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.error_outline, color: Colors.red[800]),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             _errorMessage!,
//                             style: TextStyle(color: Colors.red[800]),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _login,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.brown[700],
//                       foregroundColor: Colors.white,
//                     ),
//                     child: _isLoading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : Text(
//                             _isNewUser ? 'Create Café' : 'Login',
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                   ),
//                 ),

//                 if (widget.isFirstTime) ...[
//                   const SizedBox(height: 16),
//                   TextButton(
//                     onPressed: () => _showFirebaseHelp(context),
//                     child: const Text('Need help with Firebase setup?'),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class PrintingDashboard extends StatefulWidget {
//   const PrintingDashboard({super.key});

//   @override
//   State<PrintingDashboard> createState() => _PrintingDashboardState();
// }

// class _PrintingDashboardState extends State<PrintingDashboard> {
//   String? _cafeId;
//   String? _cafeName;
//   String? _idToken;
//   List<PrintJob> _printJobs = [];
//   bool _isInitialized = false;
//   bool _showQrCode = false;
//   Timer? _pollingTimer;

//   // Firebase configuration
//   final String _firebaseProjectId = 'creatingmyapp-defa0';

//   @override
//   void initState() {
//     super.initState();
//     _initializeDashboard();
//   }

//   @override
//   void dispose() {
//     _pollingTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _initializeDashboard() async {
//     final prefs = await SharedPreferences.getInstance();
//     _cafeId = prefs.getString('cafe_id');
//     _cafeName = prefs.getString('cafe_name');
//     _idToken = prefs.getString('id_token');

//     if (_cafeId != null) {
//       _startPollingForJobs();
//     }

//     setState(() {
//       _isInitialized = true;
//     });
//   }

//   void _startPollingForJobs() {
//     _pollingTimer?.cancel();
//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       _fetchPrintJobs();
//     });
//     _fetchPrintJobs(); // Initial fetch
//   }

//   Future<void> _fetchPrintJobs() async {
//     if (_cafeId == null || _idToken == null) return;

//     try {
//       final response = await http.get(
//         Uri.parse(
//           'https://firestore.googleapis.com/v1/projects/$_firebaseProjectId/databases/(default)/documents/printJobs'
//           '?access_token=$_idToken'
//           '&orderBy=uploadedAt desc',
//         ),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final documents = data['documents'] as List<dynamic>? ?? [];

//         final jobs = documents
//             .where((doc) {
//               final fields = doc['fields'] as Map<String, dynamic>? ?? {};
//               final cafeId = fields['cafeId']?['stringValue'];
//               final status = fields['status']?['stringValue'];
//               return cafeId == _cafeId && status == 'pending';
//             })
//             .map((doc) => PrintJob.fromFirestore(doc))
//             .toList();

//         setState(() {
//           _printJobs = jobs;
//         });

//         // Process new jobs
//         for (final job in jobs) {
//           _processJob(job);
//         }
//       }
//     } catch (e) {
//       print('Error fetching jobs: $e');
//     }
//   }

//   Future<void> _processJob(PrintJob job) async {
//     try {
//       // Update status to printing
//       await _updateJobStatus(job.id, 'printing');

//       // Download and decrypt the actual file
//       final actualFileData = await _downloadAndDecryptFile(job);

//       if (actualFileData != null) {
//         // Convert file to PDF based on file type and print directly
//         await _printFileDirectlyWithFiltering(
//           actualFileData,
//           job.fileName,
//           job.id,
//         );

//         // Update status to completed
//         await _updateJobStatus(job.id, 'completed');
//       } else {
//         throw Exception('Failed to download or decrypt file');
//       }

//       // Remove from local list
//       setState(() {
//         _printJobs.removeWhere((j) => j.id == job.id);
//       });
//     } catch (e) {
//       await _updateJobStatus(job.id, 'failed');
//       print('Error processing job: $e');
//     }
//   }

//   Future<void> _printFileDirectlyWithFiltering(
//     Uint8List fileData,
//     String fileName,
//     String job,
//   ) async {
//     try {
//       final String extension = fileName.toLowerCase().split('.').last;
//       Uint8List pdfData;

//       // Convert file to PDF (your existing conversion logic)
//       switch (extension) {
//         case 'pdf':
//           pdfData = fileData;
//           break;
//         case 'png':
//         case 'jpg':
//         case 'jpeg':
//         case 'gif':
//         case 'bmp':
//           pdfData = await _convertImageToPdf(fileData, fileName);
//           break;
//         case 'doc':
//         case 'docx':
//           pdfData = await _convertWordToPdf(fileData, fileName);
//           break;
//         case 'txt':
//           pdfData = await _convertTextToPdf(fileData, fileName);
//           break;
//         default:
//           pdfData = await _createUnsupportedFilePdf(fileName, extension);
//       }

//       // Get only physical printers
//       final physicalPrinter = await _selectPhysicalPrinter();

//       if (physicalPrinter != null) {
//         await Printing.directPrintPdf(
//           printer: physicalPrinter,
//           onLayout: (format) => pdfData,
//           name: fileName,
//           usePrinterSettings: true,
//         );
//       } else {
//         throw Exception('No physical printer available');
//       }
//     } catch (e) {
//       print('Error printing file: $e');
//       await _updateJobStatus(job, 'failed');
//     }
//   }

//   // Filter out virtual printers and only show physical ones
//   Future<Printer?> _selectPhysicalPrinter() async {
//     try {
//       final allPrinters = await Printing.listPrinters();

//       // Filter out virtual/PDF printers
//       final physicalPrinters = allPrinters.where((printer) {
//         final name = printer.name.toLowerCase();

//         // Common virtual printer names to exclude
//         final virtualPrinterKeywords = [
//           'microsoft print to pdf',
//           'microsoft xps document writer',
//           'print to pdf',
//           'pdf printer',
//           'foxit pdf printer',
//           'adobe pdf',
//           'cutepdf writer',
//           'doro pdf writer',
//           'fax',
//           'onenote',
//           'xps',
//         ];

//         // Check if printer name contains any virtual printer keywords
//         for (final keyword in virtualPrinterKeywords) {
//           if (name.contains(keyword)) {
//             return false; // Exclude this printer
//           }
//         }

//         return true; // Include this printer
//       }).toList();

//       if (physicalPrinters.isEmpty) {
//         throw Exception('No physical printers found');
//       }

//       // If only one physical printer, use it automatically
//       if (physicalPrinters.length == 1) {
//         return physicalPrinters.first;
//       }

//       // If multiple physical printers, let user choose
//       return await _showPrinterSelectionDialog(physicalPrinters);
//     } catch (e) {
//       print('Error selecting physical printer: $e');
//       return null;
//     }
//   }

//   // Show dialog to select from physical printers only
//   Future<Printer?> _showPrinterSelectionDialog(List<Printer> printers) async {
//     return await showDialog<Printer>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Select Printer'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Choose a physical printer:'),
//             const SizedBox(height: 16),
//             ...printers.map(
//               (printer) => ListTile(
//                 title: Text(printer.name),
//                 onTap: () => Navigator.pop(context, printer),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, null),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Replace your _printWithRestrictedSave method with this fixed version:
//   Future<void> _printWithRestrictedSave(
//     Uint8List pdfData,
//     String fileName,
//   ) async {
//     // FIX 2: Remove the unsupported 'actions' parameter
//     await Printing.layoutPdf(
//       onLayout: (format) => pdfData,
//       name: fileName,
//       format: PdfPageFormat.a4,
//       // Remove the 'actions' parameter as it's not supported
//       // The printing package doesn't support restricting actions in this way
//     );
//   }

//   Future<Uint8List> _convertImageToPdf(
//     Uint8List imageData,
//     String fileName,
//   ) async {
//     final pdf = pw.Document();

//     try {
//       // Decode image
//       final image = img.decodeImage(imageData);
//       if (image == null) throw Exception('Invalid image format');

//       // Convert to PNG for PDF embedding
//       final pngBytes = img.encodePng(image);
//       final pdfImage = pw.MemoryImage(pngBytes);

//       pdf.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat.a4,
//           build: (pw.Context context) {
//             return pw.Center(child: pw.Image(pdfImage, fit: pw.BoxFit.contain));
//           },
//         ),
//       );
//     } catch (e) {
//       // If image conversion fails, create error PDF
//       return await _createErrorPdf(fileName, 'Image conversion failed: $e');
//     }

//     return await pdf.save();
//   }

//   Future<Uint8List> _convertTextToPdf(
//     Uint8List textData,
//     String fileName,
//   ) async {
//     final pdf = pw.Document();

//     try {
//       final text = utf8.decode(textData);

//       // Split text into pages if too long
//       const int maxLinesPerPage = 50;
//       const int maxCharsPerLine = 80;

//       final lines = text.split('\n');
//       final pages = <List<String>>[];

//       for (int i = 0; i < lines.length; i += maxLinesPerPage) {
//         final pageLines = lines.skip(i).take(maxLinesPerPage).toList();
//         pages.add(pageLines);
//       }

//       for (final pageLines in pages) {
//         pdf.addPage(
//           pw.Page(
//             pageFormat: PdfPageFormat.a4,
//             margin: const pw.EdgeInsets.all(40),
//             build: (pw.Context context) {
//               return pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(
//                     fileName,
//                     style: pw.TextStyle(
//                       fontSize: 16,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                   pw.SizedBox(height: 20),
//                   ...pageLines.map(
//                     (line) => pw.Text(
//                       line.length > maxCharsPerLine
//                           ? line.substring(0, maxCharsPerLine) + '...'
//                           : line,
//                       style: const pw.TextStyle(fontSize: 10),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         );
//       }
//     } catch (e) {
//       return await _createErrorPdf(fileName, 'Text conversion failed: $e');
//     }

//     return await pdf.save();
//   }

//   Future<Uint8List> _convertWordToPdf(
//     Uint8List wordData,
//     String fileName,
//   ) async {
//     // Note: Full Word to PDF conversion requires complex libraries
//     // This is a simplified version that creates a placeholder PDF
//     // For production, you'd need libraries like mammoth or docx_to_text

//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) {
//           return pw.Center(
//             child: pw.Column(
//               mainAxisAlignment: pw.MainAxisAlignment.center,
//               children: [
//                 pw.Icon(pw.IconData(0xe873), size: 48), // Document icon
//                 pw.SizedBox(height: 20),
//                 pw.Text(
//                   'Word Document',
//                   style: pw.TextStyle(
//                     fontSize: 24,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//                 pw.SizedBox(height: 10),
//                 pw.Text(fileName, style: const pw.TextStyle(fontSize: 16)),
//                 pw.SizedBox(height: 10),
//                 pw.Text(
//                   'Size: ${(wordData.length / 1024).toStringAsFixed(1)} KB',
//                   style: const pw.TextStyle(fontSize: 12),
//                 ),
//                 pw.SizedBox(height: 20),
//                 pw.Container(
//                   padding: const pw.EdgeInsets.all(16),
//                   decoration: pw.BoxDecoration(
//                     border: pw.Border.all(color: PdfColors.grey),
//                     borderRadius: pw.BorderRadius.circular(8),
//                   ),
//                   child: pw.Text(
//                     'Word document content would be displayed here.\n'
//                     'For full Word support, additional libraries are needed.',
//                     textAlign: pw.TextAlign.center,
//                     style: const pw.TextStyle(fontSize: 10),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );

//     return await pdf.save();
//   }

//   Future<Uint8List> _createUnsupportedFilePdf(
//     String fileName,
//     String extension,
//   ) async {
//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) {
//           return pw.Center(
//             child: pw.Column(
//               mainAxisAlignment: pw.MainAxisAlignment.center,
//               children: [
//                 pw.Icon(pw.IconData(0xe873), size: 48),
//                 pw.SizedBox(height: 20),
//                 pw.Text(
//                   'Unsupported File Type',
//                   style: pw.TextStyle(
//                     fontSize: 24,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.red,
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),
//                 pw.Text('File: $fileName'),
//                 pw.Text('Type: ${extension.toUpperCase()}'),
//                 pw.SizedBox(height: 20),
//                 pw.Text(
//                   'This file type is not supported for printing.',
//                   style: const pw.TextStyle(fontSize: 12),
//                 ),
//                 pw.Text(
//                   'Supported types: PDF, PNG, JPG, TXT, DOC, DOCX',
//                   style: const pw.TextStyle(fontSize: 10),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );

//     return await pdf.save();
//   }

//   Future<Uint8List> _createErrorPdf(String fileName, String error) async {
//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) {
//           return pw.Center(
//             child: pw.Column(
//               mainAxisAlignment: pw.MainAxisAlignment.center,
//               children: [
//                 pw.Text(
//                   'Print Error',
//                   style: pw.TextStyle(
//                     fontSize: 24,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.red,
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),
//                 pw.Text('File: $fileName'),
//                 pw.SizedBox(height: 10),
//                 pw.Text(
//                   'Error: $error',
//                   style: const pw.TextStyle(fontSize: 12),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );

//     return await pdf.save();
//   }

//   Future<Uint8List?> _downloadAndDecryptFile(PrintJob job) async {
//     try {
//       // Download the encrypted file from the URL
//       final response = await http.get(Uri.parse(job.encryptedFileUrl));

//       if (response.statusCode != 200) {
//         throw Exception('Failed to download file: ${response.statusCode}');
//       }

//       final encryptedBytes = response.bodyBytes;

//       // Decrypt the file using the stored encryption key
//       final decryptedBytes = _decryptFile(encryptedBytes, job.encryptionKey);

//       return decryptedBytes;
//     } catch (e) {
//       print('Error downloading/decrypting file: $e');
//       return null;
//     }
//   }

//   Uint8List _decryptFile(Uint8List encryptedData, String key) {
//     var keyBytes = utf8.encode(key);

//     // Reverse the XOR encryption (same operation since XOR is reversible)
//     List<int> decrypted = [];
//     for (int i = 0; i < encryptedData.length; i++) {
//       decrypted.add(encryptedData[i] ^ keyBytes[i % keyBytes.length]);
//     }

//     return Uint8List.fromList(decrypted);
//   }

//   Future<void> _updateJobStatus(String jobId, String status) async {
//     if (_idToken == null) return;

//     try {
//       await http.patch(
//         Uri.parse(
//           'https://firestore.googleapis.com/v1/projects/$_firebaseProjectId/databases/(default)/documents/printJobs/$jobId'
//           '?access_token=$_idToken',
//         ),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'fields': {
//             'status': {'stringValue': status},
//             'completedAt': {'stringValue': DateTime.now().toIso8601String()},
//           },
//         }),
//       );
//     } catch (e) {
//       print('Error updating job status: $e');
//     }
//   }

//   Future<void> _logout() async {
//     _pollingTimer?.cancel();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();

//     if (mounted) {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//       );
//     }
//   }

//   void _toggleQrCode() {
//     setState(() {
//       _showQrCode = !_showQrCode;
//     });
//   }

//   Future<void> _regenerateQrCode() async {
//     if (_cafeId == null) return;

//     final shouldRegenerate = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Regenerate QR Code'),
//         content: const Text(
//           'This will create a new Café ID and QR code. The old QR code will stop working. Continue?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Regenerate'),
//           ),
//         ],
//       ),
//     );

//     if (shouldRegenerate == true) {
//       final newCafeId = _generateCafeId();

//       // Update local storage
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('cafe_id', newCafeId);

//       setState(() {
//         _cafeId = newCafeId;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('New Café ID generated: $newCafeId'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   }

//   String _generateCafeId() {
//     const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
//     final random = Random();
//     return List.generate(
//       6,
//       (index) => chars[random.nextInt(chars.length)],
//     ).join();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isInitialized) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$_cafeName${_cafeId != null ? ' - $_cafeId' : ''}'),
//         backgroundColor: Colors.brown[700],
//         foregroundColor: Colors.white,
//         actions: [
//           if (_cafeId != null)
//             IconButton(
//               icon: const Icon(Icons.qr_code),
//               onPressed: _toggleQrCode,
//               tooltip: 'Show/Hide QR Code',
//             ),
//           if (_cafeId != null)
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: _regenerateQrCode,
//               tooltip: 'Regenerate QR Code',
//             ),
//           IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // QR Code Section
//             if (_showQrCode && _cafeId != null)
//               Card(
//                 margin: const EdgeInsets.only(bottom: 16),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'Customer QR Code',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.close),
//                             onPressed: _toggleQrCode,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.grey[300]!),
//                             ),
//                             child: QrImageView(
//                               data: _cafeId!,
//                               version: QrVersions.auto,
//                               size: 200.0,
//                               backgroundColor: Colors.white,
//                             ),
//                           ),
//                           const SizedBox(width: 24),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Café ID: $_cafeId',
//                                   style: const TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                     fontFamily: 'monospace',
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   'Name: $_cafeName',
//                                   style: const TextStyle(fontSize: 16),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 const Text(
//                                   'Instructions for customers:',
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 const Text(
//                                   '1. Scan this QR code with your phone\n'
//                                   '2. Upload your documents\n'
//                                   '3. Your files will print automatically',
//                                   style: TextStyle(fontSize: 14),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//             // Status Card
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     Icon(Icons.print, size: 40, color: Colors.brown[700]),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Print Queue Status',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             '${_printJobs.length} jobs pending',
//                             style: TextStyle(color: Colors.grey[600]),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       width: 12,
//                       height: 12,
//                       decoration: BoxDecoration(
//                         color: _printJobs.isEmpty
//                             ? Colors.green
//                             : Colors.orange,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Jobs List
//             const Text(
//               'Pending Print Jobs',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),

//             Expanded(
//               child: _printJobs.isEmpty
//                   ? const Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.print_disabled,
//                             size: 64,
//                             color: Colors.grey,
//                           ),
//                           SizedBox(height: 16),
//                           Text(
//                             'No pending print jobs',
//                             style: TextStyle(fontSize: 18, color: Colors.grey),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             'Jobs will appear here when customers upload files',
//                             style: TextStyle(color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     )
//                   : ListView.builder(
//                       itemCount: _printJobs.length,
//                       itemBuilder: (context, index) {
//                         final job = _printJobs[index];
//                         return Card(
//                           margin: const EdgeInsets.only(bottom: 8),
//                           child: ListTile(
//                             leading: const Icon(Icons.description),
//                             title: Text(job.fileName),
//                             subtitle: Text(
//                               'Size: ${(job.fileSize / 1024).toStringAsFixed(1)} KB\n'
//                               'Uploaded: ${job.uploadedAt}',
//                             ),
//                             trailing: const SpinKitWave(
//                               color: Colors.brown,
//                               size: 20,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class PrintJob {
//   final String id;
//   final String fileName;
//   final int fileSize;
//   final String uploadedAt;
//   final String encryptedFileUrl; // Add this
//   final String encryptionKey; // Add this

//   PrintJob({
//     required this.id,
//     required this.fileName,
//     required this.fileSize,
//     required this.uploadedAt,
//     required this.encryptedFileUrl, // Add this
//     required this.encryptionKey, // Add this
//   });

//   static PrintJob fromFirestore(Map<String, dynamic> doc) {
//     final fields = doc['fields'] as Map<String, dynamic>;
//     final id = doc['name'].toString().split('/').last;

//     return PrintJob(
//       id: id,
//       fileName: fields['fileName']?['stringValue'] ?? 'Unknown',
//       fileSize: int.tryParse(fields['fileSize']?['integerValue'] ?? '0') ?? 0,
//       uploadedAt: fields['uploadedAt']?['stringValue'] ?? '',
//       encryptedFileUrl:
//           fields['encryptedFileUrl']?['stringValue'] ?? '', // Add this
//       encryptionKey: fields['encryptionKey']?['stringValue'] ?? '', // Add this
//     );
//   }
// }
