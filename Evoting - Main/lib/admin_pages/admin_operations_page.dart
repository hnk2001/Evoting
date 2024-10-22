import 'dart:convert';
import '../../admin_pages/admin/display_admin.dart';
import 'package:flutter/material.dart';
import 'admin/create_admin.dart';
import 'admin/update_admin.dart';
import 'admin/delete_admin.dart';
import 'package:provider/provider.dart';
import '../../utils/auth_token.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class AdminMainPage extends StatefulWidget {
  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
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
        title: Text('Admin Dashboard'),
        backgroundColor: Color.fromARGB(255, 0, 126, 158), // Admin theme color
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          shrinkWrap: true,
          children: <Widget>[
            if (_role != 'VILLAGE') // Only show if role is not VILLAGE
              _buildActionButton(
                  context, 'Display admins', AdminList(), Icons.group),
            SizedBox(height: 20),
            if (_role != 'VILLAGE') // Only show if role is not VILLAGE
              _buildActionButton(
                  context, 'Create Admin', CreateAdminPage(), Icons.person_add),
            SizedBox(height: 20),
            _buildActionButton(
                context, 'Update Admin', UpdateAdminPage(), Icons.update),
            SizedBox(height: 20),
            if (_role != 'VILLAGE') // Only show if role is not VILLAGE
              _buildActionButton(
                  context, 'Delete Admin', DeleteAdminPage(), Icons.delete),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String title, Widget page, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)),
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        minimumSize: Size.fromHeight(50),
        backgroundColor: Color.fromARGB(255, 63, 155, 179), // Background color
        foregroundColor: Color.fromARGB(255, 4, 11, 29),
      ),
    );
  }
}
