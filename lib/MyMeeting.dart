import 'package:dio/dio.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'MeetingDetail.dart';
var userid;
var usertoken;
class MyMeetingList extends StatefulWidget {
  @override
  _MyMeetingListState createState() => _MyMeetingListState();
}


class _MyMeetingListState extends State<MyMeetingList> {
  Future getProfile() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    userid = sharedPreferences.getInt('userID');
    usertoken = sharedPreferences.getString('token');
  }
  int _currentIndex = 0;
  final List<Widget> _children = [MySuggest(), MyMade(), Matched()];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black, size: 40),
        title: Text('내 미팅', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,

        onTap: _onTap,
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.arrow_right_alt),
            title: Text('내가 신청한 미팅'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.star),
            title: Text('내가 올린 미팅'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart),
            title: Text('매치된 미팅'),
          ),
        ],
      ),
    );
  }
}

class MySuggest extends StatefulWidget {
  @override
  _MySuggestState createState() => _MySuggestState();
}

class _MySuggestState extends State<MySuggest> {
  static int page = 0;
  ScrollController _sc = new ScrollController();
  bool isLoading = false;
  List posts = [];
  final dio = new Dio();
  late int maxpage;

  Future<void> _getData() async {
    //새로고침을 위한 것
    setState(() {
      page = 0;
      posts = [];
      _getMoreData(page);
    });
  }
  @override
  void initState() {
    page=0;
    posts=[];
    _getMoreData(page);
    super.initState();

    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent &&
          page < maxpage) {
        _getMoreData(page);
      }
    });
  }
  void _getMoreData(int index) async {
    //데이터 추가하기
    List tList = [];

    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      var url =
          "http://10.0.2.2:8000/api/v1/Meeting/?hubo=${userid}&page=" + (index + 1).toString();

      final response = await dio.get(url);
      maxpage = (response.data['count'] - 1) ~/ 10 + 1;

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

  Widget _buildList() {
    return Expanded(
      child: Container(
        child: RefreshIndicator(
          child: ListView.builder(
              itemCount: posts.length + 1,
              controller: _sc,
              // Add one more item for progress indicator
              padding: EdgeInsets.symmetric(vertical: 8.0),
              itemBuilder: (BuildContext context, int index) {
                if (index == posts.length) {
                  return _buildProgressIndicator();
                } else {
                  return Container(
                    margin: new EdgeInsets.fromLTRB(5, 10, 5, 0),
                    width: 25.0,
                    height: 80.0,
                    child: InkWell(
                      child: Container(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MeetingDetail(index: posts[index]['id']),
                                ));
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 0),
                            color: Colors.white70,
                            elevation: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: (posts[index]['partner'] == null
                                      ? FlexColor.blueDarkPrimaryVariant
                                      : FlexColor.redDarkPrimary),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 10, 0),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  child: Text(
                                                    (posts[index]['description']),
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                    Colors.black,
                                                    child: Text(
                                                      posts[index]['type'],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  CircleAvatar(
                                                    backgroundColor: Colors.red,
                                                    child: Text(
                                                      posts[index]['location'],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(30.0),
                                                bottomLeft:
                                                Radius.circular(30.0),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.fromLTRB(
                                                  14, 2, 14, 2),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.person,
                                                            size: 15),
                                                        Text(
                                                          (posts[index]
                                                          ['writer']
                                                              .toString()),
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Icon(Icons.school,
                                                            size: 15),
                                                        Text(
                                                          (posts[index]
                                                          ['school']
                                                              .toString()),
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          (posts[index]['age']
                                                              .toString() +
                                                              ' 세'),
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.timer,
                                                          size: 12,
                                                          color: Colors.grey),
                                                      Text(posts[index]['time'],
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                              Colors.grey)),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {},
                    ),
                  );
                }
              }),
          onRefresh: _getData,
        ),
      ),
    );
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
  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildList()]);
  }
}

class MyMade extends StatefulWidget {
  @override
  _MyMadeState createState() => _MyMadeState();
}

class _MyMadeState extends State<MyMade> {
  static int page = 0;
  ScrollController _sc = new ScrollController();
  bool isLoading = false;
  List posts = [];
  final dio = new Dio();
  late int maxpage;

