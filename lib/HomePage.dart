import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Meeting.dart';
import 'MyMeeting.dart';
import 'kakaologin.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var sharedPreferences;
  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") != null) {
      username = sharedPreferences.getString("name");
    }

  }

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    _initKakaoTalkInstalled();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Title(),
          Meeting(),
          MyMeeting(),
        ],
      ),

    );
  }

  var username;
  bool _isLoading = false;
  String msg = '.';
  bool _isKakaoTalkInstalled = false;

  _initKakaoTalkInstalled() async {
    final installed = await isKakaoTalkInstalled();
    print('kakao Install : ' + installed.toString());

    setState(() {
      _isKakaoTalkInstalled = installed;
    });
  }
  _issueAccessToken(String authCode) async {
    try {
      print('1212');
      var token = await AuthApi.instance.issueAccessToken(authCode);
      AccessTokenStore.instance.toStore(token);
      print('ass${token}');
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginResult(),
          ));
    } catch (e) {
      print(e.toString());
    }
  }

  _loginWithKakao() async {
    print('3');
    try {
      var code = await AuthCodeClient.instance.request();
      await _issueAccessToken(code);
      print(code);
    } catch (e) {
      print('카카오로그인' + e.toString());
    }
  }

  _loginWithTalk() async {
    print('1');
    try {
      var code = await AuthCodeClient.instance.requestWithTalk();
      print('코드'+code);
      await _issueAccessToken(code);
    } catch (e) {
      print('실패'+e.toString());
    }
  }



  Widget Title () {
    return Container(
      child: Center(child: Text('미팅대학교')),
    );
  }
  Widget Meeting() {
    return Container(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Color.fromARGB(255, 187, 222, 251),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MeetingTab(),
                  ),
                );
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      child: Material(
                        child: InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.meeting_room,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    '미팅 구하기!',
                    style: TextStyle(
                        fontFamily: 'Strong',
                        fontSize: 30,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget MyMeeting() {
    return Container(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Color.fromARGB(255, 187, 222, 251),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyMeetingList(),
                  ),
                );
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      child: Material(
                        child: InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.person_outline,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    '내 미팅',
                    style: TextStyle(
                        fontFamily: 'Strong',
                        fontSize: 30,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ));
  }


  Widget CustomDrawer() {
    return Drawer(
      // 리스트뷰 추가
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // 드로워해더 추가
          Container(
            height: 300,
            child: DrawerHeader(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (username == null)
                      Row(
                        children: [
                          Text(
                            '비회원',
                            style: TextStyle(
                                fontFamily: 'gyeongi',
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Container(
                            child: Text(
                              username,
                              style: TextStyle(
                                  fontFamily: 'gyeongi',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),

                    SizedBox(
                      height: 20,
                    ),
                    if (username == null)
                      TextButton(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(3, 5, 3, 5),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.rectangle,
                            border: Border.all(width: 1.0, color: Colors.white),
                            borderRadius:
                            BorderRadius.all(Radius.circular(30.0)),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              "로그인",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        onPressed: () {
                          print(_isKakaoTalkInstalled);
                          if (_isKakaoTalkInstalled)
                            _loginWithTalk();
                          else
                            _loginWithKakao();

                        },
                      ),

                    if (username != null)
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(50, 30),
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Dialog(

                                child: Container(
                                  padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      new CircularProgressIndicator(),
                                      SizedBox(width: 20,),
                                      new Text("로그아웃중"),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                          sharedPreferences.clear();
                          sharedPreferences.commit();
                          username = null;

                          new Future.delayed(new Duration(seconds: 1), () {
                            //pop dialog
                            setState(() {});
                            Navigator.pop(context);
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          margin: EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            color: FlexColor.redLightPrimary,
                            shape: BoxShape.rectangle,
                            border: Border.all(width: 1.0, color: Colors.white),
                            borderRadius:
                            BorderRadius.all(Radius.circular(20.0)),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              "로그아웃",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    //프로필 가기
                  ],
                ),
              ),
              decoration: BoxDecoration(color: Colors.black26),
            ),
          ),
          // 리스트타일 추가

        ],
      ),
    );
  }
}
