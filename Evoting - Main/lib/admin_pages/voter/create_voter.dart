import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/auth_token.dart';
import '../../utils/constants.dart';
import '../../face_enroll.dart';

class CreateVoterPage extends StatefulWidget {
  @override
  _CreateVoterPageState createState() => _CreateVoterPageState();
}

class _CreateVoterPageState extends State<CreateVoterPage> {
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _dateOfBirth;
  XFile? _voterImage;
  XFile? _aadhaarImage;
  List<TextEditingController> _controllers = [];

  // Initialize all TextEditingControllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _wardNoController = TextEditingController();
  final TextEditingController _cityOrVillageController =
      TextEditingController();
  final TextEditingController _talukaController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _voterIdController = TextEditingController();
  final TextEditingController _aadhaarNumberController =
      TextEditingController();

  String? _selectedGender;
  final List<String> _genderOptions = ['Male', 'Female', 'Third Gender'];
  String _selectedCountry = 'India';
  final List<String> _countryOptions = ['India'];

  @override
  void initState() {
    super.initState();
    _controllers = [
      _firstNameController,
      _middleNameController,
      _lastNameController,
      _dateOfBirthController,
      _contactNumberController,
      _houseNoController,
      _wardNoController,
      _cityOrVillageController,
      _talukaController,
      _pincodeController,
      _districtController,
      _stateController,
      _voterIdController,
      _aadhaarNumberController,
    ];
    _voterImage;
    _aadhaarImage;
  }

  @override
  void dispose() {
    // Dispose all controllers to avoid memory leaks
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, bool isVoterImage) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      // Check the file size
      File imageFile = File(image.path);
      int fileSize = await imageFile.length();
      // 256KB = 256 * 1024 bytes
      if (fileSize <= 256 * 1024) {
        setState(() {
          if (isVoterImage) {
            _voterImage = image;
          } else {
            _aadhaarImage = image;
          }
        });
      } else {
        // Show an alert or a Snackbar if the image exceeds the size limit
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Image size exceeds 256KB limit. Please choose a smaller image.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createVoter(String authToken) async {
    final String apiUrl = '${APIConstants.baseUrl}/api/admin/create/voter';

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
      ..headers.addAll({
        'Authorization': 'Bearer $authToken',
      })
      ..fields['firstName'] = _firstNameController.text
      ..fields['middleName'] = _middleNameController.text
      ..fields['lastName'] = _lastNameController.text
      ..fields['dateOfBirth'] = _dateOfBirthController.text
      ..fields['gender'] = _selectedGender!
      ..fields['contactNumber'] = _contactNumberController.text
      ..fields['houseNoFlatNo'] = _houseNoController.text
      ..fields['areaOrWardNo'] = _wardNoController.text
      ..fields['cityOrVillage'] = _cityOrVillageController.text
      ..fields['taluka'] = _talukaController.text
      ..fields['pincode'] = _pincodeController.text
      ..fields['district'] = _districtController.text
      ..fields['state'] = _stateController.text
      ..fields['country'] = _selectedCountry
      ..fields['aadhaarNumber'] = _aadhaarNumberController.text
      ..fields['voterId'] = _voterIdController.text;

    // Add images if they are selected
    if (_voterImage != null) {
      request.files.add(
          await http.MultipartFile.fromPath('voterImage', _voterImage!.path));
    }
    if (_aadhaarImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'aadhaarImage', _aadhaarImage!.path));
    }

    try {
      // Send the request
      var streamedResponse = await request.send();

      // Listen for response
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        // Successfully created voter
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voter created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Wait for the SnackBar to display before navigating
        Navigator.pop(context);
      } else {
        // Failed to create voter, show error message
        var responseBody = jsonDecode(response.body);
        String errorMessage =
            responseBody['message'] ?? 'Failed to create voter';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    String authToken = Provider.of<AuthToken>(context).token;

    return Scaffold(
      appBar: AppBar(
          title: Text('Create Voter'),
          backgroundColor: Color.fromARGB(255, 107, 105, 0)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _buildTextField(
                    _firstNameController, 'First Name', Icons.person,
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'First name cannot be empty';
                  }
                  return null;
                }),
                _buildTextField(
                    _middleNameController, 'Middle Name', Icons.person_outline),
                _buildTextField(
                    _lastNameController, 'Last Name', Icons.person_outline),
                _buildDatePicker(
                    context, 'Date of Birth', Icons.calendar_today),
                _buildDropdown(_selectedGender, _genderOptions, 'Gender',
                    Icons.transgender, (String? newValue) {
                  setState(() => _selectedGender = newValue);
                }),
                _buildTextField(
                    _contactNumberController, 'Mobile Number', Icons.phone,
                    keyboardType: TextInputType.phone,
                    maxLength: 10, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contact number cannot be empty';
                  }
                  return null;
                }),
                _buildTextField(_houseNoController, 'House Number', Icons.home),
                _buildTextField(
                    _wardNoController, 'Area/Ward No.', Icons.location_city),
                _buildTextField(_cityOrVillageController, 'City/Village',
                    Icons.location_on),
                _buildTextField(_talukaController, 'Taluka', Icons.map),
                _buildTextField(_pincodeController, 'Pincode', Icons.pin_drop,
                    keyboardType: TextInputType.number,
                    maxLength: 6, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pincode cannot be empty';
                  }
                  return null;
                }),
                _buildTextField(
                    _districtController, 'District', Icons.location_city),
                _buildTextField(_stateController, 'State', Icons.map),
                _buildDropdown(
                    _selectedCountry, _countryOptions, 'Country', Icons.flag,
                    (String? newValue) {
                  setState(() => _selectedCountry = newValue!);
                }),
                _buildTextField(
                    _voterIdController, 'Voter Id', Icons.credit_card,
                    keyboardType: TextInputType.text,
                    maxLength: 10, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Invalid Voter ID';
                  }
                  return null;
                }),
                _buildTextField(_aadhaarNumberController, 'Aadhaar Number',
                    Icons.fingerprint,
                    keyboardType: TextInputType.number,
                    maxLength: 12, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Invalid Aadhaar Number';
                  }
                  return null;
                }),
                _imageField('Voter Image', _voterImage,
                    () => _pickImage(ImageSource.gallery, true)),
                _imageField('Aadhaar Image', _aadhaarImage,
                    () => _pickImage(ImageSource.gallery, false)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to another page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyHomePage(
                              title: 'Face Image',
                              voterId: _voterIdController)),
                    );
                  },
                  child: Text('Add Face'),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 107, 105, 0),
                    onPrimary: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _createVoter(authToken);
                    }
                  },
                  child: Text('Create Voter'),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 107, 105, 0), // Button color
                    onPrimary: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text,
      int maxLength = TextField.noMaxLength,
      FormFieldValidator<String>? validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      keyboardType: keyboardType,
      maxLength: maxLength != TextField.noMaxLength ? maxLength : null,
      validator: validator,
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, IconData icon) {
    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _dateOfBirth ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null && pickedDate != _dateOfBirth) {
          setState(() {
            _dateOfBirth = pickedDate;
            _dateOfBirthController.text =
                DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: _dateOfBirthController,
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
        ),
      ),
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

  Widget _imageField(String label, XFile? image, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: image != null
                ? Image.file(File(image.path), fit: BoxFit.cover)
                : Icon(Icons.camera_alt, color: Colors.grey[700]),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
