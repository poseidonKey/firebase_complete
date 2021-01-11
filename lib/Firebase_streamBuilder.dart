import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseStreamBuilder extends StatefulWidget {
  @override
  _FirebaseStreamBuilderState createState() => _FirebaseStreamBuilderState();
}

class _FirebaseStreamBuilderState extends State<FirebaseStreamBuilder> {
  void _incrementCounter() {
    DocumentReference doc =
        Firestore.instance.collection("collection_count").document("doc_count");
    doc.get().then((snapshot) {
      if (snapshot.exists) {
        Map<String, int> data = <String, int>{
          "count": ++snapshot.data['count']
        };
        doc.setData(data);
        print("add");
      } else {
        print('error');
      }
    });
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
              stream:
                  Firestore.instance.collection("collection_count").document("doc_count").snapshots(),
              builder: (BuildContext context, snapshot) {
                print(snapshot.data);
                return new Text(
                  // snapshot.data.documents[0]['count'].toString(),
                  snapshot.data['count'].toString(),
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
