// import 'package:deskprint/screens/login_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// //import 'package:crypto/crypto.dart';
// import 'package:pdf/pdf.dart';
// import 'package:printing/printing.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// //import 'package:qr_flutter/qr_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'dart:math';
// import 'dart:async';
// import 'package:image/image.dart' as img;

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
//   //bool _showQrCode = false;
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

//   // Future<void> _processJob(PrintJob job) async {
//   //   try {
//   //     // Update status to printing
//   //     await _updateJobStatus(job.id, 'printing');

//   //     // Download and decrypt the actual file
//   //     final actualFileData = await _downloadAndDecryptFile(job);

//   //     if (actualFileData != null) {
//   //       // Convert file to PDF based on file type and print directly
//   //       await _printFileDirectlyWithFiltering(
//   //         actualFileData,
//   //         job.fileName,
//   //         job.id,
//   //       );

//   //       // Update status to completed
//   //       await _updateJobStatus(job.id, 'completed');
//   //     } else {
//   //       throw Exception('Failed to download or decrypt file');
//   //     }

//   //     // Remove from local list
//   //     setState(() {
//   //       _printJobs.removeWhere((j) => j.id == job.id);
//   //     });
//   //   } catch (e) {
//   //     await _updateJobStatus(job.id, 'failed');
//   //     print('Error processing job: $e');
//   //   }
//   // }

//   Future<void> _processJob(PrintJob job) async {
//     try {
//       // Show confirmation dialog before processing
//       final shouldPrint = await _showPrintConfirmationDialog(job);

//       if (!shouldPrint) {
//         // If user cancels, update status to cancelled
//         await _updateJobStatus(job.id, 'cancelled');
//         setState(() {
//           _printJobs.removeWhere((j) => j.id == job.id);
//         });
//         return;
//       }

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

//   Future<bool> _showPrintConfirmationDialog(PrintJob job) async {
//     // Estimate pages (rough calculation)
//     final estimatedPages = _estimatePages(job.fileSize, job.fileName);

//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) => AlertDialog(
//             title: const Text('New Print Job'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Job #${_printJobs.indexOf(job) + 1}'),
//                 const SizedBox(height: 12),
//                 _buildInfoRow('File:', job.fileName),
//                 _buildInfoRow(
//                   'Size:',
//                   '${(job.fileSize / 1024).toStringAsFixed(1)} KB',
//                 ),
//                 _buildInfoRow('Estimated Pages:', estimatedPages.toString()),
//                 _buildInfoRow('Sender:', job.userName ?? 'Unknown'),
//                 _buildInfoRow('Phone:', job.userPhone ?? 'Not provided'),
//                 _buildInfoRow('Uploaded:', job.uploadedAt),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.brown[700],
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text('Continue to Print'),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }

//   int _estimatePages(int fileSize, String fileName) {
//     final extension = fileName.toLowerCase().split('.').last;

//     switch (extension) {
//       case 'pdf':
//         return (fileSize / 50000).ceil(); // Rough estimate for PDF
//       case 'txt':
//         return (fileSize / 2000).ceil(); // Rough estimate for text
//       case 'doc':
//       case 'docx':
//         return (fileSize / 25000).ceil(); // Rough estimate for Word docs
//       case 'png':
//       case 'jpg':
//       case 'jpeg':
//         return 1; // Images are typically 1 page
//       default:
//         return (fileSize / 30000).ceil(); // Default estimate
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

//   // // Replace your _printWithRestrictedSave method with this fixed version:
//   // Future<void> _printWithRestrictedSave(
//   //   Uint8List pdfData,
//   //   String fileName,
//   // ) async {
//   //   // FIX 2: Remove the unsupported 'actions' parameter
//   //   await Printing.layoutPdf(
//   //     onLayout: (format) => pdfData,
//   //     name: fileName,
//   //     format: PdfPageFormat.a4,
//   //     // Remove the 'actions' parameter as it's not supported
//   //     // The printing package doesn't support restricting actions in this way
//   //   );
//   // }

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

//   // void _toggleQrCode() {
//   //   setState(() {
//   //     _showQrCode = !_showQrCode;
//   //   });
//   // }

//   // Future<void> _regenerateQrCode() async {
//   //   if (_cafeId == null) return;

