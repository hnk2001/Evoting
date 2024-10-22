import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:provider/provider.dart';
import '../../utils/auth_token.dart';
import '../../utils/constants.dart';

class ElectionData {
  final double percentage;

  ElectionData(this.percentage);

  factory ElectionData.fromJson(double json) {
    return ElectionData(json);
  }
}

class ElectionPercentageDetailsPage extends StatefulWidget {
  final String electionName;

  ElectionPercentageDetailsPage({required this.electionName});

  @override
  _ElectionPercentageDetailsPageState createState() =>
      _ElectionPercentageDetailsPageState();
}

class _ElectionPercentageDetailsPageState
    extends State<ElectionPercentageDetailsPage> {
  List<ElectionData> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchElectionData();
  }

  Future<void> fetchElectionData() async {
    String authToken = Provider.of<AuthToken>(context, listen: false).token;
    try {
      final response = await http.get(
        Uri.parse(
            '${APIConstants.baseUrl}/api/admin/percentage/${widget.electionName}'),
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final double percentage = json.decode(response.body);
        setState(() {
          data = [ElectionData.fromJson(percentage)];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load election percentages');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch data: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<charts.Series<ElectionData, String>> series = [
      charts.Series(
        id: 'Percentage',
        data: data,
        domainFn: (_, index) => index.toString(), // Use index as domain
        measureFn: (ElectionData series, _) => series.percentage,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      )
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Election Percentages')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? Center(child: Text('No data available'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Expanded(child: charts.BarChart(series, animate: true)),
                      SizedBox(height: 16),
                      Text(
                        ' ${widget.electionName}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
    );
  }
}
