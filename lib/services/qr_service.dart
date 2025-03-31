import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/transfer_data.dart';

class QRService {
  static Widget generateConnectionQR(ConnectionInfo connectionInfo) {
    final jsonData = jsonEncode(connectionInfo.toJson());
    
    return QrImageView(
      data: jsonData,
      version: QrVersions.auto,
      size: 250,
      backgroundColor: Colors.white,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
    );
  }
}