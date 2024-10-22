import 'dart:convert';
import '../../utils/auth_token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../utils/constants.dart';

enum ElectionType {
  LOK_SABHA,
  VIDHAN_SABHA,
  GRAM_PANCHAYAT,
  NAGARSEVAK,
  NAGARADHYAKSHA,
}

class CreateElectionPage extends StatefulWidget {
  @override
  _CreateElectionPageState createState() => _CreateElectionPageState();
}

class _CreateElectionPageState extends State<CreateElectionPage> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> _controllers = [];
  final TextEditingController _electionNameController = TextEditingController();
  final TextEditingController _electionLocationController =
      TextEditingController();
  final TextEditingController _electionStartTimeController =
      TextEditingController();
  final TextEditingController _electionEndTimeController =
      TextEditingController();
  // ElectionType? selectedElectionType;

  String? _selectedAssembly;
  final List<String> _assemblyOptions = ['LOK_SABHA', 'VIDHAN_SABHA'];
  String _role = '';

  @override
  void initState() {
    super.initState();
    _controllers = [
      _electionNameController,
      _electionLocationController,
      _electionStartTimeController,
      _electionEndTimeController,
    ];
    _fetchRole();
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
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
        });
      } else {
        print('Failed to fetch role. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching role: $e');
    }
  }

  Future<void> _createElection(String authToken) async {
    if (_formKey.currentState!.validate()) {
      final String apiUrl = '${APIConstants.baseUrl}/api/admin/create/election';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(<String, dynamic>{
          'name': _electionNameController.text,
          'assembly': _selectedAssembly,
          'location': _electionLocationController.text,
          'startTime': _electionStartTimeController.text,
          'endTime': _electionEndTimeController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Election created successfully'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to create election'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectDateTime(TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        controller.text = selectedDateTime.toIso8601String();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String authToken = Provider.of<AuthToken>(context).token;
    List<Widget> formWidgets = [
      _buildTextField(
        _electionNameController,
        'Election Name',
        Icons.person,
        'Please enter Election name',
        readOnly: false,
      ),
      _buildTextField(_electionLocationController, 'Location',
          Icons.location_city, 'Please enter party',
          readOnly: false),
      // Other form fields...
    ];

    // Conditionally add the assembly dropdown based on the role
    if (_role == 'STATE') {
      formWidgets.add(_buildDropdown(_selectedAssembly, _assemblyOptions,
          'Assembly', Icons.account_balance, (String? newValue) {
        setState(() => _selectedAssembly = newValue!);
      }));
    }

    formWidgets.addAll([
      TextFormField(
        controller: _electionStartTimeController,
        decoration: InputDecoration(
          labelText: 'Start Time',
          suffixIcon: Icon(Icons.timer), // Add icon
        ),
        onTap: () => _selectDateTime(_electionStartTimeController),
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
        readOnly: true, // Prevent keyboard from appearing
      ),
      TextFormField(
        controller: _electionEndTimeController,
        decoration: InputDecoration(
          labelText: 'End Time',
          suffixIcon: Icon(Icons.timer_off), // Add icon
        ),
        onTap: () => _selectDateTime(_electionEndTimeController),
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
        readOnly: true, // Prevent keyboard from appearing
      ),
      SizedBox(height: 20),
      ElevatedButton(
        onPressed: () => _createElection(authToken),
        child: Text('Create Election'),
      ),
      SizedBox(height: 20),
    ]);
    return Theme(
      data: ThemeData(
        buttonTheme: ButtonThemeData(
          buttonColor: Color.fromARGB(255, 145, 168, 39),
          textTheme: ButtonTextTheme.primary,
        ), // Sets the accent color locally
        // Define other local theme properties here
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Election'),
          backgroundColor: Colors.blueAccent,
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
}

Widget _buildTextField(TextEditingController controller, String labelText,
    IconData icon, String validationMessage,
    {bool readOnly = false, bool fullNameValidation = false}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon), // Add icon to the text field
      // Other decoration properties
    ),
    readOnly: readOnly,
    // Make the text field read-only based on the parameter
  );
}

Widget _buildDropdown(String? selectedValue, List<String> options, String label,
    IconData icon, ValueChanged<String?> onChanged) {
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


// Assuming you have a date picker for election start and end times
