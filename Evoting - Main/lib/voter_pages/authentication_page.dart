import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../voter_pages/candidate_page_for_voter.dart';

class AuthenticationScreen extends StatefulWidget {
  final String voterId;
  final String aadhaarNumber;

  AuthenticationScreen(
      {Key? key, required this.voterId, required this.aadhaarNumber})
      : super(key: key);
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _authenticateAndStore(); // Automatically run the authenticate method
  }

  Future<void> _authenticateAndStore() async {
    setState(() {
      _isAuthenticating = true;
    });
    bool authenticated = false;
    try {
      authenticated = await _localAuthentication.authenticate(
          localizedReason: 'Authenticate to store fingerprint data',
          options: const AuthenticationOptions(biometricOnly: true));
    } catch (e) {
      print(e);
      _showSnackBar('Authentication failed: $e');
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }

    if (authenticated) {
      print('Authentication successful');
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChooseCandidate(
                  voterId: widget.voterId,
                  aadhaarNumber: widget.aadhaarNumber,
                )),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 96, 108, 180),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.fingerprint,
                  size: 50,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Authenticate to Vote',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _authenticateAndStore,
                icon: Icon(Icons.fingerprint),
                label: Text('Authenticate'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.indigo,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
