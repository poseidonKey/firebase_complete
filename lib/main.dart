import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; // 구글 로그인 관련 패키지

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // 로그인 초기 상태 (false는 로그인 안함)
  bool _isLoggedIn = false;

  // 유저 정보 저장
  FirebaseUser _user;
  String birth = "00월 00일";

  final DocumentReference documentReference =
      Firestore.instance.document("test-collection/qYNfNWt7x3kG1Aquahmu1");

  // 로그인 함수
  _login() async {
    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;

      AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: gSA.idToken, accessToken: gSA.accessToken);

      AuthResult authResult = await _auth.signInWithCredential(credential);
      _user = authResult.user;

      setState(() {
        _isLoggedIn = true;
      });
    } catch (err) {
      print(err);
    }
  }

  // 로그아웃 함수
  _logout() {
    _googleSignIn.signOut();
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
            child: _isLoggedIn
                ? Column(
                    // 로그인 상태에 띄우는 화면
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.network(
                        _googleSignIn.currentUser.photoUrl, // 사용자 사진 가져오기
                        height: 50.0,
                        width: 50.0,
                      ),
                      Text(
                          _googleSignIn.currentUser.displayName), // 사용자 이름 가져오기
                      OutlineButton(
                        child: Text("로그아웃"),
                        onPressed: () {
                          _logout();
                        },
                      ),
                      RaisedButton(
                          onPressed: _add,
                          child: Text("데이터 추가하기"),
                          color: Colors.red),
                      RaisedButton(
                          onPressed: _update,
                          child: Text("데이터 수정하기"),
                          color: Colors.lightBlue),
                      RaisedButton(
                          onPressed: _fetch,
                          child: Text("데이터 패치하기"),
                          color: Colors.yellowAccent),
                      RaisedButton(
                          onPressed: _delete,
                          child: Text("데이터 삭제하기"),
                          color: Colors.orangeAccent),
                      Text(birth),
                      Builder(
                        builder: (ctx) {
                          return RaisedButton(
                              onPressed: () {
                                Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                    builder: (ctx) {
                                      return StreamBuilderTest();
                                    },
                                  ),
                                );
                              },
                              child: Text("StreamBuilder 이용"),
                              color: Colors.deepPurple);
                        },
                      ),
                    ],
                  )
                : Center(
                    // 로그인하지 않은 상태에 띄우는 화면
                    child: OutlineButton(
                      child: Text("구글로 로그인하기"),
                      onPressed: () {
                        _user = _login();
                      },
                    ),
                  )),
      ),
    );
  }

  void _add() {
    Map<String, String> data = <String, String>{
      "name": "gasbugs",
      "birth": "04월 03일"
    };
    documentReference.setData(data).whenComplete(() {
      print("add");
    }).catchError((e) => print(e));
  }

  void _update() {
    Map<String, String> data = <String, String>{"birth": "03월 04일"};
    documentReference.updateData(data).whenComplete(() {
      print("update");
    }).catchError((e) => print(e));
  }

  void _fetch() {
    documentReference.get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          birth = snapshot.data['birth'];
        });
      } else {
        setState(() {
          birth = "00월 00일";
        });
      }
    });
  }

  void _delete() {
    documentReference.delete().whenComplete(() {
      print("delete");
    }).catchError((e) => print(e));
  }
}

class StreamBuilderTest extends StatefulWidget {
  @override
  _StreamBuilderTestState createState() => _StreamBuilderTestState();
}

class _StreamBuilderTestState extends State<StreamBuilderTest> {
  int _counter = 0;
  StreamController<int> _events;

  @override
  initState() {
    super.initState();
    _events = new StreamController<int>();
    _events.add(0);
  }

  void _incrementCounter() {
    _counter++;
    _events.add(_counter);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("StreamBuilder test"),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'You have pushed the button this many times:',
            ),
            StreamBuilder(
              stream: _events.stream,
              builder: (BuildContext context, snapshot) {
                return new Text(
                  snapshot.data.toString(),
                  style: Theme.of(context).textTheme.headline3,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
