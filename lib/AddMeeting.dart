import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:meetingapp/Meeting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
class addMeeting extends StatefulWidget {
  @override
  _addMeetingState createState() => _addMeetingState();
}

class _addMeetingState extends State<addMeeting> {
  TextEditingController descont = TextEditingController();
  TextEditingController loccont = TextEditingController();
  TextEditingController kakaocont = TextEditingController();
  var subtext = '카카오 아이디를 적어주세요';
  var selectedKakao = "아이디";
  var kakaoList = [
    "아이디",
    "오픈채팅"
  ];
  var selectedType = "2대2";
  var typeList = [
    "2대2",
    "3대3",
    "4대4",
    "1대1"
  ];
  var selectedLoc="서울";
  var locList = [
    "서울",
    "경기",
    "강원",
    "충북",
    "충남",
    "전북",
    "전남",
    "부산",
    "대구",
    "경북",
    "경남",

  ];
  @override
  void dispose() {
    descont.dispose();
    loccont.dispose();
    kakaocont.dispose();
    return super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('미팅 등록'),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black, size: 40),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                Center(
                  child: Text(
                    '미팅 등록을 위해 간단한 내용을 작성해주세요!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                Center(child: Text('아래 입력란을 완성해주세요')),
                SizedBox(height:30),
                Row(
                  children: [
                    Container(
                      child: Text('미팅 종류를 선택해주세요'),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Container(

                          child: DropdownButton(

                              value: selectedType,
                              items: typeList.map(
                                    (value) {
                                  return DropdownMenuItem(
                                      value: value, child: Text(value));
                                },
                              ).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedType = value.toString();

                                });
                              })),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      child: Text('미팅 장소를 선택해주세요'),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Container(

                          child: DropdownButton(

                              value: selectedLoc,
                              items: locList.map(
                                    (value) {
                                  return DropdownMenuItem(
                                      value: value, child: Text(value));
                                },
                              ).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedLoc = value.toString();
                                });
                              })),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      child: Text('미팅이 성사됐을 때 연락 방법은?'),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Container(

                          child: DropdownButton(

                              value: selectedKakao,
                              items: kakaoList.map(
                                    (value) {
                                  return DropdownMenuItem(
                                      value: value, child: Text(value));
                                },
                              ).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedKakao = value.toString();
                                  if (value.toString() == '아이디') {
                                    subtext = '카카오 아이디를 입력해주세요';
                                  }
                                  else {
                                    subtext = '오픈채팅 링크를 입력해주세요';
                                  }
                                });
                              })),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    controller: kakaocont,
                    decoration: InputDecoration(
                      hintText: subtext,
                      border: OutlineInputBorder(),
                      labelText: selectedKakao,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    maxLines: 10,

                    controller: descont,
                    decoration: InputDecoration(
                      hintText: '본인을 어필해봐요!',
                      border: OutlineInputBorder(),
                      labelText: '미팅 정보',
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      // foreground
                    ),
                    child: Text('완료'),
                    onPressed: () {
                      meetingPost();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void loading() {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(content: CircularProgressIndicator());
      },
    );
  }
  Future meetingPost() async{
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('미팅 생성'),
          content: Text('미팅을 업로드하시겠습니까?'),
          actions: <Widget>[
            FlatButton(
              child: Text('네'),
              onPressed: () async {
                Navigator.pop(context, "OK");
                loading();
                var shr = await SharedPreferences.getInstance();
                var owner = shr.getInt("userID");
                var now = new DateTime.now();
                now = now.add(Duration(hours: 9));
                bool kakaotype;
                if (selectedKakao == '아이디')  kakaotype = true;
                else kakaotype = false;
                var body = {
                  "create_dt" :  DateFormat("yyyy-MM-ddTHH:mm:ss").format(now),
                  "type" : selectedType,
                  "location" : selectedLoc,
                  "description" : descont.text,
                  "locdetaio" : loccont.text,
                  "owner" : owner.toString(),
                  "kakao" : kakaocont.text,
                  "kakaotype" : kakaotype.toString(),
                };
                var response =  await http.post(Uri.http(
                  "10.0.2.2:8000",  "api/v1/MeetingWrite/", ), body: body
                );
                print(response.body);
                if (response.statusCode == 201) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  setState(() {

                  });
                }


              },
            ),
            FlatButton(
              child: Text('아니오'),
              onPressed: () {
                Navigator.pop(context, "Cancel");
              },
            ),
          ],
        );
      },
    );


  }
}
