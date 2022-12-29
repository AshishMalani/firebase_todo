import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageScreen2 extends StatelessWidget {
  MessageScreen2({Key? key}) : super(key: key);

  CollectionReference demo = FirebaseFirestore.instance.collection('demo');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: demo.doc('G7O1juENQwxyiyn3C0E6').snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Error"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              Map data = snapshot.data!.data() as Map;

              return Slider(
                  max: 200,
                  min: 10,
                  value: data['size'].toDouble(),
                  onChanged: (value) {
                    demo
                        .doc('G7O1juENQwxyiyn3C0E6')
                        .set({'size': value.toInt()});
                  });
            }
          },
        ),
      ),
    );
  }
}
