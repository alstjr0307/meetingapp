import 'dart:convert';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingDetail extends StatefulWidget {
  final int index;

  const MeetingDetail({Key? key, required this.index}) : super(key: key);

  @override
  _MeetingDetailState createState() => _MeetingDetailState();
}

class _MeetingDetailState extends State<MeetingDetail> {
  late Future _future;
  var userid;
  var usertoken;
  var username;
  var content;
  bool _isloading = false;

  Future getProfile() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    userid = sharedPreferences.getInt('userID');
    usertoken = sharedPreferences.getString('token');
    username = sharedPreferences.getString('name');
  }

  @override
  void initState() {
    print(widget.index);
    getProfile();
    super.initState();
    _future = getMeetingData(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(body: Center(child: Text('미팅이 존재하지 않습니다')));
          } else if (!snapshot.hasData) {
            return Container(
              child: Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.amber),
              )),
            );
          } else {
            final meetingdata = snapshot.data as Map;

            final courseAge = Container(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Icon(Icons.cake),
                  new Text(
                    meetingdata['age'].toString() + '세',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
            Widget meetingStatus() {
              if (meetingdata['owner'] == userid) {
                return Text(
                  '나의 미팅',
                  style: TextStyle(
                      fontSize: 20, fontFamily: 'Strong', color: Colors.white),
                );
              }
              if (meetingdata['partner'] == null) {
                return Text(
                  '모집 중',
                  style: TextStyle(
                      color: Colors.green, fontSize: 20, fontFamily: 'Strong'),
                );
              } else
                return Text(
                  '마감',
                  style: TextStyle(
                      color: Colors.red, fontSize: 20, fontFamily: 'Strong'),
                );
            }

            final courseType = Container(
              padding: const EdgeInsets.all(4.0),
              decoration: new BoxDecoration(
                  border: new Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(5.0)),
              child: new Text(
                meetingdata['type'],
                style: TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            );
            final courseVerified = Container(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  if (meetingdata['verified'] == true)
                    Icon(Icons.verified_user, color: Colors.white,),
                  if(meetingdata['verified'] != true) Icon(Icons.dangerous, color: Colors.white,),
                  new Text((() {
                    if (meetingdata['verified'] == true) {
                      return '인증된 회원입니다';
                    }
                    return "인증되지 않은 회원입니다";
                  })(), style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            );

            final topContentText = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 120.0),
                meetingStatus(),
                Container(
                  width: 90.0,
                  child: new Divider(color: Colors.green),
                ),
                SizedBox(height: 10.0),
                Text(
                  meetingdata['school'],
                  style: TextStyle(color: Colors.white, fontSize: 45.0),
                ),
                SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(flex: 2, child: courseAge),
                    Expanded(
                        flex: 6,
                        child: Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Row(
                              children: [
                                Icon(Icons.person),
                                Text(
                                  meetingdata['writer'],
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ))),
                    Expanded(flex: 2, child: courseType)
                  ],
                ),
                SizedBox(height: 40.0),
                courseVerified,
              ],
            );

            return Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.55,
                        padding: EdgeInsets.all(20.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(126, 33, 44, 1.0)),
                        child: Center(
                          child: topContentText,
                        ),
                      ),
                      Positioned(
                        left: 8.0,
                        top: 60.0,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      if (meetingdata['owner'] == userid)
                        Positioned(
                          right: 8,
                          top: 60.0,
                          child: Container(
                            child: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _delete();
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              child: Center(
                                  child: Text(
                                '"' + meetingdata['description'] + '"',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              )),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        if (meetingdata['partner'] != null &&
                            (meetingdata['owner'] != userid &&
                                meetingdata['partner']['id'] !=
                                    userid)) //다른사람 미팅, 마감됨, 선택안됨
                          Center(child: Text('이미 마감된 미팅입니다 ㅠ')),
                        if (userid != null &&
                            !meetingdata['hubos'].contains(userid) &&
                            meetingdata['owner'] != userid &&
                            meetingdata['partner'] ==
                                null) //다른사람 미팅, 마감 안됨, 신청 안함
                          Center(
                            child: Container(
                              child: TextButton(
                                child: Text(
                                  '미팅 해요!',
                                  style: TextStyle(
                                      fontFamily: 'gyeongi',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  _postdata(true);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  primary: Colors.blue,
                                  onSurface: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        if (meetingdata['hubos'].contains(userid) &&
                            meetingdata['owner'] !=
                                userid) //다른사람 미팅, 마감 안됨, 신청 함
                          Center(
                            child: Container(
                              child: TextButton(
                                child: Text(
                                  '신청 취소',
                                  style: TextStyle(
                                      fontFamily: 'gyeongi',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  _postdata(false);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  primary: Colors.blue,
                                  onSurface: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        if (meetingdata['hubos'].toString() == '[]' &&
                            meetingdata['partner'] == null &&
                            meetingdata['owner'] ==
                                userid) //본인 미팅, 신청자 없음, 마감 안됨
                          Center(
                            child: Text('아직 신청자가 없네요~! 좀 더 기다려봐요'),
                          ),
                        SizedBox(
                          height: 30,
                        ),
                        if (meetingdata['partner'] != null)
                          if (meetingdata['partner']['id'] ==
                              userid) //본인이 선택된 미팅
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    child: Text(
                                      '축하드립니다! $username님과 매치된 미팅입니다',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Strong',
                                          color: FlexColor.blueLightPrimary),
                                    ),
                                  ),
                                  SizedBox(height: 40),
                                  Text(
                                    (() {
                                      if (meetingdata['kakaotype'] == true) {
                                        return "${meetingdata['writer']}님의 카카오아이디";
                                      }

                                      return "${meetingdata['writer']}님의 오픈채팅링크";
                                    })(),
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  SizedBox(height: 10),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(
                                              text: meetingdata['kakao']))
                                          .then(
                                        (_) {
                                          Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                  content: Text("복사되었습니다")));
                                          if (meetingdata['kakaotype'] == false)
                                            launch(meetingdata['kakao']);
                                        },
                                      );
                                    },
                                    child: Card(
                                      color: Color.fromRGBO(255, 232, 18, 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          (() {
                                            if (meetingdata['kakaotype'] ==
                                                true) {
                                              return " ${meetingdata['kakao']}";
                                            }

                                            return " ${meetingdata['kakao']}";
                                          })(),
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                        if (meetingdata['owner'] == userid &&
                            meetingdata['partner'] != null)
                          Column(
                            children: [
                              Text('다음 상대와 매치되었습니다!',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  child: Container(
                                    color: Colors.blue.withOpacity(0.2),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.person),
                                              Text(
                                                  meetingdata['partner']
                                                      ['name'],
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.school),
                                              Text(
                                                  meetingdata['partner']
                                                      ['school'],
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.cake),
                                              Text(
                                                  meetingdata['partner']['age']
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              if (meetingdata['partner']
                                                      ['verified'] ==
                                                  true)
                                                Icon(Icons.verified,
                                                    color: Colors.blue),
                                              if (meetingdata['partner']
                                                      ['verified'] ==
                                                  true)
                                                Text(
                                                  '인증된 사용자입니다',
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              if (meetingdata['partner']
                                                      ['verified'] !=
                                                  true)
                                                Icon(Icons.warning,
                                                    color: Colors.red),
                                              if (meetingdata['partner']
                                                      ['verified'] !=
                                                  true)
                                                Text(
                                                  '인증되지 않은 사용자입니다',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    child: Text(
                                  meetingdata['partner']['name'] +
                                      '님께 본인의 카카오 아이디 or 오픈채팅 링크가 공개됩니다',
                                  style: TextStyle(
                                      color: FlexColor.redDarkPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                )),
                              ),
                              SizedBox(height:20),
                            ],
                          ),
                        if (meetingdata['hubos'].toString() != '[]' &&
                            meetingdata['owner'] != userid) //다른 사람 마팅, 신청자 있음

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: Row(
                                children: [
                                  Text(
                                    '현재 신청 팀: ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    ' ${meetingdata['hubos'].length.toString()}팀',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 25,
                                        fontFamily: 'Strong'),
                                  )
                                ],
                              ),
                            ),
                          ),
                        if (meetingdata['hubos'].toString() != '[]' &&
                            meetingdata['owner'] ==
                                userid) //내 미팅, 신청자 있음, 파트너 안정해짐
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '신청자 목록',
                                  style: TextStyle(
                                      fontFamily: 'hanma',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              for (var index in meetingdata['hubo'])
                                Card(
                                  elevation: 6,
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        Icon(CupertinoIcons.person),
                                        Text(index['name']),
                                      ],
                                    ),
                                    subtitle: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text('학교: ' + index['school']),
                                            SizedBox(width: 30),
                                            Text('나이: ' +
                                                index['age'].toString()),
                                            SizedBox(width: 30),
                                          ],
                                        ),
                                        if (index['verified'] == true)
                                          Row(
                                            children: [
                                              Icon(Icons.verified_user),
                                              Text('인증된 회원입니다!')
                                            ],
                                          ),
                                        if (index['verified'] == false)
                                          Row(
                                            children: [
                                              Icon(Icons.warning),
                                              Text('인증되지 않은 회원입니다')
                                            ],
                                          )
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: Text(
                                        '수락',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () {
                                        _pickPartner(index['id']);
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          )
                      ],
                    ),
                  ),
                ]));
          }
        },
      ),
    );
  }

  Future<Map> getMeetingData(int meetingid) async {
    final response = await http.get(
      Uri.http('10.0.2.2:8000', "api/v1/Meeting/$meetingid/"),
    ); //게시물 가져오기
    print(response.statusCode);
    print('포스트 ${meetingid}');

    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      content = jsonDecode(utf8.decode(response.bodyBytes));
      content['time'] =
          DateFormat("M월dd일 H:m").format(DateTime.parse(content['create_dt']));
      content['hubos'] = [];
      print(content['time']);
      for (var i in content['hubo']) {
        print(i);
        content['hubos'].add(i['id']);
      }
      print(content['hubos']);
      if (content['owner'] == userid) {
        final responsehubo = await http.get(
          Uri.http('10.0.2.2:8000', "api/v1/Meeting/$meetingid/"),
        );
      }
      return content;
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future _pickPartner(int partner) async {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('미팅 수락'),
          content: Text('미팅을 수락하시겠습니까?\n 당신의 카톡 아이디 or 오픈채팅 링크가 상대방에게 보여집니다'),
          actions: <Widget>[
            FlatButton(
              child: Text('네'),
              onPressed: () async {
                Navigator.pop(context, "OK");
                loading();
                final responsee = await http.put(
                    Uri.http('10.0.2.2:8000',
                        "api/v1/MeetingWrite/${widget.index.toString()}/"),
                    body: {
                      "partner": partner.toString(),
                      "kakaotype": content['kakaotype'].toString()
                    });
                print(responsee.body);
                Navigator.pop(context);
                _future = getMeetingData(widget.index);
                setState(() {});
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

  Future _postdata(bool type) async {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('미팅 신청'),
          content: Text((() {
            if (type == true) {
              return '미팅을 신청하시겠습니까?';
            }
            return "미팅 신청을 취소하시겠습니까?";
          })()),
          actions: <Widget>[
            FlatButton(
              child: Text('네'),
              onPressed: () async {
                Navigator.pop(context, "OK");
                loading();
                List hubolist = content['hubos'];
                if (type == true)
                  hubolist.add(userid);
                else
                  hubolist.remove(userid);
                var hubobody = new Map();
                hubobody['hubo'] = hubolist;

                final responsee = await http.put(
                    Uri.http('10.0.2.2:8000',
                        "api/v1/MeetingWrite/${widget.index.toString()}/"),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode(hubobody));
                print(responsee.body);

                Navigator.pop(context);
                _future = getMeetingData(widget.index);
                setState(() {});
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

  Future _delete() async {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('미팅 신청'),
          content: Text('미팅을 삭제하시겠습니까?'),
          actions: <Widget>[
            FlatButton(
              child: Text('네'),
              onPressed: () async {
                Navigator.pop(context, "OK");
                Navigator.pop(context);

                final responsee = await http.delete(
                  Uri.http('10.0.2.2:8000',
                      "api/v1/Meeting/${widget.index.toString()}/"),
                  headers: {'Content-Type': 'application/json'},
                );
                print(responsee.body);
                setState(() {});
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

  void loading() {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(content: CircularProgressIndicator());
      },
    );
  }
}
