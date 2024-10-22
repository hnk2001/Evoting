import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../utils/auth_token.dart';
import '../../utils/constants.dart';

class DeleteCandidatePage extends StatefulWidget {
  @override
  _DeleteCandidatePageState createState() => _DeleteCandidatePageState();
}

class _DeleteCandidatePageState extends State<DeleteCandidatePage> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> _controllers = [];
  final TextEditingController _candidateNameController =
      TextEditingController();
  final TextEditingController _candidatePartyController =
      TextEditingController();
  final TextEditingController _electionNameController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _cityOrVillageController =
      TextEditingController();
  final TextEditingController _talukaController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  String _selectedCountry = 'India';
  final List<String> _countryOptions = ['India'];

  @override
  void initState() {
    super.initState();
    _controllers = [
      _candidateNameController,
      _candidatePartyController,
      _electionNameController,
      _houseNoController,
      _cityOrVillageController,
      _talukaController,
      _pincodeController,
      _districtController,
      _stateController,
    ];
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _deleteCandidate(String authToken, String name) async {
    if (_formKey.currentState!.validate()) {
      final String apiUrl =
          '${APIConstants.baseUrl}/api/admin/delete/candidate/$name';

      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: <String, String>{'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Candidate deleted successfully'),
            backgroundColor: Colors.green));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to delete candidate'),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _fetchCandidateDetails(String authToken, String name) async {
    final String apiUrl =
        '${APIConstants.baseUrl}/api/admin/get/candidate/$name';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      // Successfully fetched voter details
      final data = jsonDecode(response.body);
      setState(() {
        _candidateNameController.text = data['name'];
        _candidatePartyController.text = data['party'];
        _electionNameController.text = data['electionName'];
        _houseNoController.text = data['houseNoFlatNo'];
        _cityOrVillageController.text = data['cityOrVillage'];
        _talukaController.text = data['taluka'];
        _pincodeController.text = data['pincode'];
        _districtController.text = data['district'];
        _stateController.text = data['state'];
      });
    } else {
      // Failed to fetch voter details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch candidate details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String authToken = Provider.of<AuthToken>(context).token;

    List<Widget> formWidgets = [
      TextField(
        controller: _candidateNameController,
        decoration: InputDecoration(labelText: 'Candidate Name'),
      ),
      SizedBox(height: 10),
      ElevatedButton(
        onPressed: () {
          _fetchCandidateDetails(authToken, _candidateNameController.text);
        },
        child: Text('Fetch Candidate Details'),
        style: ElevatedButton.styleFrom(
          primary: Color.fromARGB(255, 0, 126, 109), // Button color
          onPrimary: Colors.white, // Text color
        ),
      ),
      _buildTextField(_candidateNameController, 'Full Name', Icons.person,
          'Please enter fullname',
          readOnly: false, fullNameValidation: true),
      _buildTextField(_candidatePartyController, 'Party', Icons.groups,
          'Please enter party',
          readOnly: false),
      _buildTextField(_electionNameController, 'Election Name', Icons.event,
          'Please enter election Name',
          readOnly: false),
      _buildTextField(_houseNoController, 'House Number', Icons.home,
          'Please enter House number'),
      _buildTextField(
        _cityOrVillageController,
        'City/Village',
        Icons.location_on,
        'Please enter City/Village',
      ),
      _buildTextField(
        _talukaController,
        'Taluka',
        Icons.map,
        'Please enter Taluka .if not type NA',
      ),
      _buildTextField(_pincodeController, 'Pincode', Icons.pin_drop,
          'Please enter mobile number',
          keyboardType: TextInputType.number, maxLength: 6),
      _buildTextField(
        _districtController,
        'District',
        Icons.location_city,
        'Please enter District',
      ),
      _buildTextField(
        _stateController,
        'State',
        Icons.map,
        'Please enter State',
      ),
      _buildDropdown(_selectedCountry, _countryOptions, 'Country', Icons.flag,
          (String? newValue) {
        setState(() => _selectedCountry = newValue!);
      }),
      SizedBox(height: 20),
      // Add other fields as needed...
      ElevatedButton(
        onPressed: () =>
            _deleteCandidate(authToken, _candidateNameController.text),
        child: Text('Delete Candidate'),
        style: ElevatedButton.styleFrom(
            primary: Color.fromARGB(255, 0, 126, 109), onPrimary: Colors.white),
      ),
      // Other form fields...
    ];

    return Theme(
      data: ThemeData(
        buttonTheme: ButtonThemeData(
          buttonColor: Color.fromARGB(255, 0, 161, 140),
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Delete Candidate'),
          backgroundColor: Color.fromARGB(255, 0, 117, 102),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: formWidgets,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      IconData icon, String validationMessage,
      {TextInputType keyboardType = TextInputType.text,
      int maxLength = TextField.noMaxLength,
      bool readOnly = false,
      bool fullNameValidation = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
      readOnly: readOnly,
      maxLength: maxLength != TextField.noMaxLength ? maxLength : null,
      validator: (value) {
        if (fullNameValidation && value!.trim().split(' ').length != 3) {
          return 'Full name must contain three names';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(String? selectedValue, List<String> options,
      String label, IconData icon, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      onChanged: onChanged,
      items: options.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }
}
