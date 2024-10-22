import 'dart:convert';
import '../../admin_pages/election_operations_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../utils/auth_token.dart';
import '../../utils/constants.dart';

class UpdateElectionPage extends StatefulWidget {
  @override
  _UpdateElectionPageState createState() => _UpdateElectionPageState();
}

class _UpdateElectionPageState extends State<UpdateElectionPage> {
  final TextEditingController _electionNameController = TextEditingController();
  final TextEditingController _electionAssemblyController =
      TextEditingController();
  final TextEditingController _electionLocationController =
      TextEditingController();
  final TextEditingController _electionStartTimeController =
      TextEditingController();
  final TextEditingController _electionEndTimeController =
      TextEditingController();

  Future<void> _updateElection(String authToken, String electionName) async {
    final String apiUrl =
        '${APIConstants.baseUrl}/api/admin/update/$electionName';

    final response = await http.put(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(<String, dynamic>{
        'name': _electionNameController.text,
        'assembly': _electionAssemblyController.text,
        'location': _electionLocationController.text,
        'startTime': _electionStartTimeController.text,
        'endTime': _electionEndTimeController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Successfully updated election
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Election Updated successfully'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      // Failed to update election
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update election'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _selectDateTime(TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        controller.text = selectedDateTime.toIso8601String();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String authToken = Provider.of<AuthToken>(context).token;
    return Theme(
      data: ThemeData(
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueAccent,
          textTheme: ButtonTextTheme.primary,
        ), // Sets the accent color locally
        // Define other local theme properties here
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Update Election Profile'),
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
                TextFormField(
                  controller: _electionStartTimeController,
                  decoration: InputDecoration(
                    labelText: 'Start Time',
                    suffixIcon: Icon(Icons.timer), // Add icon
                  ),
                  onTap: () => _selectDateTime(_electionStartTimeController),
                  validator: (value) =>
                      value!.isEmpty ? 'This field is required' : null,
                  readOnly: true, // Prevent keyboard from appearing
                ),
                TextFormField(
                  controller: _electionEndTimeController,
                  decoration: InputDecoration(
                    labelText: 'End Time',
                    suffixIcon: Icon(Icons.timer_off), // Add icon
                  ),
                  onTap: () => _selectDateTime(_electionEndTimeController),
                  validator: (value) =>
                      value!.isEmpty ? 'This field is required' : null,
                  readOnly: true, // Prevent keyboard from appearing
                ),
                // Other text fields...
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _updateElection(authToken, _electionNameController.text);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ElectionPage()),
                    );
                  },
                  child: const Text('Update Election'),
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
