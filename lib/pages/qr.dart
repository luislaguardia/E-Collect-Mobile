import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QRContent extends StatefulWidget {
  const QRContent({super.key});

  @override
  State<QRContent> createState() => _QRContentState();
}

class _QRContentState extends State<QRContent> {
  bool qrDetected = false;
  String? barcodeValue;
  String? responseMessage;
  bool isSuccess = false;

  Future<void> submitScan(String rawValue) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        setState(() {
          responseMessage = 'You must be logged in to scan.';
          isSuccess = false;
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

      setState(() {
        responseMessage = result['message'] ?? 'No response message';
        isSuccess = response.statusCode == 200 && result['success'] == true;
      });
    } catch (e) {
      setState(() {
        responseMessage = 'Error scanning QR: $e';
        isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        AppBar(
          backgroundColor: Colors.white,
          title: const Center(
            child: Text(
              'QR Scanner',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
        if (responseMessage != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              responseMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),
          ),
        if (barcodeValue != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'QR Value: $barcodeValue',
              style: const TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: MobileScanner(
                    controller: MobileScannerController(
                      detectionSpeed: DetectionSpeed.noDuplicates,
                    ),
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      final Uint8List? image = capture.image;

                      if (barcodes.isNotEmpty && !qrDetected) {
                        final String scannedValue = barcodes.first.rawValue ?? "";

                        setState(() {
                          qrDetected = true;
                          barcodeValue = scannedValue;
                          responseMessage = null;
                          isSuccess = false;
                        });

                        submitScan(scannedValue);
                      }
                    },
                  ),
                ),
                SvgPicture.asset(
                  'assets/cameraFrame.svg',
                  width: 325,
                  height: 325,
                  color: qrDetected ? const Color(0xff92d400) : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}