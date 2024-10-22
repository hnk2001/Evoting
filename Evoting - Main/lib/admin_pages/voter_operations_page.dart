import '../../admin_pages/voter/get_voter_by_voterId.dart';
import 'package:flutter/material.dart';
import 'voter/create_voter.dart';
import 'voter/update_voter.dart';
import 'voter/delete_voter.dart';

class VoterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voters Operations Dashboard'),
        backgroundColor: Color.fromARGB(255, 107, 105, 0), // Voter theme color
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          shrinkWrap: true,
          children: [
            _buildOperationButton(
                context, 'Voter Info', VoterInfoPage(), Icons.info),
            SizedBox(height: 20),
            _buildOperationButton(
                context, 'Create Voter', CreateVoterPage(), Icons.person_add),
            SizedBox(height: 20),
            _buildOperationButton(
                context, 'Update Voter', UpdateVoterPage(), Icons.update),
            SizedBox(height: 20),
            _buildOperationButton(
                context, 'Delete Voter', DeleteVoterPage(), Icons.delete),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationButton(
      BuildContext context, String title, Widget page, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)),
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        minimumSize: Size.fromHeight(50),
        backgroundColor: Color.fromARGB(255, 207, 205, 51), // Background color
        foregroundColor: Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }
}
