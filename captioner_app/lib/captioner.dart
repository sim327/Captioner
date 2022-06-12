import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class Captioner extends StatefulWidget {
  const Captioner({Key? key}) : super(key: key);

  @override
  State<Captioner> createState() => _CaptionerState();
}

class _CaptionerState extends State<Captioner> {
  final FlutterTts flutterTts = FlutterTts();
  bool _loading = true;
  late File _image;
  final picker = ImagePicker();
  String resultText = "Fetching Response...";

  speak() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(resultText);
  }

  pickImage() async {
    var image = await picker.pickImage(source: ImageSource.camera);
    print("got image");
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
      _loading = false;
    });
    var str = fetchResponse(_image);
    print("value is $str");
  }

  pickGalleryImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      print(File(image.path));
      _image = File(image.path);
      _loading = false;
    });
    var str = fetchResponse(_image);
    print("value is $str");
  }

  Future<Map<String, dynamic>> fetchResponse(File image) async {
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])!.split('/');
    final imageuploadRequest = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://max-image-caption-generator-simmi-simmiapirequest-dev.apps.sandbox-m2.ll9k.p1.openshiftapps.com/model/predict'),
    );

    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    imageuploadRequest.fields['ext'] = mimeTypeData[1];
    imageuploadRequest.files.add(file);
    try {
      final streamedResponse = await imageuploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      final Map<String, dynamic> responseData = json.decode(response.body);
      parseResponse(responseData);
      print(responseData);
      return responseData;
    } catch (e) {
      print(e);
      Map<String, dynamic> val = {};
      return val;
    }
  }

  void parseResponse(var response) {
    String r = "";
    var predictions = response['predictions'];
    for (var prediction in predictions) {
      var caption = prediction['caption'];
      var probability = prediction['probability'];
      r = r + "$caption\n\n";
      setState(() {
        resultText = r;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.004],
                colors: [Color(0x11232526)],
              ),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 48),
                    Text(
                      "Image Captioning ",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                      ),
                    ),
                    Text(
                      "Image to Caption Generator",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 30),
                    Container(
                      height: MediaQuery.of(context).size.height - 250,
                      padding: EdgeInsets.all(30),
                      decoration: BoxDecoration(
                          color: Color.fromARGB(78, 221, 216, 216),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7),
                          ]),
                      child: Column(children: <Widget>[
                        Center(
                            child: _loading
                                ? Container(
                                    width: 500,
                                    child: Column(
                                      children: [
                                        SizedBox(height: 30),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Column(
                                            children: [],
                                          ),
                                        ),
                                        SizedBox(height: 30),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                  onTap: pickGalleryImage,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6)),
                                                    // height: 250,
                                                    // width: 250,
                                                    child: Column(children: [
                                                      Icon(
                                                        Icons
                                                            .upload_file_outlined,
                                                        size: 100,
                                                      ),
                                                      Text("UPLOAD IMAGE")
                                                    ]),
                                                  ))
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 90),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                  onTap: pickImage,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6)),
                                                    child: Column(children: [
                                                      Icon(
                                                        Icons
                                                            .camera_enhance_outlined,
                                                        size: 100,
                                                      ),
                                                      Text("TAKE PICTURE")
                                                    ]),
                                                  ))
                                            ],
                                          ),
                                        )
                                      ],
                                    ))
                                : Container(
                                    padding: EdgeInsets.only(top: 18),
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          height: 200,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _loading = true;
                                                      resultText =
                                                          "Fetching Response...";
                                                    });
                                                  },
                                                  icon: Icon(
                                                      Icons.arrow_back_ios),
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    205,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.file(_image,
                                                      fit: BoxFit.fill),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        Container(
                                          child: Text(
                                            "$resultText",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            speak();
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                250,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 17),
                                            decoration: BoxDecoration(
                                              color: Colors.redAccent[400],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              "AUDIO",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )))
                      ]),
                    ),
                  ]),
            )));
  }
}
