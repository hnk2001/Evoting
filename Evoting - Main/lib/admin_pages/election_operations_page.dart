import 'dart:convert';
import 'package:flutter/material.dart';
import 'election/create_election.dart';
import 'election/update_election.dart';
import 'election/delete_election.dart';
import 'election/election_results.dart';
import 'election/election_percentage.dart';
import 'election/voters_by_election_name.dart';
import 'package:provider/provider.dart';
import '../../utils/auth_token.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class ElectionPage extends StatefulWidget {
  @override
  State<ElectionPage> createState() => _ElectionMainPageState();
}

class _ElectionMainPageState extends State<ElectionPage> {
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
        title: Text('Elections Operations Dashboard'),
        backgroundColor: Colors.blueAccent, // Election theme color
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          shrinkWrap: true,
          children: [
            if (_role == 'STATE' ||
                _role == 'CITY_NAGAR_ADHYAKSHA' ||
                _role == 'CITY_NAGAR_SEVAK' ||
                _role == 'VILLAGE')
              _buildOperationButton(context, 'Create Election',
                  CreateElectionPage(), Icons.how_to_vote),
            SizedBox(height: 20),
            if (_role == 'STATE' ||
                _role == 'CITY_NAGAR_ADHYAKSHA' ||
                _role == 'CITY_NAGAR_SEVAK' ||
                _role == 'VILLAGE')
              _buildOperationButton(context, 'Update Election',
                  UpdateElectionPage(), Icons.update),
            SizedBox(height: 20),
            if (_role == 'STATE' ||
                _role == 'CITY_NAGAR_ADHYAKSHA' ||
                _role == 'CITY_NAGAR_SEVAK' ||
                _role == 'VILLAGE')
              _buildOperationButton(context, 'Delete Election',
                  DeleteElectionPage(), Icons.delete_forever),
            SizedBox(height: 20),
            _buildOperationButton(context, 'Display Election Results',
                ElectionResultsPage(), Icons.pie_chart),
            SizedBox(height: 20),
            _buildOperationButton(context, 'Voters in Current Election',
                VotersElectionPage(), Icons.group),
            SizedBox(height: 20),
            _buildOperationButton(context, 'Election Percentage',
                ElectionPercentagePage(), Icons.pie_chart_outline_outlined),
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
        backgroundColor:
            const Color.fromARGB(255, 99, 185, 224), // Background color
        foregroundColor: Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }
}
