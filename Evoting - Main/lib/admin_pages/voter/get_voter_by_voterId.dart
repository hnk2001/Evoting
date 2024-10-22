import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import '../../utils/auth_token.dart';
import '../../utils/constants.dart';

class VoterInfoPage extends StatefulWidget {
  @override
  _VoterInfoPageState createState() => _VoterInfoPageState();
}

class _VoterInfoPageState extends State<VoterInfoPage> {
  final TextEditingController _voterIdController = TextEditingController();
  Map<String, dynamic>? voterInfo;

  Future<void> fetchVoterInfo(String authToken, String voterId) async {
    final String apiUrl =
        '${APIConstants.baseUrl}/api/admin/get/voter/$voterId';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          voterInfo = json.decode(response.body);
        });
      } else {
        // Failed to delete voter
        setState(() {
          voterInfo = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load voter info'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error occurred: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> fetchAndDisplayImage(
      String authToken, String voterId, String imageType) async {
    final String imageUrl =
        '${APIConstants.baseUrl}/api/admin/voter/$voterId/$imageType';
    try {
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode == 200) {
        Uint8List imageBytes = response.bodyBytes;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Image.memory(imageBytes, fit: BoxFit.cover),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String authToken = Provider.of<AuthToken>(context).token;
    return Scaffold(
      appBar: AppBar(
          title: Text('Get Voter Information'),
          backgroundColor: Color.fromARGB(255, 107, 105, 0)),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _voterIdController,
                decoration: InputDecoration(
                  labelText: 'Enter Voter ID',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () =>
                        fetchVoterInfo(authToken, _voterIdController.text),
                  ),
                ),
                maxLength: 10,
              ),
            ),
            if (voterInfo != null) _buildVoterInfoCard(voterInfo!),
            if (voterInfo != null)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => fetchAndDisplayImage(
                        authToken, _voterIdController.text, 'aadhaarImage'),
                    child: Text('View Aadhaar Image'),
                  ),
                  ElevatedButton(
                    onPressed: () => fetchAndDisplayImage(
                        authToken, _voterIdController.text, 'voterImage'),
                    child: Text('View Voter Image'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoterInfoCard(Map<String, dynamic> info) {
    return Card(
      color: Color.fromRGBO(236, 218, 241, 0.747),
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _infoRow(Icons.person, 'First Name', info['firstName']),
            _infoRow(Icons.person_outline, 'Middle Name', info['middleName']),
            _infoRow(Icons.person_pin, 'Last Name', info['lastName']),
            _infoRow(Icons.cake, 'Date of Birth', info['dateOfBirth']),
            _infoRow(Icons.phone, 'Contact Number', info['contactNumber']),
            _infoRow(Icons.home, 'House No', info['houseNoFlatNo']),
            _infoRow(
                Icons.location_city, 'City/Village', info['cityOrVillage']),
            _infoRow(Icons.map, 'Ward No', info['areaOrWardNo']),
            _infoRow(Icons.account_balance, 'Taluka', info['taluka']),
            _infoRow(Icons.pin_drop, 'Pincode', info['pincode']),
            _infoRow(Icons.location_on, 'District', info['district']),
            _infoRow(Icons.flag, 'State', info['state']),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String? value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Color.fromARGB(255, 164, 72, 218)),
          SizedBox(width: 8.0),
          Text('$label: ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
          Expanded(
              child: Text(
            value ?? 'N/A',
            style: TextStyle(
              fontSize:
                  17, // Optionally, adjust the font size of the value as well
            ),
          )),
        ],
      ),
    );
  }
}

//   Widget _imageRow(String label, String base64Image) {
//     // Decode the base64 string to bytes
//     Uint8List bytes = base64.decode(base64Image);
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('$label:',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
//           SizedBox(height: 8.0),
//           Image.memory(bytes, fit: BoxFit.cover),
//         ],
//       ),
//     );
//   }
// }
