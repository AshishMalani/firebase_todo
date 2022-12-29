import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

class MessageScreen1 extends StatelessWidget {
  MessageScreen1(
      {Key? key, required this.sender_uid, required this.receiver_uid})
      : super(key: key);

  final String sender_uid;
  final String receiver_uid;

  CollectionReference demo = FirebaseFirestore.instance.collection('demo');

  TextEditingController _editingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NewGradientAppBar(
        titleSpacing: -10,
        gradient: LinearGradient(
          colors: [
            Color(0xffFEDA77),
            Color(0xffDD2A7B),
            Color(0xff8134AF),
          ],
        ),
        title: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("userProfile")
                .doc(receiver_uid)
                .snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text("error");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("waiting");
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(
                          "${(snapshot.data!.data() as Map)['user_profile']}"),
                    ),
                  ),
                  SizedBox(width: 5),
                  Text("${(snapshot.data!.data() as Map)['full_name']}"),
                  SizedBox(width: 5),
                ],
              );
            }),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.video_call_outlined),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: Center(
            child: StreamBuilder<QuerySnapshot>(
              stream: demo.orderBy("time", descending: false).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error"),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  List<QueryDocumentSnapshot> messages = snapshot.data!.docs;
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    itemBuilder: (context, index) {
                      Map msg = messages[index].data() as Map;

                      if (msg['sender_uid'] == sender_uid &&
                              msg['receiver_uid'] == receiver_uid ||
                          msg['sender_uid'] == receiver_uid &&
                              msg['receiver_uid'] == sender_uid) {
                        return Row(
                          mainAxisAlignment: msg['sender_uid'] == sender_uid
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            Chip(label: Text("${msg['message']}")),
                          ],
                        );
                      } else {
                        return SizedBox();
                      }
                    },
                    itemCount: messages.length,
                  );
                }
              },
            ),
          ),
        ),
        SizedBox(
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: Material(
            elevation: 10,
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextField(
                    controller: _editingController,
                    autofocus: true,
                    decoration: InputDecoration(
                        hintText: "Type Message...",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                FloatingActionButton(
                    onPressed: () {
                      demo.add({
                        'sender_uid': sender_uid,
                        'receiver_uid': receiver_uid,
                        'message': _editingController.text.trim(),
                        'time': DateTime.now(),
                      }).then((value) {
                        _editingController.clear();
                      });
                    },
                    child: Icon(Icons.send_outlined)),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