//   //   final shouldRegenerate = await showDialog<bool>(
//   //     context: context,
//   //     builder: (context) => AlertDialog(
//   //       title: const Text('Regenerate QR Code'),
//   //       content: const Text(
//   //         'This will create a new Café ID and QR code. The old QR code will stop working. Continue?',
//   //       ),
//   //       actions: [
//   //         TextButton(
//   //           onPressed: () => Navigator.pop(context, false),
//   //           child: const Text('Cancel'),
//   //         ),
//   //         TextButton(
//   //           onPressed: () => Navigator.pop(context, true),
//   //           child: const Text('Regenerate'),
//   //         ),
//   //       ],
//   //     ),
//   //   );

//   //   if (shouldRegenerate == true) {
//   //     final newCafeId = _generateCafeId();

//   //     // Update local storage
//   //     final prefs = await SharedPreferences.getInstance();
//   //     await prefs.setString('cafe_id', newCafeId);

//   //     setState(() {
//   //       _cafeId = newCafeId;
//   //     });

//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Text('New Café ID generated: $newCafeId'),
//   //         backgroundColor: Colors.green,
//   //       ),
//   //     );
//   //   }
//   // }

//   // String _generateCafeId() {
//   //   const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
//   //   final random = Random();
//   //   return List.generate(
//   //     6,
//   //     (index) => chars[random.nextInt(chars.length)],
//   //   ).join();
//   // }

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
//           // if (_cafeId != null)
//           //   IconButton(
//           //     icon: const Icon(Icons.qr_code),
//           //     onPressed: _toggleQrCode,
//           //     tooltip: 'Show/Hide QR Code',
//           //   ),
//           // if (_cafeId != null)
//           //   IconButton(
//           //     icon: const Icon(Icons.refresh),
//           //     onPressed: _regenerateQrCode,
//           //     tooltip: 'Regenerate QR Code',
//           //   ),
//           IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // QR Code Section
//             // if (_showQrCode && _cafeId != null)
//             if (_cafeId != null)
//               Card(
//                 margin: const EdgeInsets.only(bottom: 16),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       // Row(
//                       //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       //   children: [
//                       //     const Text(
//                       //       'Customer QR Code',
//                       //       style: TextStyle(
//                       //         fontSize: 18,
//                       //         fontWeight: FontWeight.bold,
//                       //       ),
//                       //     ),
//                       //     IconButton(
//                       //       icon: const Icon(Icons.close),
//                       //       onPressed: _toggleQrCode,
//                       //     ),
//                       //   ],
//                       // ),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           // Container(
//                           //   padding: const EdgeInsets.all(16),
//                           //   decoration: BoxDecoration(
//                           //     color: Colors.white,
//                           //     borderRadius: BorderRadius.circular(8),
//                           //     border: Border.all(color: Colors.grey[300]!),
//                           //   ),
//                           //   child: QrImageView(
//                           //     data: _cafeId!,
//                           //     version: QrVersions.auto,
//                           //     size: 200.0,
//                           //     backgroundColor: Colors.white,
//                           //   ),
//                           // ),
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
//   final String? userName; // Add this
//   final String? userPhone;

//   PrintJob({
//     required this.id,
//     required this.fileName,
//     required this.fileSize,
//     required this.uploadedAt,
//     required this.encryptedFileUrl, // Add this
//     required this.encryptionKey, // Add this
//     this.userName, // Add this
//     this.userPhone, // Add this
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
//       userName: fields['userName']?['stringValue'], // Add this
//       userPhone: fields['userPhone']?['stringValue'], // Add this
//     );
//   }
// }

import 'package:deskprint/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'dart:async';
import 'package:image/image.dart' as img;

class PrintingDashboard extends StatefulWidget {
  const PrintingDashboard({super.key});

  @override
  State<PrintingDashboard> createState() => _PrintingDashboardState();
}

class _PrintingDashboardState extends State<PrintingDashboard> {
  String? _cafeId;
  String? _cafeName;
  String? _idToken;
  List<PrintJob> _printJobs = [];
  bool _isInitialized = false;
  Timer? _pollingTimer;
  Set<String> _processingJobs = {};

  // Firebase configuration
  final String _firebaseProjectId = 'creatingmyapp-defa0';

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    _cafeId = prefs.getString('cafe_id');
    _cafeName = prefs.getString('cafe_name');
    _idToken = prefs.getString('id_token');

    if (_cafeId != null) {
      _startPollingForJobs();
    }

