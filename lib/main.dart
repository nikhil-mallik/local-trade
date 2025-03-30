import 'package:flutter/material.dart';
import 'package:local_trade/screens/home_screen.dart';
import 'package:local_trade/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:local_trade/providers/auth_provider.dart';
import 'package:local_trade/providers/listing_provider.dart';
import 'package:local_trade/providers/connectivity_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await DatabaseService.database;
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: MaterialApp(
        title: 'LocalTrade',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: true,
      ),
    );
  }
}