  Future<void> _getData() async {
    //새로고침을 위한 것
    setState(() {
      page = 0;
      posts = [];
      _getMoreData(page);
    });
  }
  @override
  void initState() {
    page=0;
    posts=[];
    _getMoreData(page);
    super.initState();

    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent &&
          page < maxpage) {
        _getMoreData(page);
      }
    });
  }
  void _getMoreData(int index) async {
    //데이터 추가하기
    List tList = [];

    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      var url =
          "http://10.0.2.2:8000/api/v1/Meeting/?owner=$userid&page=" + (index + 1).toString();

      final response = await dio.get(url);
      maxpage = (response.data['count'] - 1) ~/ 10 + 1;

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
  Widget _buildList() {
    return Expanded(
      child: Container(
        child: RefreshIndicator(
          child: ListView.builder(
              itemCount: posts.length + 1,
              controller: _sc,
              // Add one more item for progress indicator
              padding: EdgeInsets.symmetric(vertical: 8.0),
              itemBuilder: (BuildContext context, int index) {
                if (index == posts.length) {
                  return _buildProgressIndicator();
                } else {
                  return Container(
                    margin: new EdgeInsets.fromLTRB(5, 10, 5, 0),
                    width: 25.0,
                    height: 80.0,
                    child: InkWell(
                      child: Container(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MeetingDetail(index: posts[index]['id']),
                                ));
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 0),
                            color: Colors.white70,
                            elevation: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: (posts[index]['partner'] == null
                                      ? FlexColor.blueDarkPrimaryVariant
                                      : FlexColor.redDarkPrimary),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 10, 0),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  child: Text(
                                                    (posts[index]['description']),
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                    Colors.black,
                                                    child: Text(
                                                      posts[index]['type'],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  CircleAvatar(
                                                    backgroundColor: Colors.red,
                                                    child: Text(
                                                      posts[index]['location'],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(30.0),
                                                bottomLeft:
                                                Radius.circular(30.0),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.fromLTRB(
                                                  14, 2, 14, 2),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.person,
                                                            size: 15),
                                                        Text(
                                                          (posts[index]
                                                          ['writer']
                                                              .toString()),
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Icon(Icons.school,
                                                            size: 15),
                                                        Text(
                                                          (posts[index]
                                                          ['school']
                                                              .toString()),
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          (posts[index]['age']
                                                              .toString() +
                                                              ' 세'),
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.timer,
                                                          size: 12,
                                                          color: Colors.grey),
                                                      Text(posts[index]['time'],
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                              Colors.grey)),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {},
                    ),
                  );
                }
              }),
          onRefresh: _getData,
        ),
      ),
    );
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
  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildList()]);
  }
}

class Matched extends StatefulWidget {
  @override
  _MatchedState createState() => _MatchedState();
}

class _MatchedState extends State<Matched> {
  static int page = 0;
  ScrollController _sc = new ScrollController();
  bool isLoading = false;
  List posts = [];
  final dio = new Dio();
  late int maxpage;

  Future<void> _getData() async {
    //새로고침을 위한 것
    setState(() {
      page = 0;
      posts = [];
      _getMoreData(page);
    });
  }
  @override
  void initState() {
    page=0;
    posts=[];
    _getMoreData(page);
    super.initState();

    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent &&
          page < maxpage) {
        _getMoreData(page);
      }
    });
  }
  void _getMoreData(int index) async {
    //데이터 추가하기
    List tList = [];

    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      var url =
          "http://10.0.2.2:8000/api/v1/Meeting/?partner=$userid&page=" + (index + 1).toString();

      final response = await dio.get(url);
      maxpage = (response.data['count'] - 1) ~/ 10 + 1;

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
  Widget _buildList() {
    return Expanded(
      child: Container(
        child: RefreshIndicator(
          child: ListView.builder(
              itemCount: posts.length + 1,
              controller: _sc,
              // Add one more item for progress indicator
              padding: EdgeInsets.symmetric(vertical: 8.0),
              itemBuilder: (BuildContext context, int index) {
                if (index == posts.length) {
                  return _buildProgressIndicator();
                } else {
                  return Container(
                    margin: new EdgeInsets.fromLTRB(5, 10, 5, 0),
                    width: 25.0,
                    height: 80.0,
                    child: InkWell(
                      child: Container(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MeetingDetail(index: posts[index]['id']),
                                ));
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 0),
                            color: Colors.white70,
                            elevation: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: (posts[index]['partner'] == null
                                      ? FlexColor.blueDarkPrimaryVariant
                                      : FlexColor.redDarkPrimary),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 10, 0),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  child: Text(
                                                    (posts[index]['description']),
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                    Colors.black,
                                                    child: Text(
                                                      posts[index]['type'],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  CircleAvatar(
                                                    backgroundColor: Colors.red,
                                                    child: Text(
                                                      posts[index]['location'],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(30.0),
                                                bottomLeft:
                                                Radius.circular(30.0),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.fromLTRB(
                                                  14, 2, 14, 2),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.person,
                                                            size: 15),
                                                        Text(
                                                          (posts[index]
                                                          ['writer']
                                                              .toString()),
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Icon(Icons.school,
                                                            size: 15),
                                                        Text(
                                                          (posts[index]
                                                          ['school']
                                                              .toString()),
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          (posts[index]['age']
                                                              .toString() +
                                                              ' 세'),
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.timer,
                                                          size: 12,
                                                          color: Colors.grey),
                                                      Text(posts[index]['time'],
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                              Colors.grey)),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {},
                    ),
                  );
                }
              }),
          onRefresh: _getData,
        ),
      ),
    );
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
  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildList()]);
  }
}
