import '../../admin_dashboard.dart';
import '../../utils/auth_token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';

class AdminSigninPage extends StatefulWidget {
  @override
  _AdminSigninPageState createState() => _AdminSigninPageState();
}

class _AdminSigninPageState extends State<AdminSigninPage> {
  final TextEditingController _adminUsernameController =
      TextEditingController();
  final TextEditingController _adminPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _adminLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      http.Response response = await http.post(
        Uri.parse('${APIConstants.baseUrl}/admin/signin'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _adminUsernameController.text,
          'password': _adminPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final String token = jsonDecode(response.body)['jwt'];
        // Directly set the token in the AuthToken provider (in-memory storage)
        Provider.of<AuthToken>(context, listen: false).setToken(token);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => AdminDashboard()));
      } else {
        _showSnackBar('Signin failed');
      }
    } catch (e) {
      _showSnackBar('Error occurred: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      backgroundColor: Color.fromARGB(255, 0, 144, 180),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            const Icon(Icons.account_circle, size: 72),
                            const SizedBox(height: 10),
                            _buildUsernameField(),
                            const SizedBox(height: 10),
                            _buildPasswordField(),
                            const SizedBox(height: 20),
                            _buildLoginButton(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _adminUsernameController,
      decoration: const InputDecoration(labelText: 'Username'),
      validator: (value) => value!.isEmpty ? 'Please enter username' : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _adminPasswordController,
      decoration: const InputDecoration(labelText: 'Password'),
      obscureText: true,
      validator: (value) => value!.isEmpty ? 'Please enter password' : null,
    );
  }

  Widget _buildLoginButton() {
    return _isLoading
        ? CircularProgressIndicator()
        : ElevatedButton(
            onPressed: _isLoading ? null : () => _adminLogin(context),
            child: const Text('Login'),
          );
  }
}
