import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../utils/auth_token.dart';
import '../../utils/constants.dart';
import './election_percentage_details.dart';

class Election {
  final String name;

  Election({required this.name});

  factory Election.fromJson(dynamic json) {
    return Election(name: json as String);
  }
}

class ElectionPercentagePage extends StatefulWidget {
  @override
  _ElectionPercentagePageState createState() => _ElectionPercentagePageState();
}

class _ElectionPercentagePageState extends State<ElectionPercentagePage> {
  List<Election> elections = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchElections();
  }

  Future<void> fetchElections() async {
    setState(() {
      isLoading = true;
    });

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
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load elections');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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

  void _navigateToElectionPercentages(String electionName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ElectionPercentageDetailsPage(electionName: electionName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Election List')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: elections.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(elections[index].name),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    _navigateToElectionPercentages(elections[index].name);
                  },
                );
              },
            ),
    );
  }
}
