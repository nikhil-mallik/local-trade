import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/transfer_data.dart';
import '../services/transfer_service.dart';

class QRDisplayScreen extends StatelessWidget {
  final ConnectionInfo connectionInfo;
  final TransferService transferService = Get.find<TransferService>();

  QRDisplayScreen({required this.connectionInfo});

  @override
  Widget build(BuildContext context) {
    final jsonData = jsonEncode(connectionInfo.toJson());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Device'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Scan this QR code with the receiver device',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: QrImageView(
                data: jsonData,
                version: QrVersions.auto,
                size: 250,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'IP: ${connectionInfo.ipAddress}:${connectionInfo.port}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 32),
            Obx(() {
              if (transferService.isTransferring.value) {
                return const Text(
                  'Connected! Transfer in progress...',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                );
              }
              return const Text(
                'Waiting for connection...',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}