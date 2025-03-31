import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:uuid/uuid.dart';
import '../models/transfer_data.dart';

class TransferService extends GetxController {
  // Socket server for TCP transfers
  ServerSocket? _server;
  io.Socket? _clientSocket;
  
  // Transfer state
  final Rx<TransferProgress?> currentTransfer = Rx<TransferProgress?>(null);
  final RxBool isTransferring = false.obs;
  final RxBool isServer = false.obs;
  
  // Encryption key
  encrypt.Key? encryptionKey;
  
  // Start server for incoming transfers
  Future<ConnectionInfo> startServer() async {
    isServer.value = true;
    final deviceId = const Uuid().v4();
    final deviceName = Platform.localHostname;
    
    // Generate encryption key
    encryptionKey = generateKey();
    final keyString = base64.encode(encryptionKey!.bytes);
    
    // Start TCP server
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    final port = _server!.port;
    
    _server!.listen((socket) {
      _handleIncomingConnection(socket);
    });
    
    return ConnectionInfo(
      deviceId: deviceId,
      deviceName: deviceName,
      ipAddress: await _getLocalIpAddress(),
      port: port,
      encryptionKey: keyString,
    );
  }
  
  // Connect to server using connection info from QR
  Future<bool> connectToServer(ConnectionInfo info) async {
    isServer.value = false;
    
    // Set encryption key
    encryptionKey = encrypt.Key(base64.decode(info.encryptionKey));
    
    try {
      _clientSocket = io.io('http://${info.ipAddress}:${info.port}', 
          io.OptionBuilder().setTransports(['websocket']).build());
      
      _clientSocket!.onConnect((_) {
        print('Connected to server');
      });
      
      _clientSocket!.onDisconnect((_) {
        print('Disconnected from server');
      });
      
      return true;
    } catch (e) {
      print('Error connecting to server: $e');
      return false;
    }
  }
  
  // Send data to connected peer
  Future<bool> sendData({
    required String fileName,
    required Uint8List data,
    required String fileType,
  }) async {
    if (encryptionKey == null) {
      print('Encryption key not set');
      return false;
    }
    
    isTransferring.value = true;
    final transferId = const Uuid().v4();
    
    // Create progress tracker
    currentTransfer.value = TransferProgress(
      transferId: transferId,
      bytesTransferred: 0,
      totalBytes: data.length,
      status: 'pending',
    );
    
    // Encrypt data
    final encryptedData = encryptFile(data, encryptionKey!);
    final checksum = calculateChecksum(data);
    
    // Create metadata
    final metadata = TransferMetadata(
      id: transferId,
      fileName: fileName,
      fileSize: data.length,
      fileType: fileType,
      checksum: checksum,
      timestamp: DateTime.now(),
      isEncrypted: true,
    );
    
    if (_clientSocket != null) {
      // TCP transfer
      try {
        // Send metadata first
        _clientSocket!.emit('metadata', metadata.toJson());
        
        // Send data in chunks
        const chunkSize = 1024 * 16; // 16KB chunks
        int offset = 0;
        
        while (offset < encryptedData.length) {
          final end = (offset + chunkSize) > encryptedData.length 
              ? encryptedData.length 
              : offset + chunkSize;
          
          final chunk = encryptedData.sublist(offset, end);
          _clientSocket!.emit('data', {
            'transferId': transferId,
            'chunk': base64.encode(chunk),
            'offset': offset,
          });
          
          offset = end;
          
          // Update progress
          currentTransfer.value = TransferProgress(
            transferId: transferId,
            bytesTransferred: offset,
            totalBytes: encryptedData.length,
            status: 'in_progress',
          );
          
          // Simulate network delay for demonstration
          await Future.delayed(const Duration(milliseconds: 100));
        }
        
        // Finalize transfer
        _clientSocket!.emit('complete', {'transferId': transferId});
        
        currentTransfer.value = TransferProgress(
          transferId: transferId,
          bytesTransferred: encryptedData.length,
          totalBytes: encryptedData.length,
          status: 'completed',
        );
        
        isTransferring.value = false;
        return true;
      } catch (e) {
        print('Error during TCP transfer: $e');
        currentTransfer.value = TransferProgress(
          transferId: transferId,
          bytesTransferred: currentTransfer.value?.bytesTransferred ?? 0,
          totalBytes: encryptedData.length,
          status: 'failed',
          errorMessage: e.toString(),
        );
        isTransferring.value = false;
        return false;
      }
    } else {
      print('No connection available');
      isTransferring.value = false;
      return false;
    }
  }
  
  void _handleIncomingConnection(Socket socket) {
    print('Client connected: ${socket.remoteAddress.address}:${socket.remotePort}');
    
    // Handle incoming data
    // Implementation would depend on your protocol
  }
  
  Future<String> _getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      
      // Prefer non-loopback addresses
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback) {
            return addr.address;
          }
        }
      }
      
      // Fall back to loopback if no other address is found
      return '127.0.0.1';
    } catch (e) {
      print('Error getting local IP: $e');
      return '127.0.0.1';
    }
  }
  
  // Encryption helpers
  encrypt.Key generateKey() {
    final key = encrypt.Key.fromSecureRandom(32);
    return key;
  }
  
  Uint8List encryptFile(Uint8List data, encrypt.Key key) {
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    
    // Prepend IV to encrypted data
    final encrypted = encrypter.encryptBytes(data, iv: iv);
    final result = Uint8List(iv.bytes.length + encrypted.bytes.length);
    
    result.setRange(0, iv.bytes.length, iv.bytes);
    result.setRange(iv.bytes.length, result.length, encrypted.bytes);
    
    return result;
  }
  
  String calculateChecksum(Uint8List data) {
    return sha256.convert(data).toString();
  }
  
  @override
  void onClose() {
    _server?.close();
    _clientSocket?.disconnect();
    super.onClose();
  }
}
