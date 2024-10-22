import 'dart:convert';
import '../../admin_pages/election_operations_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../utils/auth_token.dart';
import '../../utils/constants.dart';

class DeleteElectionPage extends StatefulWidget {
  @override
  _DeleteElectionPageState createState() => _DeleteElectionPageState();
}

class _DeleteElectionPageState extends State<DeleteElectionPage> {
  final TextEditingController _electionNameController = TextEditingController();
  final TextEditingController _electionAssemblyController =
      TextEditingController();
  final TextEditingController _electionLocationController =
      TextEditingController();
  final TextEditingController _electionStartTimeController =
      TextEditingController();
  final TextEditingController _electionEndTimeController =
      TextEditingController();
  Future<void> _deleteElection(String authToken, String electionName) async {
    final String apiUrl =
        '${APIConstants.baseUrl}/api/admin/delete/election/$electionName';

    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      // Successfully deleted election
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Election deleted successfully'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      // Failed to delete election
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete election'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String authToken = Provider.of<AuthToken>(context).token;
    return Theme(
      data: ThemeData(
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.lightBlue,
          textTheme: ButtonTextTheme.primary,
        ), // Sets the accent color locally
        // Define other local theme properties here
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Delete Election Profile'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: _electionNameController,
                  decoration: InputDecoration(labelText: 'Enter Election Name'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _fetchElectionDetails(
                        authToken, _electionNameController.text);
                  },
                  child: Text('Fetch Election Details'),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _electionNameController,
                  decoration: InputDecoration(labelText: 'Election Name'),
                  enabled: false,
                ),
                TextField(
                  controller: _electionAssemblyController,
                  decoration: InputDecoration(labelText: 'Assembly'),
                  enabled: false,
                ),
                TextField(
                  controller: _electionLocationController,
                  decoration: InputDecoration(labelText: 'Location/Place'),
                  enabled: false,
                ),
                TextField(
                  controller: _electionStartTimeController,
                  decoration: InputDecoration(labelText: 'Start Time'),
                  enabled: false,
                ),
                TextField(
                  controller: _electionEndTimeController,
                  decoration: InputDecoration(labelText: 'End Time'),
                  enabled: false,
                ),
                // Other text fields...
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _deleteElection(authToken, _electionNameController.text);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ElectionPage()),
                    );
                  },
                  child: const Text('Delete Election'),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to fetch election details
  Future<void> _fetchElectionDetails(
      String authToken, String electionName) async {
    final String apiUrl =
        '${APIConstants.baseUrl}/api/admin/get/election/$electionName';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      // Successfully fetched election details
      final data = jsonDecode(response.body);
      setState(() {
        _electionNameController.text = data['name'];
        _electionAssemblyController.text = data['assembly'];
        _electionLocationController.text = data['location'];
        _electionStartTimeController.text = data['startTime'];
        _electionEndTimeController.text = data['endTime'];
      });
    } else {
      // Failed to fetch election details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch election details')),
      );
    }
  }
}
