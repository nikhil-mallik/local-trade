import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../services/transfer_service.dart';
import 'qr_scanner_screen.dart';
import 'qr_display_screen.dart';

class TransferScreen extends StatelessWidget {
  final TransferService transferService = Get.put(TransferService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Transfer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTransferCard(
              title: 'Send Data',
              description: 'Share files with another device',
              icon: Icons.upload,
              onTap: () => _handleSendData(),
            ),
            const SizedBox(height: 16),
            _buildTransferCard(
              title: 'Receive Data',
              description: 'Receive files from another device',
              onTap: () => _handleReceiveData(),
              icon: Icons.download,
            ),
            const SizedBox(height: 24),
            Obx(() {
              final transfer = transferService.currentTransfer.value;
              if (transfer == null) {
                return const SizedBox.shrink();
              }
              
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Transfer',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: transfer.totalBytes > 0
                            ? transfer.bytesTransferred / transfer.totalBytes
                            : 0,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(transfer.bytesTransferred / 1024).toStringAsFixed(2)} KB / ${(transfer.totalBytes / 1024).toStringAsFixed(2)} KB',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status: ${transfer.status.capitalizeFirst}',
                        style: TextStyle(
                          color: _getStatusColor(transfer.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (transfer.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Error: ${transfer.errorMessage}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendData() async {
    // Pick a file
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;
      String fileType = fileName.split('.').last;
      Uint8List fileBytes = await file.readAsBytes();
      
      // Start server and show QR code
      final connectionInfo = await transferService.startServer();
      
      // Show QR code screen
      Get.to(() => QRDisplayScreen(connectionInfo: connectionInfo));
      
      // Wait for connection and then send data
      // This would typically be triggered by a connection event
      // For simplicity, we'll just wait a bit and then send
      await Future.delayed(Duration(seconds: 5));
      
      if (transferService.isServer.value) {
        transferService.sendData(
          fileName: fileName,
          data: fileBytes,
          fileType: fileType,
        );
      }
    }
  }

  void _handleReceiveData() {
    // Scan QR code to connect to server
    Get.to(() => QRScannerScreen());
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}