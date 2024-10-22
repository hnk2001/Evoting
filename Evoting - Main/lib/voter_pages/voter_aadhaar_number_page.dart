import 'dart:convert';
import 'package:facerecognition_flutter/face_verify.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class VoterDashboard extends StatefulWidget {
  @override
  _VoterDashboardState createState() => _VoterDashboardState();
}

class _VoterDashboardState extends State<VoterDashboard> {
  final TextEditingController _aadhaarNumberController =
      TextEditingController();
  final TextEditingController _voterIdController = TextEditingController();
  bool _isAadhaarActive = false;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // To track loading state

  Future<void> _verifyVoter() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });
      final String apiUrl = '${APIConstants.baseUrl}/voter/verify';

      try {
        final response = await http.get(
          Uri.parse(
              '$apiUrl?voterId=${_voterIdController.text}&aadhaarNumber=${_aadhaarNumberController.text}'),
        );

        if (response.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(
                title: 'dfd',
                voterId: _voterIdController.text, // Pass voter ID value
                aadhaarNumber: _aadhaarNumberController.text,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error occurred')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  void _toggleInputBox() {
    setState(() {
      _isAadhaarActive = !_isAadhaarActive;
      if (_isAadhaarActive) {
        _voterIdController.clear();
      } else {
        _aadhaarNumberController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voter'),
        backgroundColor: Colors.indigo, // Set AppBar color to Colors.indigo
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(
                      255, 111, 199, 226), // Adjusted to match the indigo theme
                  const Color.fromARGB(
                      255, 121, 139, 252), // Darker shade for gradient end
                ], // Background gradient
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _isAadhaarActive
                        ? 'Enter Aadhaar Number'
                        : 'Enter Voter ID',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors
                            .white), // Adjusted text color for better visibility
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _isAadhaarActive
                        ? _aadhaarNumberController
                        : _voterIdController,
                    decoration: InputDecoration(
                      labelText:
                          _isAadhaarActive ? 'Aadhaar Number' : 'Voter ID',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    maxLength: _isAadhaarActive ? 12 : 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter this field';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _verifyVoter,
                          child: Text('Submit to Verify'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.indigo, // Button background color
                          ),
                        ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _toggleInputBox,
                    child: Text(_isAadhaarActive
                        ? 'Switch to Voter ID'
                        : 'Switch to Aadhaar Number'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.indigo, // Button background color
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
