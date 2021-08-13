import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_dropdown_alert/dropdown_alert.dart';
import 'package:meetingapp/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetID extends StatefulWidget {
  final String userID;

  const SetID({Key? key, required this.userID}) : super(key: key);

  @override
  _SetIDState createState() => _SetIDState();
}

class _SetIDState extends State<SetID> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController schoolController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  var sharedPreferences;
  var _isloading = false;
  final genderList = ['남', '여'];
  var selectedgender = '남';

  getShared() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    getShared();
  }

  @override
  Widget build(BuildContext context) {
    if (_isloading == true) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    } else
      return Scaffold(
        appBar: AppBar(
          title: Text('회원가입'),
        ),
        body: SafeArea(
          child: Center(
            child: ListView(
              children: [
                Center(
                  child: Text(
                    '카카오계정으로 가입중입니다',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 50),
                Center(child: Text('아래 입력란을 완성해주세요')),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    maxLength: 5,
                    inputFormatters: [
                      new FilteringTextInputFormatter.allow(
                          RegExp('[a-zA-Z0-9ㄱ-ㅎ가-힣ㆍᆢ]')),
                    ],
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: '(한글 영어 숫자 가능, 5자 이내)',
                      border: OutlineInputBorder(),
                      labelText: '닉네임',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    maxLength: 2,
                    inputFormatters: [
                      new FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                    ],
                    controller: ageController,
                    decoration: InputDecoration(
                      hintText: '나이',
                      border: OutlineInputBorder(),
                      labelText: '나이',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                  child: Container(

                      child: DropdownButton(

                          value: selectedgender,
                          items: genderList.map(
                            (value) {
                              return DropdownMenuItem(
                                  value: value, child: Text(value));
                            },
                          ).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedgender = value.toString();
                            });
                          })),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    maxLength: 7,
                    inputFormatters: [
                      new FilteringTextInputFormatter.allow(
                          RegExp('[a-zA-Z0-9ㄱ-ㅎ가-힣ㆍᆢ]')),
                    ],
                    controller: schoolController,
                    decoration: InputDecoration(
                      hintText: '학교',
                      border: OutlineInputBorder(),
                      labelText: '학교',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: '비밀번호',
                      border: OutlineInputBorder(),
                      labelText: '비밀번호',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordConfirmController,
                    decoration: InputDecoration(
                      hintText: '비밀번호 확인',
                      border: OutlineInputBorder(),
                      labelText: '비밀번호 확인',
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    // foreground
                  ),
                  child: Text('완료'),
                  onPressed: () {
                    _isloading = true;
                    if (passwordController.text ==
                        passwordConfirmController.text)
                      register();
                    else {
                      setState(() {
                        _isloading = false;
                      });
                      AlertController.show(
                          "비밀번호 틀림", "비밀번호와 비밀번호 확인이 일치하지 않습니다!",
                          TypeAlert.success);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
  }

  register() async {
    Map body = {
      "username": widget.userID,
      "password": passwordController.text,
      "age": ageController.text,
      "school": schoolController.text,
      "name": nameController.text,
      "photo": "",
      "gender": selectedgender.toString()
    };
    var responsee =
        await http.post(Uri.http("10.0.2.2:8000", "api/v2/users/"), body: body);
    if (responsee.statusCode == 201) {
      //계정 생성 성공
      var user= json.decode(responsee.body);

      var responselogin = await http
          .post(Uri.http("10.0.2.2:8000", "api/v2/token/login/"), body: {
        "username": widget.userID,
        "password": passwordController.text
      });
      var jsonLogin = json.decode(responselogin.body);

      var token = jsonLogin['auth_token'];
      print(jsonLogin);
      setState(() {
        _isloading = false;
        sharedPreferences.setString("token", token);
        sharedPreferences.setString("name", user['name'].toString());
        sharedPreferences.setInt('userID', user['id']);
        sharedPreferences.setString('verified', user['verified'].toString());
        sharedPreferences.setString('school', user['school'].toString());
        sharedPreferences.setInt('age', user['age']);
      });
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ));
    }
    else{

    }
  }
}
