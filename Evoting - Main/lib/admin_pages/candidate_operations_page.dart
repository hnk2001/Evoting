import 'dart:convert';
import '../../admin_pages/candidate/display_candidate.dart';
import 'package:flutter/material.dart';
import 'candidate/create_candidate.dart';
import 'candidate/delete_candidate.dart';
import 'package:provider/provider.dart';
import '../../utils/auth_token.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class CandidatePage extends StatefulWidget {
  @override
  State<CandidatePage> createState() => _CandidateMainPageState();
}

class _CandidateMainPageState extends State<CandidatePage> {
  String _role = ''; // State variable to store the role

  @override
  void initState() {
    super.initState();
    _fetchRole(); // Fetch the role when the widget is initialized
  }

  Future<void> _fetchRole() async {
    String authToken = Provider.of<AuthToken>(context, listen: false).token;
    final String apiUrl = '${APIConstants.baseUrl}/api/admin/get/role';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _role = data['role']; // Update the role state variable
        });
      } else {
        print('Failed to fetch role. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching role: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Candidate Operations Dashboard'),
        backgroundColor:
            Color.fromARGB(255, 0, 119, 103), // Candidate theme color
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          shrinkWrap: true,
          children: [
            _buildOperationButton(
                context, 'Display Candidates', CandidateList(), Icons.group),
            SizedBox(height: 20),
            if (_role == 'STATE' ||
                _role == 'CITY_NAGAR_ADHYAKSHA' ||
                _role == 'CITY_NAGAR_SEVAK' ||
                _role == 'VILLAGE')
              _buildOperationButton(context, 'Create Candidate',
                  CreateCandidatePage(), Icons.person_add),
            SizedBox(height: 20),
            if (_role == 'STATE' ||
                _role == 'CITY_NAGAR_ADHYAKSHA' ||
                _role == 'CITY_NAGAR_SEVAK' ||
                _role == 'VILLAGE')
              _buildOperationButton(context, 'Delete Candidate',
                  DeleteCandidatePage(), Icons.delete),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationButton(
      BuildContext context, String title, Widget page, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)),
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        minimumSize: Size.fromHeight(50),
        backgroundColor: Color.fromARGB(255, 50, 172, 155), // Background color
        foregroundColor: Color.fromARGB(255, 0, 5, 1),
      ),
    );
  }
}
