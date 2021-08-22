import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:meetingapp/MeetingDetail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AddMeeting.dart';

class MeetingTab extends StatefulWidget {
  @override
  _MeetingTabState createState() => _MeetingTabState();
}

class _MeetingTabState extends State<MeetingTab> {
  static int page = 0;
  ScrollController _sc = new ScrollController();
  bool isLoading = false;
  List posts = [];
  final dio = new Dio();
  late int maxpage;
  var posttype = '';
  var sharedPreferences;
  var token;

  Future _checklogin() async {
    sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString('token');
  }

  Future<void> _getData() async {
    //새로고침을 위한 것
    setState(() {
      page = 0;
      posts = [];
      print(page);
      _getMoreData(page);
    });
  }

  @override
  void initState() {
    _getMoreData(page);
    _checklogin();
    super.initState();

    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent &&
          page < maxpage) {
        _getMoreData(page);
      }
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    page = 0;
    posts = [];
    isLoading = false;

    super.dispose();
  }

  Widget _buildList() {
    return Expanded(
      child: Container(
        child: RefreshIndicator(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: posts.length + 1,
              controller: _sc,
              // Add one more item for progress indicator
              padding: EdgeInsets.symmetric(vertical: 8.0),
              itemBuilder: (BuildContext context, int index) {
                if (index == posts.length) {
                  return _buildProgressIndicator();
                } else {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MeetingDetail(index: posts[index]['id']),
                          ));
                    },
                    child: Card(
                      elevation: 8.0,
                      margin: new EdgeInsets.symmetric(
                          horizontal: 5, vertical: 6.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(126, 33, 44,1.0)),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 5.0, vertical: 20.0),
                          leading: Container(
                            margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                            constraints: const BoxConstraints(
                                minWidth: 10.0, maxWidth: 50),
                            height: double.infinity,
                            padding: EdgeInsets.only(right: 12.0),
                            decoration: new BoxDecoration(
                                border: new Border(
                                    right: new BorderSide(
                                        width: 1.0, color: Colors.white24))),
                            child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(posts[index]['type'].toString(),
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          ),
                          title: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(


                              child: Text(
                                (posts[index]['description']),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),
                          subtitle: Container(
                            child: Column(

                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(Icons.person, size: 15),
                                          Text(
                                              (posts[index]['writer']
                                                  .toString()),
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          SizedBox(width: 10),
                                          Icon(Icons.school, size: 15),
                                          Text(
                                              (posts[index]['school']
                                                  .toString()),
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          SizedBox(width: 10),
                                          Text(
                                              (posts[index]['age'].toString() +
                                                  ' 세'),
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.timer,
                                          size: 12, color: Colors.grey),
                                      Text(posts[index]['time'],
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          trailing: Wrap(
                            spacing: 12,
                            children: [
                              if (posts[index]['partner'] == null)
                                Container(
                                    child: Text('모집중', style: TextStyle(fontSize: 15,fontFamily: 'Strong', fontWeight: FontWeight.bold, color: Colors.blue),),),
                              if (posts[index]['partner'] != null)
                                Container(


                                  child: Text('마감', style: TextStyle(fontSize: 15,fontFamily: 'Strong', fontWeight: FontWeight.bold, color: Colors.red),),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }),
          onRefresh: _getData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO( 254, 213, 217,1.0),
          iconTheme: IconThemeData(color: Colors.black, size: 40),
          title: Text(
            '미팅 목록',
            style: TextStyle(fontWeight: FontWeight.bold
            ),
          ),
          foregroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          actions: [
            if (token != null)
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => addMeeting(),
                        ));
                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.black,
                  )),
          ],
        ),
        body: Container(
            color: Color.fromRGBO( 254, 213, 217,1.0),
            child: Column(children: [_buildList()])));
  }

  void _getMoreData(int index) async {
    //데이터 추가하기
    List tList = [];

    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      var url =
          "http://10.0.2.2:8000/api/v1/Meeting/?page=" + (index + 1).toString();
      print(page);
      final response = await dio.get(url);
      print('11');
      maxpage = (response.data['count'] - 1) ~/ 10 + 1;
      print(response.statusCode);
      tList = [];

      for (int i = 0; i < response.data['results'].length; i++) {
        tList.add(response.data['results'][i]);
        tList[i]['time'] = DateFormat("M월dd일 H:m")
            .format(DateTime.parse(tList[i]['create_dt']));
      }

      setState(() {
        isLoading = false;
        posts.addAll(tList);
        page++;
      });
    }
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }
}
