import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:http/http.dart' as http;
import 'package:meetingapp/Password.dart';
import 'package:meetingapp/setID.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomePage.dart';


class LoginResult extends StatefulWidget {
  @override
  _LoginResultState createState() => _LoginResultState();
}

class _LoginResultState extends State {
  bool _isLoading = false;
  TextEditingController passwordController = TextEditingController();
  TextEditingController nicknameController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  String _accountEmail = 'None';

  var _userid = 'None';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    checkAccount(_accountEmail);

  }
  String sentence = "로그인중입니다";
  checkAccount(String username) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final User user = await UserApi.instance.me();
    print(user.kakaoAccount);
    setState(() {
      _accountEmail = user.kakaoAccount!.email.toString();
      _userid = user.id.toString();
      print(_userid);
    });
    var response = await http.get(
      Uri.http(
          "10.0.2.2:8000",  "api/v1/User", {"username": "$_userid"}),
    );
    print(response.body);
    print('진행중');
    if (response.body == '[]') {
      print('신규');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SetID(userID: _userid),
          ));//신규가입일 때

      
    } else { //이미 가입됐을때
      print('이미 가입');
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => InputPassword(userID: _userid),
      ));
    }
  }


  Widget successText() {
    return Text(sentence);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: successText(),
        ),
      ),
    );
  }
}


