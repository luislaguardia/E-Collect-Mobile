import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecollect/navContainer.dart';

class QRContent extends StatefulWidget {
  const QRContent({super.key});

  @override
  State<QRContent> createState() => _QRContentState();
}

class _QRContentState extends State<QRContent> {
  bool isScanning = true;
  String? statusMessage;
  bool isSuccess = false;
  bool isLoading = false;
  MobileScannerController? scannerController;

  @override
  void initState() {
    super.initState();
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    scannerController?.dispose();
    super.dispose();
  }

  Future<void> submitScan(String rawValue) async {
    setState(() {
      isLoading = true;
      statusMessage = 'Processing scan...';
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() {
          statusMessage = 'Please log in to continue scanning';
          isSuccess = false;
          isLoading = false;
        });
        return;
      }

      final response = await http.post(
        Uri.parse('https://ecollect-server.onrender.com/api/scan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'qrData': rawValue}),
      );

      final result = jsonDecode(response.body);
      final success = response.statusCode == 200 && result['success'] == true;

      setState(() {
        isSuccess = success;
        statusMessage = success
            ? 'QR Scanned Successfully!'
            : result['message'] ?? 'Scan failed. Please try again.';
        isLoading = false;
      });

      if (success) {
        await Future.delayed(const Duration(seconds: 3));
        _resetScanner();
      }
    } catch (e) {
      setState(() {
        statusMessage =
            'Connection error. Please check your internet and try again.';
        isSuccess = false;
        isLoading = false;
      });
    }
  }

  void _resetScanner() {
    setState(() {
      isScanning = true;
      statusMessage = null;
      isSuccess = false;
      isLoading = false;
    });
  }

  Widget _buildStatusCard() {
    if (statusMessage == null && !isLoading) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
              size: 24,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusMessage ?? '',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 20),
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              'QR Scanner',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
            ),
            centerTitle: true,
          ),

          _buildStatusCard(),

          Expanded(
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isScanning)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: MobileScanner(
                          controller: scannerController,
                          onDetect: (capture) {
                            final List<Barcode> barcodes = capture.barcodes;

                            if (barcodes.isNotEmpty &&
                                isScanning &&
                                !isLoading) {
                              final String scannedValue =
                                  barcodes.first.rawValue ?? "";

                              if (scannedValue.isNotEmpty) {
                                setState(() {
                                  isScanning = false;
                                });
                                submitScan(scannedValue);
                              }
                            }
                          },
                        ),
                      ),

                    SvgPicture.asset(
                      'assets/cameraFrame.svg',
                      width: 325,
                      height: 325,
                      colorFilter: ColorFilter.mode(
                        isSuccess ? const Color(0xff92d400) : Colors.amber,
                        BlendMode.srcIn,
                      ),
                    ),

                    if (isScanning && !isLoading)
                      const Positioned(
                        bottom: 20,
                        child: Text(
                          'Position QR code within the frame',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            backgroundColor: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (!isScanning && !isLoading)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _resetScanner,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Scan Another QR Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NavigationContainer(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.amber),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
