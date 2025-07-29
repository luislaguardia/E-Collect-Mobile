import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRContent extends StatefulWidget {
  const QRContent({super.key});

  @override
  State<QRContent> createState() => _QRContentState();
}

class _QRContentState extends State<QRContent> {
  bool qrDetected = false;
  String? barcodeValue;

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

        if (qrDetected)
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Success',
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
          ),

        if (barcodeValue != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Barcode Value: $barcodeValue',
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
                        final String scannedValue =
                            barcodes.first.rawValue ?? "";

                        setState(() {
                          qrDetected = true;
                          barcodeValue = scannedValue;
                        });

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Center(
                                child: Text(
                                  'Barcode value:',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    scannedValue.isNotEmpty
                                        ? scannedValue
                                        : 'No value detected',
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  if (image != null)
                                    Image(image: MemoryImage(image)),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ),

                SvgPicture.asset(
                  'assets/cameraFrame.svg',
                  width: 325,
                  height: 325,
                  color: qrDetected ? Color(0xff92d400) : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
