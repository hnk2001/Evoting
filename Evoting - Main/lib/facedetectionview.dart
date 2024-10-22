import 'dart:async';
import 'dart:io';
import 'package:facerecognition_flutter/voter_pages/authentication_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:facesdk_plugin/facedetection_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:facesdk_plugin/facesdk_plugin.dart';
import 'person.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class FaceRecognitionView extends StatefulWidget {
  final List<Person> personList;
  FaceDetectionViewController? faceDetectionViewController;

  String voterId;
  final String aadhaarNumber;

  FaceRecognitionView({
    super.key,
    required this.personList,
    required this.voterId,
    required this.aadhaarNumber,
  });

  @override
  State<StatefulWidget> createState() => FaceRecognitionViewState();
}

class FaceRecognitionViewState extends State<FaceRecognitionView> {
  dynamic _faces;
  double _livenessThreshold = 0;
  double _identifyThreshold = 0;
  bool _recognized = false;
  String _identifiedName = "";
  String _identifiedSimilarity = "";
  var _identifiedFace;
  var _enrolledFace;
  final _facesdkPlugin = FacesdkPlugin();
  FaceDetectionViewController? faceDetectionViewController;

  @override
  void initState() {
    super.initState();
    loadSettings();
    fetchVoterId();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String? livenessThreshold = prefs.getString("liveness_threshold");
    String? identifyThreshold = prefs.getString("identify_threshold");
    setState(() {
      _livenessThreshold = double.parse(livenessThreshold ?? "0.7");
      _identifyThreshold = double.parse(identifyThreshold ?? "0.8");
    });
  }

  Future<void> fetchVoterId() async {
    if (widget.aadhaarNumber.isNotEmpty && widget.voterId.isEmpty) {
      try {
        String? voterId = await fetchVoterIdByAadhaar(widget.aadhaarNumber);
        setState(() {
          widget.voterId = voterId ?? '';
        });
        print(widget.voterId);
      } catch (e) {
        print('Failed to fetch voter ID: $e');
      }
    }
  }

