import 'dart:convert';
import 'package:flutter/material.dart';
import 'admin_pages/admin_operations_page.dart';
import 'admin_pages/voter_operations_page.dart';
import 'admin_pages/candidate_operations_page.dart';
import 'admin_pages/election_operations_page.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../utils/auth_token.dart';
import './utils/constants.dart';

class AdminDashboard extends StatelessWidget {
  AdminDashboard({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<Map<String, dynamic>> fetchAdminProfile(String authToken) async {
    final String apiUrl = '${APIConstants.baseUrl}/api/admin/profile';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 202) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load admin profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    String authToken = Provider.of<AuthToken>(context).token;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10), // Add 10px margin to the right
            child: IconButton(
              icon: Icon(
                Icons.account_circle,
                size: 35,
              ),
              onPressed: () =>
                  _scaffoldKey.currentState?.openEndDrawer(), // Open drawer
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchAdminProfile(authToken), // Your fetch function
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else {
              // Assuming data is fetched successfully
              Map<String, dynamic> profileData = snapshot.data!;
              return ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text(profileData['fullName'] ?? 'N/A'),
                    accountEmail: Text(profileData['email'] ?? 'N/A'),
                    currentAccountPicture: CircleAvatar(
                      child: Icon(Icons.account_circle, size: 60.0),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.deepPurple),
                    title: Text('Full Name: ${profileData['fullName']}'),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone, color: Colors.deepPurple),
                    title: Text('Mobile: ${profileData['mobile']}'),
                  ),
                  ListTile(
                    leading: Icon(Icons.email, color: Colors.deepPurple),
                    title: Text('Email: ${profileData['email']}'),
                  ),
                  ListTile(
                    leading: Icon(Icons.group, color: Colors.deepPurple),
                    title: Text('Role: ${profileData['role']}'),
                  ),
                  // Add more fields as needed
                ],
              );
            }
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purpleAccent,
              Colors.blueAccent
            ], // Background gradient
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            // Ensures the content is scrollable if it overflows
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildDashboardCard('Admin', Icons.admin_panel_settings, () {
                  _navigateToPage(context, AdminMainPage());
                }, context),
                SizedBox(height: 20), // Adds space between the cards
                _buildDashboardCard('Voter Operations', Icons.how_to_vote, () {
                  _navigateToPage(context, VoterPage());
                }, context),
                SizedBox(height: 20), // Adds space between the cards
                _buildDashboardCard('Candidate Operations', Icons.person_add,
                    () {
                  _navigateToPage(context, CandidatePage());
                }, context),
                SizedBox(height: 20), // Adds space between the cards
                _buildDashboardCard('Election Operations', Icons.ballot, () {
                  _navigateToPage(context, ElectionPage());
                }, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      String title, IconData icon, VoidCallback onTap, BuildContext context) {
    // Define fixed width and height for the cards
    double cardWidth = 190.0;
    double cardHeight = 130.0;

    return Container(
      width: cardWidth,
      height: cardHeight,
      child: Card(
        elevation: 4.0,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 48.0, color: Colors.deepPurple),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16.0, color: Colors.deepPurple),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
}

// ***********************************************


