import 'dart:typed_data';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';

const Color kErrorRed = Colors.redAccent;
const Color kDarkGray = Color(0xFFA3A3A3);
const Color kLightGray = Color(0xFFF1F0F5);

class CardSelect extends StatefulWidget {
  @override
  _CardSelectState createState() => _CardSelectState();
}

class _CardSelectState extends State<CardSelect> {
  var userid;
  var username2;
  var usertoken;
  var username;
  String endPoint = '';
  Dio dio = new Dio();
  var image;
  var _future;
  var content;

  Future getProfile() async {}

  void _upload(XFile file) async {
    String fileName = file.path.split('/').last;

    FormData data = FormData.fromMap({
      "photo": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
      "username": username2
    });

    var response = await dio.put(
      'http://10.0.2.2:8000/api/v1/User/$userid/',
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Token $usertoken' // set content-length
        },
      ),
    );
    setState(() {
      _future = _getImage();
    });
  }

  Future getImage() async {
    var picker = ImagePicker();
    image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      var futureImg = _upload(image);
    }
  }

  @override
  void initState() {
    super.initState();
    _future = _getImage();
  }

  Future _getImage() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    userid = await sharedPreferences.getInt('userID');
    usertoken = sharedPreferences.getString('token');
    username = sharedPreferences.getString('name');
    endPoint = 'http://10.0.2.2:8000/api/v1/User/$userid' + '/';
    print(userid);
    final response = await http.get(
      Uri.http('10.0.2.2:8000', "api/v1/User/$userid"),
    ); //
    if (response.statusCode == 200) {
      content = jsonDecode(utf8.decode(response.bodyBytes));
      username2 = content['username'];
      return content;
    } else {
      throw Exception('Failed to load post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('학생증 인증', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        iconTheme:IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          print(snapshot.data);
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (!snapshot.hasData) {
            return Container(
              child: Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.amber),
              )),
            );
          } else
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                if (content['photo'] == null)
                  Column(
                    children: [
                      Center(child: Text('학생증 사진을 찍어 업로드해주세요!\n민감한 개인정보는 가려서 올려주시기 바랍니다', style: TextStyle(fontWeight: FontWeight.bold),)),
                      SizedBox(height: 200,),
                      ElevatedButton(
                        onPressed:getImage,
                        child: Text('학생증 인증하기!', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),

                if (content['photo'] != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(content['photo'], width: 500, height: 200),
                  ),
                if (content['photo'] != null)
                  if (content['verified'] == false)
                    Column(
                      children: [
                        Text('학생증 검토중입니다...',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Strong')),
                        SizedBox(height:100),
                        ElevatedButton(
                          onPressed:getImage,
                          child: Text('학생증 사진 다시 찍기', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                if (content['photo'] != null)
                  if (content['verified'] == true)
                    Text('학생증 인증이 완료되었습니다!', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            );
        },
      ),

    );
  }
}
