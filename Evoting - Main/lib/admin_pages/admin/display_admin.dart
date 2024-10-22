import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../utils/auth_token.dart';
import '../../utils/constants.dart';

class Admin {
  final String id;
  final String fullName;
  final String role;

  Admin({required this.id, required this.fullName, required this.role});

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
        id: json['id'], fullName: json['fullName'], role: json['role']);
  }
}

class AdminList extends StatefulWidget {
  @override
  _AdminsElectionPageState createState() => _AdminsElectionPageState();
}

class _AdminsElectionPageState extends State<AdminList> {
  List<Admin> admins = [];
  List<Admin> filteredAdmins = [];
  final TextEditingController _controller = TextEditingController();

  Future<void> fetchAdmins(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('${APIConstants.baseUrl}/api/admin/list'),
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedJson = json.decode(response.body);
        final List<dynamic> adminsJson = decodedJson['admins'];
        setState(() {
          admins = adminsJson.map((json) => Admin.fromJson(json)).toList();
          filteredAdmins = admins;
        });
      } else {
        throw Exception('Failed to load admins');
      }
    } catch (e) {
      // Handle exceptions, for example, showing a dialog with the error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch admins: $e'),
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
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        filteredAdmins = admins
            .where((admin) => admin.fullName.contains(_controller.text))
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
          buttonColor: Color.fromARGB(255, 18, 126, 153),
          textTheme: ButtonTextTheme.primary,
        ), // Sets the accent color locally
        // Define other local theme properties here
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admins'),
          backgroundColor: Color.fromARGB(255, 0, 144, 180),
        ),
        body: Column(
          children: [
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await fetchAdmins(authToken);
              },
              child: Text('Fetch Admins'),
              style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 17, 103, 153),
                  onPrimary: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Search by Admin ID',
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
                        'ID',
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
                        'Role',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: filteredAdmins
                      .map((admin) => DataRow(
                            cells: <DataCell>[
                              DataCell(
                                  Text(admin.id,
                                      style: TextStyle(fontSize: 16)),
                                  onTap: () {}),
                              DataCell(
                                  Text(admin.fullName,
                                      style: TextStyle(fontSize: 16)),
                                  onTap: () {}),
                              DataCell(
                                  Text(admin.role,
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

class AdminSearch extends SearchDelegate<Admin> {
  final List<Admin> admins;

  AdminSearch(this.admins);

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
    final suggestionList = admins
        .where((admin) =>
            admin.fullName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        title: Text(suggestionList[index].fullName),
      ),
      itemCount: suggestionList.length,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = admins
        .where((admin) =>
            admin.fullName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        title: Text(suggestionList[index].fullName),
      ),
      itemCount: suggestionList.length,
    );
  }
}
