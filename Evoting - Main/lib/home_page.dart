import './admin_pages/admin/admin_signin_page.dart';
import 'package:flutter/material.dart';
import 'voter_pages/voter_aadhaar_number_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define a base color for the theme
    Color baseBlueColor =
        Color.fromARGB(255, 8, 54, 97); // A vibrant blue color

    return Scaffold(
      appBar: AppBar(
          title: Text('E-Voting System'),
          backgroundColor: baseBlueColor.withOpacity(0.8)
          // Circular border for the AppBar
          ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/front_page.jpeg"),
              fit: BoxFit.cover,
              opacity: 0.8 // Cover the entire widget area
              ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.admin_panel_settings, size: 40),
                label: Text('Admin',
                    style: TextStyle(
                      fontSize: 24, // Adjusted for consistency
                    )),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminSigninPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: baseBlueColor, // Button background color
                  onPrimary: Colors.white, // Text and icon color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 45,
                      vertical: 18), // Adjusted padding for consistency
                ),
              ),
              SizedBox(height: 20), // Add some space between the buttons
              ElevatedButton.icon(
                icon: Icon(Icons.how_to_vote,
                    size: 40), // Ensure icon size consistency
                label: Text('Voter',
                    style: TextStyle(
                      fontSize: 24, // Adjusted for consistency
                    )),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VoterDashboard()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: baseBlueColor, // Button background color
                  onPrimary: Colors.white, // Text and icon color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 18), // Adjusted padding for consistency
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
