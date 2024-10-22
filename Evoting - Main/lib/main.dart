import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './home_page.dart';
import '../../utils/auth_token.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthToken(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Voting System',
      debugShowCheckedModeBanner: false, // Disables the debug banner
      theme: ThemeData(
        // Define your app-wide theme here
        primarySwatch: Colors.deepPurple,
        buttonTheme: ButtonThemeData(
          buttonColor: const Color.fromARGB(255, 84, 146, 177),
          textTheme: ButtonTextTheme.primary,
        ),
        // Add more theme properties as needed
      ),
      home: HomePage(),
      // Define named routes
      routes: {
        '/home': (context) => HomePage(),
        // Add more routes as needed
      },
    );
  }
}
