import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../utils/auth_token.dart';
import '../../utils/constants.dart';

class Candidate {
  final String id;
  final String name;
  final String party;

  Candidate({required this.id, required this.name, required this.party});

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(id: json['id'], name: json['name'], party: json['party']);
  }
}

class Election {
  final String name;

  Election({required this.name});

  factory Election.fromJson(dynamic json) {
    return Election(name: json as String);
  }
}

class CandidateList extends StatefulWidget {
  @override
  _CandidatesElectionPageState createState() => _CandidatesElectionPageState();
}

class _CandidatesElectionPageState extends State<CandidateList> {
  String _role = '';
  List<Election> elections = [];
  List<Candidate> candidates = [];
  List<Candidate> filteredCandidates = [];
  final TextEditingController _controller = TextEditingController();
  String? selectedElection;

  @override
  void initState() {
    super.initState();
    _fetchRole();
    _controller.addListener(() {
      setState(() {
        filteredCandidates = candidates
            .where((candidate) => candidate.name.contains(_controller.text))
            .toList();
      });
    });
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
          _role = data['role'];
          if (_role == 'CENTRAL') {
            _fetchElections(authToken);
          }
        });
      } else {
        print('Failed to fetch role. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching role: $e');
    }
  }

  Future<void> fetchCandidates(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('${APIConstants.baseUrl}/api/admin/candidate-list'),
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedJson = json.decode(response.body);
        final List<dynamic> candidatesJson = decodedJson['candidates'];
        setState(() {
          candidates =
              candidatesJson.map((json) => Candidate.fromJson(json)).toList();
          filteredCandidates = candidates;
        });
      } else {
        throw Exception('Failed to load candidates');
      }
    } catch (e) {
      // Handle exceptions, for example, showing a dialog with the error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch candidates: $e'),
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

  Future<void> fetchCandidatesByElectionName(
      String electionName, String authToken) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${APIConstants.baseUrl}/api/admin/all-candidate-list/$electionName'),
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedJson = json.decode(response.body);
        final List<dynamic> candidatesJson = decodedJson['candidates'];
        setState(() {
          candidates =
              candidatesJson.map((json) => Candidate.fromJson(json)).toList();
          filteredCandidates = candidates;
        });
      } else {
        throw Exception('Failed to load candidates');
      }
    } catch (e) {
      // Handle exceptions
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch candidates: $e'),
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

  Future<void> _fetchElections(String authToken) async {
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

  @override
  Widget build(BuildContext context) {
    String authToken = Provider.of<AuthToken>(context).token;
    return Theme(
      data: ThemeData(
        buttonTheme: ButtonThemeData(
          buttonColor: Color.fromARGB(255, 0, 126, 109),
          textTheme: ButtonTextTheme.primary,
        ), // Sets the accent color locally
        // Define other local theme properties here
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Candidates'),
          backgroundColor: Color.fromARGB(255, 0, 126, 109),
          leading: selectedElection != null
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      selectedElection = null;
                    });
                  },
                )
              : null,
        ),
        body: _role == 'CENTRAL'
            ? selectedElection == null
                ? _buildElectionList(authToken)
                : _buildCandidateList(authToken)
            : _buildCandidateList(authToken),
      ),
    );
  }

  Widget _buildElectionList(String authToken) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          'Election List',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: elections.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(elections[index].name),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  setState(() {
                    selectedElection = elections[index].name;
                  });
                  fetchCandidatesByElectionName(
                      elections[index].name, authToken);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCandidateList(String authToken) {
    return Column(
      children: [
        if (_role == 'CENTRAL') ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '$selectedElection',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Search by Candidate Name',
            ),
          ),
        ),
        if (_role != 'CENTRAL') ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                // Fetch candidates when the role is not 'CENTRAL'
                fetchCandidates(authToken);
              },
              child: Text('Fetch Candidates'),
            ),
          ),
        ],
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              dataRowHeight: 60,
              columnSpacing: 20,
              horizontalMargin: 10,
              headingRowHeight: 30,
              columns: [
                DataColumn(
                  label: Text(
                    'Candidate ID',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Full Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Party',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: filteredCandidates
                  .map((candidate) => DataRow(
                        cells: <DataCell>[
                          DataCell(
                            Text(candidate.id, style: TextStyle(fontSize: 16)),
                            onTap: () {},
                          ),
                          DataCell(
                            Text(candidate.name,
                                style: TextStyle(fontSize: 16)),
                            onTap: () {},
                          ),
                          DataCell(
                            Text(candidate.party,
                                style: TextStyle(fontSize: 16)),
                            onTap: () {},
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ),
        if (_role == 'CENTRAL') ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedElection = null;
                });
              },
              child: Text('Back to Election List'),
            ),
          ),
        ],
      ],
    );
  }
}

class CandidateSearch extends SearchDelegate<Candidate> {
  final List<Candidate> candidates;

  CandidateSearch(this.candidates);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        //close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestionList = candidates
        .where((candidate) =>
            candidate.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        title: Text(suggestionList[index].name),
      ),
      itemCount: suggestionList.length,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = candidates
        .where((candidate) =>
            candidate.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        title: Text(suggestionList[index].name),
      ),
      itemCount: suggestionList.length,
    );
  }
}
