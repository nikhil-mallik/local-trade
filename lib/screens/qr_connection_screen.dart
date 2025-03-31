import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/transfer_data.dart';
import '../services/qr_service.dart';
import '../services/transfer_service.dart';
import 'qr_scanner_screen.dart';
import 'transfer_screen.dart';

class QRConnectionScreen extends StatelessWidget {
  const QRConnectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TransferService transferService = Get.put(TransferService());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Devices'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Share files between devices',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _startServer(context, transferService, 'tcp'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Create Connection (Wi-Fi)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _startServer(context, transferService, 'bluetooth'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Create Connection (Bluetooth)'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _scanQRCode(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Scan QR Code to Connect'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Secure, encrypted file transfer without internet',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startServer(
      BuildContext context, TransferService transferService, String method) async {
    // Request necessary permissions
    if (method == 'bluetooth') {
      final status = await Permission.bluetooth.request();
      if (status.isDenied) {
        Get.snackbar(
          'Permission Denied',
          'Bluetooth permission is required for connection',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    // Show loading dialog
    Get.dialog(
      const AlertDialog(
        title: Text('Starting Server'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing secure connection...'),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Start the server
      final connectionInfo = await transferService.startServer(
        transferMethod: method,
      );

      // Close loading dialog
      Get.back();

      // Show QR code
      Get.to(() => QRDisplayScreen(connectionInfo: connectionInfo));
    } catch (e) {
      // Close loading dialog
      Get.back();

      Get.snackbar(
        'Error',
        'Failed to start server: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _scanQRCode(BuildContext context) {
    Get.to(() => const QRScannerScreen());
  }
}

class QRDisplayScreen extends StatelessWidget {
  final ConnectionInfo connectionInfo;

  const QRDisplayScreen({Key? key, required this.connectionInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection QR Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Scan this QR code with another device',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Center(
              child: QRService.generateConnectionQR(connectionInfo),
            ),
            const SizedBox(height: 32),
            Text(
              'Connection Method: ${connectionInfo.transferMethod.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Device ID: ${connectionInfo.deviceId.substring(0, 8)}...'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Get.off(() => const TransferScreen());
              },
              child: const Text('Continue to Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}