  Future<String?> fetchVoterIdByAadhaar(String aadhaarNumber) async {
    final String apiUrl =
        '${APIConstants.baseUrl}/voter/get-voterId/$aadhaarNumber';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load voter ID');
    }
  }

  Future<void> faceRecognitionStart() async {
    final prefs = await SharedPreferences.getInstance();
    var cameraLens = prefs.getInt("camera_lens");

    setState(() {
      _faces = null;
      _recognized = false;
    });

    await faceDetectionViewController?.startCamera(cameraLens ?? 1);
  }

  Future<bool> onFaceDetected(faces) async {
    if (_recognized == true) {
      return false;
    }

    if (!mounted) return false;

    setState(() {
      _faces = faces;
    });

    bool recognized = false;
    double maxSimilarity = -1;
    String maxSimilarityName = "";
    double maxLiveness = -1;
    var enrolledFace, identifedFace;

    if (faces.length > 0) {
      var face = faces[0];
      for (var person in widget.personList) {
        double similarity = await _facesdkPlugin.similarityCalculation(
              face['templates'],
              person.templates,
            ) ??
            -1;

        if (maxSimilarity < similarity) {
          maxSimilarity = similarity;
          maxSimilarityName = person.name;
          maxLiveness = face['liveness'];
          identifedFace = face['faceJpg'];
          enrolledFace = person.faceJpg;
        }
      }

      if (maxSimilarity > _identifyThreshold &&
          maxLiveness > _livenessThreshold &&
          widget.voterId == maxSimilarityName) {
        recognized = true;
      }
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return false;
      setState(() {
        _recognized = recognized;
        _identifiedName = maxSimilarityName;
        _identifiedSimilarity = maxSimilarity.toString();
        _enrolledFace = enrolledFace;
        _identifiedFace = identifedFace;
      });

      if (recognized) {
        faceDetectionViewController?.stopCamera();
        setState(() {
          _faces = null;
        });
      }
    });

    return recognized;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        faceDetectionViewController?.stopCamera();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 82, 96, 177),
          title: const Text('Face Recognition'),
          toolbarHeight: 70,
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            FaceDetectionView(faceRecognitionViewState: this),
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: FacePainter(
                  faces: _faces,
                  livenessThreshold: _livenessThreshold,
                ),
              ),
            ),
            Visibility(
              visible: _recognized,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Theme.of(context).colorScheme.background,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _enrolledFace != null
                            ? Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.memory(
                                      _enrolledFace,
                                      width: 160,
                                      height: 160,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text('Enrolled'),
                                ],
                              )
                            : const SizedBox(height: 1),
                        _identifiedFace != null
                            ? Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.memory(
                                      _identifiedFace,
                                      width: 160,
                                      height: 160,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text('Identified'),
                                ],
                              )
                            : const SizedBox(height: 1),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        Text(
                          'VoterId: $_identifiedName',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        Text(
                          'Similarity: $_identifiedSimilarity',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 90, 103, 177),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuthenticationScreen(
                              voterId: widget.voterId,
                              aadhaarNumber: widget.aadhaarNumber,
                            ),
                          ),
                        );
                      },
                      child: Text('Authentication'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FaceDetectionView extends StatefulWidget
    implements FaceDetectionInterface {
  FaceRecognitionViewState faceRecognitionViewState;

  FaceDetectionView({super.key, required this.faceRecognitionViewState});

  @override
  Future<void> onFaceDetected(faces) async {
    await faceRecognitionViewState.onFaceDetected(faces);
  }

  @override
  State<StatefulWidget> createState() => _FaceDetectionViewState();
}

class _FaceDetectionViewState extends State<FaceDetectionView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'facedetectionview',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      return UiKitView(
        viewType: 'facedetectionview',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
  }

  void _onPlatformViewCreated(int id) async {
    final prefs = await SharedPreferences.getInstance();
    var cameraLens = prefs.getInt("camera_lens");

    widget.faceRecognitionViewState.faceDetectionViewController =
        FaceDetectionViewController(id, widget);

    await widget.faceRecognitionViewState.faceDetectionViewController
        ?.initHandler();

    int? livenessLevel = prefs.getInt("liveness_level");
    await widget.faceRecognitionViewState._facesdkPlugin
        .setParam({'check_liveness_level': livenessLevel ?? 0});

    await widget.faceRecognitionViewState.faceDetectionViewController
        ?.startCamera(cameraLens ?? 1);
  }
}

class FacePainter extends CustomPainter {
  dynamic faces;
  double livenessThreshold;
  FacePainter({required this.faces, required this.livenessThreshold});

  @override
  void paint(Canvas canvas, Size size) {
    if (faces != null) {
      var paint = Paint();
      paint.color = const Color.fromARGB(0xff, 0xff, 0, 0);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;

      for (var face in faces) {
        double xScale = face['frameWidth'] / size.width;
        double yScale = face['frameHeight'] / size.height;

        String title = "";
        Color color = const Color.fromARGB(0xff, 0xff, 0, 0);
        if (face['liveness'] < livenessThreshold) {
          color = const Color.fromARGB(0xff, 0xff, 0, 0);
          title = "Spoof" + face['liveness'].toString();
        } else {
          color = const Color.fromARGB(0xff, 0, 0xff, 0);
          title = "Real " + face['liveness'].toString();
        }

        TextSpan span =
            TextSpan(style: TextStyle(color: color, fontSize: 20), text: title);
        TextPainter tp = TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(face['x1'] / xScale, face['y1'] / yScale - 30));

        paint.color = color;
        canvas.drawRect(
            Offset(face['x1'] / xScale, face['y1'] / yScale) &
                Size((face['x2'] - face['x1']) / xScale,
                    (face['y2'] - face['y1']) / yScale),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
