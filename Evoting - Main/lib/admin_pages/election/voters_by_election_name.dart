import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../utils/auth_token.dart';
import '../../utils/constants.dart';

class Voter {
  final String voterId;
  final String cityOrVillage;
  final String taluka;
  final String district;
  final String state;

  Voter(
      {required this.voterId,
      required this.cityOrVillage,
      required this.taluka,
      required this.district,
      required this.state});

  factory Voter.fromJson(Map<String, dynamic> json) {
    return Voter(
      voterId: json['voterId'],
      cityOrVillage: json['cityOrVillage'],
      taluka: json['taluka'],
      district: json['district'],
      state: json['state'],
    );
  }
}

class VotersElectionPage extends StatefulWidget {
  @override
  _VotersElectionPageState createState() => _VotersElectionPageState();
}

class _VotersElectionPageState extends State<VotersElectionPage> {
  List<Voter> voters = [];
  List<Voter> filteredVoters = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _electionNameController = TextEditingController();

  Future<void> fetchVoters(String authToken, String electionName) async {
    final response = await http.get(
      Uri.parse('${APIConstants.baseUrl}/api/admin/by-election/$electionName'),
      headers: <String, String>{
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedJson = json.decode(response.body);
      final List<dynamic> votersJson = decodedJson['voters'];
      setState(() {
        voters = votersJson.map((json) => Voter.fromJson(json)).toList();
        filteredVoters = voters;
      });
    } else {
      throw Exception('Failed to load voters');
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        filteredVoters = voters
            .where((voter) => voter.voterId.contains(_controller.text))
            .toList();
      });
    });
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
          title: Text('Voters'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _electionNameController,
                decoration: InputDecoration(
                  labelText: 'Enter Election Name',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await fetchVoters(authToken, _electionNameController.text);
              },
              child: Text('Fetch Voters'),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Search by Voter ID',
                ),
              ),
            ),
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
                        'Voter Id',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'City/Village',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Taluka',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'District',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: filteredVoters
                      .map((voter) => DataRow(
                            cells: <DataCell>[
                              DataCell(
                                  Text(voter.voterId,
                                      style: TextStyle(fontSize: 16)),
                                  onTap: () {}),
                              DataCell(
                                  Text(voter.cityOrVillage,
                                      style: TextStyle(fontSize: 16)),
                                  onTap: () {}),
                              DataCell(
                                  Text(voter.taluka,
                                      style: TextStyle(fontSize: 16)),
                                  onTap: () {}),
                              DataCell(
                                  Text(voter.district,
                                      style: TextStyle(fontSize: 16)),
                                  onTap: () {}),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VoterSearch extends SearchDelegate<Voter> {
  final List<Voter> voters;

  VoterSearch(this.voters);

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
    final suggestionList = voters
        .where((voter) =>
            voter.voterId.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        title: Text(suggestionList[index].voterId),
      ),
      itemCount: suggestionList.length,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = voters
        .where((voter) =>
            voter.voterId.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        title: Text(suggestionList[index].voterId),
      ),
      itemCount: suggestionList.length,
    );
  }
}
