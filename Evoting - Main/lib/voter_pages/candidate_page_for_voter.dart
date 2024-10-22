import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';
import '../../model/candidate.dart';
import '../../voter_pages/vote_saved_page.dart';

class ChooseCandidate extends StatefulWidget {
  final String voterId;
  final String aadhaarNumber;

  ChooseCandidate(
      {Key? key, required this.voterId, required this.aadhaarNumber})
      : super(key: key);

  @override
  _ChooseCandidatePageState createState() => _ChooseCandidatePageState();
}

class _ChooseCandidatePageState extends State<ChooseCandidate> {
  List<String> _candidates = []; // List to hold candidate names
  String? _selectedCandidate; // Variable to hold the selected candidate
  String _electionName = ""; // Variable to hold the election name
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchCandidatesAndElectionName();
  }

  Future<void> _fetchCandidatesAndElectionName() async {
    final String apiUrl = '${APIConstants.baseUrl}/voter/candidates';
    // Append the voterId and aadhaarNumber as query parameters
    // Ensure to handle the case where either voterId or aadhaarNumber might be null or empty
    final queryParams = {
      if (widget.voterId?.isNotEmpty == true) 'voterId': widget.voterId,
      if (widget.aadhaarNumber?.isNotEmpty == true)
        'aadhaarNumber': widget.aadhaarNumber, // Corrected parameter name here
    };
    final Uri fullUrl = Uri.parse(apiUrl).replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        fullUrl,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<Candidate> candidates = [];
        String electionName = '';
        data.forEach((key, value) {
          electionName = key;
          List<dynamic> candidatesJson = value;
          candidates.addAll(
              candidatesJson.map((e) => Candidate.fromJson(e)).toList());
        });
        setState(() {
          _candidates =
              candidates.map((c) => '${c.name} (${c.party})').toList();
          _electionName = electionName;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error occurred')),
      );
    }
  }

  Future<void> _saveVote() async {
    if (_selectedCandidate == null) return;

    // Extract candidate name from the selected candidate string
    final candidateName = _selectedCandidate!.split(' (').first;

    final String apiUrl = '${APIConstants.baseUrl}/voter/cast-vote';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'voterId': widget.voterId,
          'aadhaarNumber': widget.aadhaarNumber,
          'candidateName': candidateName,
          'electionName': _electionName,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vote saved successfully')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VoteSavedPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vote has been already given')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _electionName.isEmpty ? 'No Ongoing Elections' : _electionName),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _electionName.isEmpty
                ? Center(child: Text('No elections ongoing'))
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ..._candidates.map((candidate) => RadioListTile<String>(
                              title: Text(candidate),
                              value: candidate,
                              groupValue: _selectedCandidate,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCandidate = value;
                                });
                              },
                            )),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed:
                              _selectedCandidate == null ? null : _saveVote,
                          child: Text('Save Vote'),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