    setState(() {
      _isInitialized = true;
    });
  }

  void _startPollingForJobs() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchPrintJobs();
    });
    _fetchPrintJobs(); // Initial fetch
  }

  Future<void> _fetchPrintJobs() async {
    if (_cafeId == null || _idToken == null) return;

    try {
      final response = await http.get(
        Uri.parse(
          'https://firestore.googleapis.com/v1/projects/$_firebaseProjectId/databases/(default)/documents/printJobs'
          '?access_token=$_idToken'
          '&orderBy=uploadedAt desc',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data['documents'] as List<dynamic>? ?? [];

        final jobs = documents
            .where((doc) {
              final fields = doc['fields'] as Map<String, dynamic>? ?? {};
              final cafeId = fields['cafeId']?['stringValue'];
              final status = fields['status']?['stringValue'];
              return cafeId == _cafeId && status == 'pending';
            })
            .map((doc) => PrintJob.fromFirestore(doc))
            .toList();

        setState(() {
          _printJobs = jobs;
        });
      }
    } catch (e) {
      print('Error fetching jobs: $e');
    }
  }

  Future<void> _printJob(PrintJob job) async {
    setState(() {
      _processingJobs.add(job.id);
    });

    try {
      // Update status to printing
      await _updateJobStatus(job.id, 'printing');

      // Download and decrypt the actual file
      final actualFileData = await _downloadAndDecryptFile(job);

      if (actualFileData != null) {
        // Convert file to PDF based on file type and print directly
        await _printFileDirectlyWithFiltering(
          actualFileData,
          job.fileName,
          job.id,
        );

        // Update status to completed
        await _updateJobStatus(job.id, 'completed');

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully printed: ${job.fileName}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception('Failed to download or decrypt file');
      }

      // Remove from local list
      setState(() {
        _printJobs.removeWhere((j) => j.id == job.id);
        _processingJobs.remove(job.id);
      });
    } catch (e) {
      await _updateJobStatus(job.id, 'failed');
      setState(() {
        _processingJobs.remove(job.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print: ${job.fileName}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      print('Error processing job: $e');
    }
  }

  Future<void> _rejectJob(PrintJob job) async {
    final shouldReject = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Print Job'),
        content: Text('Are you sure you want to reject "${job.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (shouldReject == true) {
      await _updateJobStatus(job.id, 'rejected');
      setState(() {
        _printJobs.removeWhere((j) => j.id == job.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rejected: ${job.fileName}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  int _estimatePages(int fileSize, String fileName) {
    final extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      case 'pdf':
        return (fileSize / 50000).ceil();
      case 'txt':
        return (fileSize / 2000).ceil();
      case 'doc':
      case 'docx':
        return (fileSize / 25000).ceil();
      case 'png':
      case 'jpg':
      case 'jpeg':
        return 1;
      default:
        return (fileSize / 30000).ceil();
    }
  }

  String _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return '📄';
      case 'txt':
        return '📝';
      case 'doc':
      case 'docx':
        return '📃';
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'bmp':
        return '🖼️';
      default:
        return '📎';
    }
  }

  Widget _buildJobsTable() {
    if (_printJobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.print_disabled, size: 80, color: Colors.grey),
            SizedBox(height: 24),
            Text(
              'No pending print jobs',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Jobs will appear here when customers upload files',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.brown[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.queue, color: Colors.brown[700], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Print Queue',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_printJobs.length} pending',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
              columns: const [
                DataColumn(
                  label: Text(
                    '#',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'File',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Size',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Pages',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Customer',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Phone',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Uploaded',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: _printJobs.asMap().entries.map((entry) {
                final index = entry.key;
                final job = entry.value;
                final isProcessing = _processingJobs.contains(job.id);
                final estimatedPages = _estimatePages(
                  job.fileSize,
                  job.fileName,
                );

                return DataRow(
                  color: MaterialStateProperty.all(
                    isProcessing ? Colors.blue[50] : null,
                  ),
                  cells: [
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.brown[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[800],
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getFileIcon(job.fileName),
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  job.fileName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  job.fileName.split('.').last.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text('${(job.fileSize / 1024).toStringAsFixed(1)} KB'),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: estimatedPages <= 5
                              ? Colors.green[100]
                              : Colors.orange[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$estimatedPages',
                          style: TextStyle(
                            color: estimatedPages <= 5
                                ? Colors.green[800]
                                : Colors.orange[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        job.userName ?? 'Unknown',
                        style: TextStyle(
                          color: job.userName != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        job.userPhone ?? 'Not provided',
                        style: TextStyle(
                          color: job.userPhone != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatUploadTime(job.uploadedAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    DataCell(
                      isProcessing
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SpinKitWave(color: Colors.blue, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Printing...',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _printJob(job),
                                  icon: const Icon(Icons.print, size: 16),
                                  label: const Text('Print'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    minimumSize: Size.zero,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () => _rejectJob(job),
                                  icon: const Icon(Icons.close, size: 16),
                                  label: const Text('Reject'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    minimumSize: Size.zero,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatUploadTime(String uploadedAt) {
    try {
      final uploadTime = DateTime.parse(uploadedAt);
      final now = DateTime.now();
      final difference = now.difference(uploadTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return uploadedAt;
    }
  }

  // Keep all your existing methods for printing, encryption, etc.
  Future<void> _printFileDirectlyWithFiltering(
    Uint8List fileData,
    String fileName,
    String job,
  ) async {
    try {
      final String extension = fileName.toLowerCase().split('.').last;
      Uint8List pdfData;

      switch (extension) {
        case 'pdf':
          pdfData = fileData;
          break;
        case 'png':
        case 'jpg':
        case 'jpeg':
        case 'gif':
        case 'bmp':
          pdfData = await _convertImageToPdf(fileData, fileName);
          break;
        case 'doc':
        case 'docx':
          pdfData = await _convertWordToPdf(fileData, fileName);
          break;
        case 'txt':
          pdfData = await _convertTextToPdf(fileData, fileName);
          break;
        default:
          pdfData = await _createUnsupportedFilePdf(fileName, extension);
      }

      final physicalPrinter = await _selectPhysicalPrinter();

      if (physicalPrinter != null) {
        await Printing.directPrintPdf(
          printer: physicalPrinter,
          onLayout: (format) => pdfData,
          name: fileName,
          usePrinterSettings: true,
        );
      } else {
        throw Exception('No physical printer available');
      }
    } catch (e) {
      print('Error printing file: $e');
      await _updateJobStatus(job, 'failed');
    }
  }

  Future<Printer?> _selectPhysicalPrinter() async {
    try {
      final allPrinters = await Printing.listPrinters();

      final physicalPrinters = allPrinters.where((printer) {
        final name = printer.name.toLowerCase();

        final virtualPrinterKeywords = [
          'microsoft print to pdf',
          'microsoft xps document writer',
          'print to pdf',
          'pdf printer',
          'foxit pdf printer',
          'adobe pdf',
          'cutepdf writer',
          'doro pdf writer',
          'fax',
          'onenote',
          'xps',
        ];

        for (final keyword in virtualPrinterKeywords) {
          if (name.contains(keyword)) {
            return false;
          }
        }

        return true;
      }).toList();

      if (physicalPrinters.isEmpty) {
        throw Exception('No physical printers found');
      }

      if (physicalPrinters.length == 1) {
        return physicalPrinters.first;
      }

      return await _showPrinterSelectionDialog(physicalPrinters);
    } catch (e) {
      print('Error selecting physical printer: $e');
      return null;
    }
  }

  Future<Printer?> _showPrinterSelectionDialog(List<Printer> printers) async {
    return await showDialog<Printer>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Printer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose a physical printer:'),
            const SizedBox(height: 16),
            ...printers.map(
              (printer) => ListTile(
                title: Text(printer.name),
                onTap: () => Navigator.pop(context, printer),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Keep all your existing conversion methods
  Future<Uint8List> _convertImageToPdf(
    Uint8List imageData,
    String fileName,
  ) async {
    final pdf = pw.Document();

    try {
      final image = img.decodeImage(imageData);
      if (image == null) throw Exception('Invalid image format');

      final pngBytes = img.encodePng(image);
      final pdfImage = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(pdfImage, fit: pw.BoxFit.contain));
          },
        ),
      );
    } catch (e) {
      return await _createErrorPdf(fileName, 'Image conversion failed: $e');
    }

    return await pdf.save();
  }

  Future<Uint8List> _convertTextToPdf(
    Uint8List textData,
    String fileName,
  ) async {
    final pdf = pw.Document();

    try {
      final text = utf8.decode(textData);

      const int maxLinesPerPage = 50;
      const int maxCharsPerLine = 80;

      final lines = text.split('\n');
      final pages = <List<String>>[];

      for (int i = 0; i < lines.length; i += maxLinesPerPage) {
        final pageLines = lines.skip(i).take(maxLinesPerPage).toList();
        pages.add(pageLines);
      }

      for (final pageLines in pages) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    fileName,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  ...pageLines.map(
                    (line) => pw.Text(
                      line.length > maxCharsPerLine
                          ? line.substring(0, maxCharsPerLine) + '...'
                          : line,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
    } catch (e) {
      return await _createErrorPdf(fileName, 'Text conversion failed: $e');
    }

    return await pdf.save();
  }

  Future<Uint8List> _convertWordToPdf(
    Uint8List wordData,
    String fileName,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Icon(pw.IconData(0xe873), size: 48),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Word Document',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(fileName, style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Size: ${(wordData.length / 1024).toStringAsFixed(1)} KB',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'Word document content would be displayed here.\n'
                    'For full Word support, additional libraries are needed.',
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return await pdf.save();
  }

  Future<Uint8List> _createUnsupportedFilePdf(
    String fileName,
    String extension,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Icon(pw.IconData(0xe873), size: 48),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Unsupported File Type',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('File: $fileName'),
                pw.Text('Type: ${extension.toUpperCase()}'),
                pw.SizedBox(height: 20),
                pw.Text(
                  'This file type is not supported for printing.',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'Supported types: PDF, PNG, JPG, TXT, DOC, DOCX',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );

    return await pdf.save();
  }

  Future<Uint8List> _createErrorPdf(String fileName, String error) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Print Error',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('File: $fileName'),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Error: $error',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );

    return await pdf.save();
  }

  Future<Uint8List?> _downloadAndDecryptFile(PrintJob job) async {
    try {
      final response = await http.get(Uri.parse(job.encryptedFileUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to download file: ${response.statusCode}');
      }

      final encryptedBytes = response.bodyBytes;
      final decryptedBytes = _decryptFile(encryptedBytes, job.encryptionKey);

      return decryptedBytes;
    } catch (e) {
      print('Error downloading/decrypting file: $e');
      return null;
    }
  }

  Uint8List _decryptFile(Uint8List encryptedData, String key) {
    var keyBytes = utf8.encode(key);

    List<int> decrypted = [];
    for (int i = 0; i < encryptedData.length; i++) {
      decrypted.add(encryptedData[i] ^ keyBytes[i % keyBytes.length]);
    }

    return Uint8List.fromList(decrypted);
  }

  Future<void> _updateJobStatus(String jobId, String status) async {
    if (_idToken == null) return;

    try {
      await http.patch(
        Uri.parse(
          'https://firestore.googleapis.com/v1/projects/$_firebaseProjectId/databases/(default)/documents/printJobs/$jobId'
          '?access_token=$_idToken',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fields': {
            'status': {'stringValue': status},
            'completedAt': {'stringValue': DateTime.now().toIso8601String()},
          },
        }),
      );
    } catch (e) {
      print('Error updating job status: $e');
    }
  }

  Future<void> _logout() async {
    _pollingTimer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$_cafeName${_cafeId != null ? ' - $_cafeId' : ''}'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPrintJobs,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.brown[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.brown[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.store,
                        color: Colors.brown[700],
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _cafeName ?? 'Print Dashboard',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cafe ID: ${_cafeId ?? 'Not set'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _printJobs.isEmpty
                            ? Colors.green[100]
                            : Colors.orange[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _printJobs.isEmpty
                                ? Icons.check_circle
                                : Icons.pending,
                            size: 16,
                            color: _printJobs.isEmpty
                                ? Colors.green[700]
                                : Colors.orange[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _printJobs.isEmpty
                                ? 'All Clear'
                                : '${_printJobs.length} Pending',
                            style: TextStyle(
                              color: _printJobs.isEmpty
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Jobs Table
              Expanded(child: _buildJobsTable()),
            ],
          ),
        ),
      ),
    );
  }
}

// PrintJob model class
class PrintJob {
  final String id;
  final String fileName;
  final int fileSize;
  final String encryptedFileUrl;
  final String encryptionKey;
  final String uploadedAt;
  final String? userName;
  final String? userPhone;

  PrintJob({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.encryptedFileUrl,
    required this.encryptionKey,
    required this.uploadedAt,
    this.userName,
    this.userPhone,
  });

  factory PrintJob.fromFirestore(Map<String, dynamic> doc) {
    final fields = doc['fields'] as Map<String, dynamic>;
    final name = doc['name'] as String;
    final id = name.split('/').last;

    return PrintJob(
      id: id,
      fileName: fields['fileName']?['stringValue'] ?? 'Unknown',
      fileSize: int.tryParse(fields['fileSize']?['integerValue'] ?? '0') ?? 0,
      encryptedFileUrl: fields['encryptedFileUrl']?['stringValue'] ?? '',
      encryptionKey: fields['encryptionKey']?['stringValue'] ?? '',
      uploadedAt: fields['uploadedAt']?['stringValue'] ?? '',
      userName: fields['userName']?['stringValue'],
      userPhone: fields['userPhone']?['stringValue'],
    );
  }
}
