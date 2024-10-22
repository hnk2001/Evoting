import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../utils/auth_token.dart';
import '../../utils/constants.dart';
import './election_results_details.dart';

class Election {
  final String name;

  Election({required this.name});

  factory Election.fromJson(dynamic json) {
    return Election(name: json as String);
  }
}

class ElectionResultsPage extends StatefulWidget {
  @override
  _ElectionResultsPageState createState() => _ElectionResultsPageState();
}

class _ElectionResultsPageState extends State<ElectionResultsPage> {
  List<Election> elections = [];

  @override
  void initState() {
    super.initState();
    _fetchElections();
  }

  Future<void> _fetchElections() async {
    String authToken = Provider.of<AuthToken>(context, listen: false).token;
    try {
      final response = await http.get(
        Uri.parse('${APIConstants.baseUrl}/api/admin/electionList'),
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> electionNamesJson = json.decode(response.body);
        setState(() {
          elections =
              electionNamesJson.map((name) => Election.fromJson(name)).toList();
        });
      } else {
        throw Exception('Failed to load elections');
      }
    } catch (e) {
      // Handle exceptions
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch elections: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _navigateToElectionResults(String selectedElection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ElectionResultsDetailsPage(selectedElection),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Election Results'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: elections.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(elections[index].name),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              _navigateToElectionResults(elections[index].name);
            },
          );
        },
      ),
    );
  }
}
