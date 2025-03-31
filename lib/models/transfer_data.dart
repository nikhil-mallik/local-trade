import 'dart:convert';

class ConnectionInfo {
  final String deviceId;
  final String deviceName;
  final String ipAddress;
  final int port;
  final String encryptionKey;

  ConnectionInfo({
    required this.deviceId,
    required this.deviceName,
    required this.ipAddress,
    required this.port,
    required this.encryptionKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'ipAddress': ipAddress,
      'port': port,
      'encryptionKey': encryptionKey,
    };
  }

  factory ConnectionInfo.fromJson(Map<String, dynamic> json) {
    return ConnectionInfo(
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      ipAddress: json['ipAddress'],
      port: json['port'],
      encryptionKey: json['encryptionKey'],
    );
  }
}

class TransferMetadata {
  final String id;
  final String fileName;
  final int fileSize;
  final String fileType;
  final String checksum;
  final DateTime timestamp;
  final bool isEncrypted;

  TransferMetadata({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
    required this.checksum,
    required this.timestamp,
    required this.isEncrypted,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileType': fileType,
      'checksum': checksum,
      'timestamp': timestamp.toIso8601String(),
      'isEncrypted': isEncrypted,
    };
  }

  factory TransferMetadata.fromJson(Map<String, dynamic> json) {
    return TransferMetadata(
      id: json['id'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      fileType: json['fileType'],
      checksum: json['checksum'],
      timestamp: DateTime.parse(json['timestamp']),
      isEncrypted: json['isEncrypted'],
    );
  }
}

class TransferProgress {
  final String transferId;
  final int bytesTransferred;
  final int totalBytes;
  final String status; // pending, in_progress, completed, failed
  final String? errorMessage;

  TransferProgress({
    required this.transferId,
    required this.bytesTransferred,
    required this.totalBytes,
    required this.status,
    this.errorMessage,
  });
}