import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../utils/auth_token.dart';
import '../../utils/constants.dart';
import 'package:facerecognition_flutter/model/ElectionResult.dart';

class ElectionResultsDetailsPage extends StatefulWidget {
  final String selectedElection;

  ElectionResultsDetailsPage(this.selectedElection);

  @override
  _ElectionResultsDetailsPageState createState() =>
      _ElectionResultsDetailsPageState();
}

class _ElectionResultsDetailsPageState
    extends State<ElectionResultsDetailsPage> {
  Future<List<ElectionResult>>? futureElectionResults;

  @override
  void initState() {
    super.initState();
    futureElectionResults = _fetchElectionResults(widget.selectedElection);
  }

  Future<List<ElectionResult>> _fetchElectionResults(
      String electionName) async {
    String authToken = Provider.of<AuthToken>(context, listen: false).token;
    final response = await http.get(
      Uri.parse('${APIConstants.baseUrl}/api/admin/results/$electionName'),
      headers: <String, String>{
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body);
      if (decodedJson != null) {
        List<ElectionResult> results = [];
        decodedJson.forEach((key, value) {
          results.add(ElectionResult.fromJson(key, value));
        });
        return results;
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load election results');
    }
  }

  Future<void> _generatePdf(List<ElectionResult> results) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Election Results: ${widget.selectedElection}',
                    style: pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: ['Candidate', 'Party', 'Votes'],
                  data: results
                      .map((result) => [
                            result.candidateName,
                            result.partyName,
                            result.votes.toString()
                          ])
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      if (downloadsDirectory != null) {
        final file = File(
            "${downloadsDirectory.path}/election_results_${widget.selectedElection}.pdf");
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to ${file.path}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get downloads directory')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Election Results: ${widget.selectedElection}'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              if (futureElectionResults != null) {
                final results = await futureElectionResults;
                if (results != null) {
                  _generatePdf(results);
                }
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ElectionResult>>(
        future: futureElectionResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Candidate')),
                  DataColumn(label: Text('Party')),
                  DataColumn(label: Text('Votes')),
                ],
                rows: snapshot.data!
                    .map(
                      (result) => DataRow(cells: [
                        DataCell(Text(result.candidateName)),
                        DataCell(Text(result.partyName)),
                        DataCell(Text(result.votes.toString())),
                      ]),
                    )
                    .toList(),
              ),
            );
          } else {
            return Center(child: Text('No data'));
          }
        },
      ),
    );
  }
}
