import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shimmer/shimmer.dart';

class comments_Screen extends StatefulWidget {
  final image;
  final id;
  final userPostSnap;
  const comments_Screen({
    super.key,
    required this.image,
    required this.id,
    required this.userPostSnap,
  });
  @override
  State<comments_Screen> createState() => _Coment_ScreenState();
}

class _Coment_ScreenState extends State<comments_Screen> {
  TextEditingController comment = TextEditingController();
  CollectionReference UserPostCollection =
      FirebaseFirestore.instance.collection('userPost');

  CollectionReference ProfileCollection =
      FirebaseFirestore.instance.collection('userProfile');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Comments',
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
            ),
          ),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.share,
                  color: Colors.black,
                ))
          ]),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: UserPostCollection.doc('${widget.id}')
                  .collection('comment')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> Comment) {
                if (Comment.hasError) {
                  return Center(child: Text("Something went wrong"));
                }
                if (Comment.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Text("loading"),
                  );
                }
                print(Comment.data!.docs.length);
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: Comment.data!.docs.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        StreamBuilder<DocumentSnapshot>(
                          stream: ProfileCollection.doc(
                                  "${(Comment.data!.docs[index].data() as Map)['uid']}")
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> userProfile) {
                            if (userProfile.hasError) {
                              print(
                                  '${(Comment.data!.docs[index].data() as Map)['uid']}');
                              return Center(
                                  child: Text("Something went wrong"));
                            }
                            if (userProfile.connectionState ==
                                ConnectionState.waiting) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                enabled: false,
                                child: Row(
                                  children: [
                                    CircleAvatar(),
                                    Text('asdfhgkhgdfhg')
                                  ],
                                ),
                              );
                            }
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundImage: NetworkImage(
                                            '${(userProfile.data!.data() as Map)['user_profile']}'),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          GetStorage().read("uid") ==
                                                  ((widget.userPostSnap.data!
                                                      .docs[index]
                                                      .data() as Map)['uid'])
                                              ? Text(
                                                  'Me',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 17),
                                                )
                                              : Text(
                                                  '${(userProfile.data!.data() as Map)['full_name']}'),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            '${(Comment.data!.docs[index].data() as Map)['comment']}',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Reply',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Text(
                                                'Send',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Container(
            height: 70,
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage('${widget.image}'),
              ),
              title: TextFormField(
                controller: comment,
              ),
              trailing: TextButton(
                onPressed: () {
                  UserPostCollection.doc(widget.id).collection('comment').add({
                    "uid": GetStorage().read("uid"),
                    "comment": comment.text,
                  }).then((value) {
                    comment.clear();
                  });
                },
                child: Text(
                  'Post',
                  style: TextStyle(fontSize: 17, color: Colors.black),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
