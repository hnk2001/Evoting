import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';
import '../../utils/auth_token.dart';
import 'package:provider/provider.dart';

class UpdateAdminPage extends StatefulWidget {
  @override
  _UpdateAdminPageState createState() => _UpdateAdminPageState();
}

class _UpdateAdminPageState extends State<UpdateAdminPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<TextEditingController> _controllers = [];

  final TextEditingController _adminUsernameController =
      TextEditingController();
  final TextEditingController _adminPasswordController =
      TextEditingController();
  final TextEditingController _adminFullNameController =
      TextEditingController();
  final TextEditingController _adminMobileController = TextEditingController();
  final TextEditingController _adminEmailController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _cityOrVillageController =
      TextEditingController();
  final TextEditingController _talukaController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  String _selectedCountry = 'India';
  final List<String> _countryOptions = ['India'];

  // final List<String> _roles = ['CENTRAL', 'STATE', 'DISTRICT'];
  // String? _selectedRole;
  @override
  void initState() {
    super.initState();
    _controllers = [
      _adminUsernameController,
      _adminPasswordController,
      _adminFullNameController,
      _adminMobileController,
      _adminEmailController,
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
    // Dispose all controllers to avoid memory leaks
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _fetchAdminDetails(String authToken, String id) async {
    final String apiUrl = '${APIConstants.baseUrl}/api/admin/getById/$id';

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
        _adminUsernameController.text = data['username'];
        _adminFullNameController.text = data['fullName'];
        _adminMobileController.text = data['mobile'];
        _adminEmailController.text = data['email'];
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
        SnackBar(content: Text('Failed to fetch admin details')),
      );
    }
  }

  Future<void> _updateAdmin(String authToken, String email) async {
    final String apiUrl =
        '${APIConstants.baseUrl}/api/admin/updateByEmail/$email';

    try {
      http.Response response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(<String, dynamic>{
          'username': _adminUsernameController.text,
          'password': _adminPasswordController.text,
          'fullName': _adminFullNameController.text,
          'mobile': _adminMobileController.text,
          'email': _adminEmailController.text,
          // 'role': _selectedRole,
          'houseNoFlatNo': _houseNoController.text,
          'cityOrVillage': _cityOrVillageController.text,
          'taluka': _talukaController.text,
          'pincode': _pincodeController.text,
          'district': _districtController.text,
          'state': _stateController.text,
          'country': _selectedCountry,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Admin updated successfully'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update admin'),
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
          title: const Text('Update Admin'),
          backgroundColor:
              Color.fromARGB(255, 0, 144, 180), // Admin theme color
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildTextField(
                    _adminEmailController,
                    'Enter Id',
                    Icons.account_circle,
                    'Please enter Admin Id',
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _fetchAdminDetails(authToken, _adminEmailController.text);
                    },
                    child: Text('Fetch Admin Details'),
                    style: ElevatedButton.styleFrom(
                      primary:
                          Color.fromARGB(255, 17, 103, 153), // Button color
                      onPrimary: Colors.white,
                    ),
                  ),
                  _buildTextField(_adminUsernameController, 'Username',
                      Icons.person, 'Please enter username'),
                  _buildTextField(
                    _adminPasswordController,
                    'Password',
                    Icons.lock,
                    'Please enter password',
                    isPassword: true,
                  ),
                  _buildTextField(_adminFullNameController, 'Full Name',
                      Icons.account_circle, 'Please enter full name',
                      fullNameValidation: true),
                  _buildTextField(_adminMobileController, 'Mobile Number',
                      Icons.phone, 'Please enter mobile number',
                      isMobile: true),
                  _buildTextField(_adminEmailController, 'Email Id',
                      Icons.email, 'Please enter email id',
                      isEmail: true, enabled: false),
                  _buildTextField(
                    _houseNoController,
                    'House Number',
                    Icons.home,
                    'Please enter House number',
                  ),
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
                  _buildDropdown(
                      _selectedCountry, _countryOptions, 'Country', Icons.flag,
                      (String? newValue) {
                    setState(() => _selectedCountry = newValue!);
                  }),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updateAdmin(authToken, _adminEmailController.text);
                        // Navigate to the VoterPage or show a success message
                      }
                    },
                    child: Text('Update Admin'),
                    style: ElevatedButton.styleFrom(
                      primary:
                          Color.fromARGB(255, 17, 103, 153), // Button color
                      onPrimary: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildTextField(TextEditingController controller, String label,
    IconData icon, String validationMessage,
    {TextInputType keyboardType = TextInputType.text,
    int maxLength = TextField.noMaxLength,
    bool isPassword = false,
    bool fullNameValidation = false,
    bool isMobile = false,
    bool isEmail = false,
    bool enabled = false}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
    ),
    obscureText: isPassword,
    keyboardType: isMobile ? TextInputType.phone : TextInputType.text,
    // keyboardType: keyboardType,
    maxLength: maxLength != TextField.noMaxLength ? maxLength : null,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return validationMessage;
      }
      if (fullNameValidation) {
        var names = value.trim().split(' ');
        if (names.length != 3) {
          return 'Full name must contain three names';
        }
      }
      if (isMobile) {
        if (value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
          return 'Please enter a valid 10-digit mobile number';
        }
      }
      if (isEmail) {
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
      }
      return null;
    },
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
