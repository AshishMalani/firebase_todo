import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_todo/view/login_screen.dart';
import 'package:firebase_todo/view/message_screen%201.dart' as view;
import 'package:firebase_todo/view/unicorn_outline_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gradient_floating_button/gradient_floating_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:share_plus/share_plus.dart';

import '../service/collection_service.dart';
import 'my_follower_following_list.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late String uid;

  var _firebaseService = FirebaseService();

  @override
  void initState() {
    uid = GetStorage().read('uid');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    CollectionReference userPostCollection =
        FirebaseFirestore.instance.collection('userPost');

    CollectionReference userProfileCollection =
        FirebaseFirestore.instance.collection('userProfile');

    TextEditingController _editorControllerForComment = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: NewGradientAppBar(
        title: Text('Social Media'),
        gradient: LinearGradient(
          colors: [
            Color(0xffFEDA77),
            Color(0xffDD2A7B),
            Color(0xff8134AF),
          ],
        ),
        actions: [
          IconButton(
            color: Colors.black,
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              GetStorage().remove("uid");
              Get.offAll(LoginScreen());
            },
          )
        ],
      ),
      floatingActionButton: GradientFloatingButton().withLinearGradient(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                insetPadding:
                    EdgeInsets.symmetric(vertical: 100, horizontal: 20),
                child: PostCreate(),
              );
            },
          );
        },
        iconWidget: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        alignmentEnd: Alignment.topRight,
        alignmentBegin: Alignment.bottomLeft,
        colors: [
          Color(0xffFEDA77),
          Color(0xffDD2A7B),
          Color(0xff8134AF),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userPostCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Something went wrong"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Text("loading"),
            );
          }

          print("title: ${snapshot.data!.docs.length}");
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height * 0.04,
                    ),
                    StreamBuilder<DocumentSnapshot>(
                      stream: userProfileCollection
                          .doc(
                              "${(snapshot.data!.docs[index].data() as Map)['uid']}")
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                        if (userSnapshot.hasError) {
                          return Center(
                            child: Text("Something went wrong"),
                          );
                        }
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Text("loading"),
                          );
                        }

                        print("title: ${userSnapshot.data!.id}");
                        return Row(
                          children: [
                            InkWell(
                              onTap: () {
                                publicUserProfile(
                                    snapshot, index, userSnapshot);
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          "${(userSnapshot.data!.data() as Map)['user_profile']}"),
                                    ),
                                    shape: BoxShape.circle),
                              ),
                            ),
                            SizedBox(
                              width: width * 0.04,
                            ),
                            GetStorage().read('uid') ==
                                    ((snapshot.data!.docs[index].data()
                                        as Map)['uid'])
                                ? Text("Me")
                                : Text(
                                    "${(userSnapshot.data!.data() as Map)['full_name']}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400),
                                  ),
                            Spacer(),
                            GetStorage().read('uid') ==
                                    ((snapshot.data!.docs[index].data()
                                        as Map)['uid'])
                                ? PopupMenuButton<String>(
                                    // Callback that sets the selected popup menu item.
                                    onSelected: (value) {
                                      userPostCollection
                                          .doc(snapshot.data!.docs[index].id)
                                          .delete();
                                    },
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<String>>[
                                          const PopupMenuItem<String>(
                                            value: "Delete",
                                            child: Text('Delete'),
                                          ),
                                        ])
                                : Icon(Icons.more_vert_outlined)
                          ],
                        );
                      },
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                            fit: BoxFit.cover,
                            '${(snapshot.data!.docs[index].data() as Map)['image']}'),
                      ),
                    ),
                    Row(
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('userPost')
                              .doc('${snapshot.data!.docs[index].id}')
                              .collection('like')
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot> likesnapshot) {
                            if (likesnapshot.hasError) {
                              return Center(
                                  child: Text("Something went wrong"));
                            }
                            if (likesnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            bool isfavorite = false;
                            for (var fav in (likesnapshot.data!.docs)) {
                              if (uid == (fav.id)) {
                                isfavorite = true;
                                break;
                              }
                            }
                            return Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      if (isfavorite) {
                                        userPostCollection
                                            .doc(snapshot.data!.docs[index].id)
                                            .collection('like')
                                            .doc(uid)
                                            .delete()
                                            .then((value) => print("delete"));
                                      } else {
                                        userPostCollection
                                            .doc(snapshot.data!.docs[index].id)
                                            .collection('like')
                                            .doc(uid)
                                            .set({});
                                      }
                                    },
                                    icon: isfavorite
                                        ? Icon(
                                            Icons.favorite,
                                            color: isfavorite
                                                ? Colors.red
                                                : Colors.black,
                                          )
                                        : Icon(Icons.favorite_border)),
                                Text(
                                  '${likesnapshot.data!.docs.length}',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400),
                                )
                              ],
                            );
                          },
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              constraints: BoxConstraints(maxWidth: 335),
                              builder: (context) {
                                return Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: Container(
                                    height: 500,
                                    width: double.infinity,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () {},
                                              icon: Icon(Icons.arrow_back),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            ShaderMask(
                                              shaderCallback: (Rect bounds) {
                                                return LinearGradient(
                                                        colors: [
                                                      Color(0xffFEDA77),
                                                      Color(0xffDD2A7B),
                                                      Color(0xff8134AF),
                                                    ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight)
                                                    .createShader(bounds);
                                              },
                                              child: Text(
                                                "Comments",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    letterSpacing: 3,
                                                    shadows: [
                                                      BoxShadow(
                                                        color: Colors.white,
                                                        offset: Offset(0, 2),
                                                        blurRadius: 10,
                                                      )
                                                    ],
                                                    fontSize: 20),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: StreamBuilder<QuerySnapshot>(
                                            stream: userPostCollection
                                                .doc(
                                                    '${(snapshot.data!.docs[index].id)}')
                                                .collection('comments')
                                                .snapshots(),
                                            builder: (context,
                                                AsyncSnapshot<QuerySnapshot>
                                                    commentSnapshot) {
                                              if (commentSnapshot.hasData) {
                                                print(
                                                    "comments ${commentSnapshot.data!.docs.length}");
                                                return ListView.builder(
                                                  itemCount: commentSnapshot
                                                      .data!.docs.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    print(
                                                        '${(commentSnapshot.data!.docs[index].data() as Map)['msg']}');

                                                    return Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Row(
                                                        children: [
                                                          StreamBuilder<
                                                              DocumentSnapshot>(
                                                            stream: userProfileCollection
                                                                .doc(
                                                                    "${(commentSnapshot.data!.docs[index].data() as Map)['uid']}")
                                                                .snapshots(),
                                                            builder: (BuildContext
                                                                    context,
                                                                AsyncSnapshot<
                                                                        DocumentSnapshot>
                                                                    userSnapshot) {
                                                              if (userSnapshot
                                                                  .hasError) {
                                                                return Center(
                                                                  child: Text(
                                                                      "Something went wrong"),
                                                                );
                                                              }
                                                              if (userSnapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return Center(
                                                                  child: Text(
                                                                      "loading"),
                                                                );
                                                              }

                                                              print(
                                                                  "title: ${userSnapshot.data!.id}");
                                                              return Container(
                                                                width: 50,
                                                                height: 50,
                                                                decoration:
                                                                    BoxDecoration(
                                                                        image:
                                                                            DecorationImage(
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          image:
                                                                              NetworkImage("${(userSnapshot.data!.data() as Map)['user_profile']}"),
                                                                        ),
                                                                        shape: BoxShape
                                                                            .circle),
                                                              );
                                                            },
                                                          ),
                                                          SizedBox(width: 10),
                                                          Center(
                                                            child: Text(
                                                              "${(commentSnapshot.data!.docs[index].data() as Map)['msg']}",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              }

                                              return Center(
                                                  child: Text(
                                                      "Something went wrong"));
                                            },
                                          ),
                                        ),
                                        Container(
                                          height: 60,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.grey.shade300),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        fit: BoxFit.fill,
                                                        image: NetworkImage(
                                                            "${(snapshot.data!.docs[index].data() as Map)['image']}")),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 15,
                                                ),
                                                Expanded(
                                                  child: TextField(
                                                    controller:
                                                        _editorControllerForComment,
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText:
                                                          'Add a comment...',
                                                      hintStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Spacer(),
                                                TextButton(
                                                  onPressed: () {
                                                    userPostCollection
                                                        .doc(snapshot.data!
                                                            .docs[index].id)
                                                        .collection('comments')
                                                        .add({
                                                      'uid': uid,
                                                      "msg":
                                                          _editorControllerForComment
                                                              .text
                                                              .trim(),
                                                    }).then((value) {
                                                      _editorControllerForComment
                                                          .clear();
                                                    });
                                                  },
                                                  child: ShaderMask(
                                                    shaderCallback:
                                                        (Rect bounds) {
                                                      return LinearGradient(
                                                              colors: [
                                                            Color(0xffFEDA77),
                                                            Color(0xffDD2A7B),
                                                            Color(0xff8134AF),
                                                          ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight)
                                                          .createShader(bounds);
                                                    },
                                                    child: Text(
                                                      "Post",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          letterSpacing: 3,
                                                          shadows: [
                                                            BoxShadow(
                                                              color:
                                                                  Colors.white,
                                                              offset:
                                                                  Offset(0, 2),
                                                              blurRadius: 10,
                                                            )
                                                          ],
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Image.asset(
                            "assets/images/comment.png",
                            height: 22,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Share.share(
                                "${(snapshot.data!.docs[index].data() as Map)["image"]}\n ${(snapshot.data!.docs[index].data() as Map)["desc"]}");
                          },
                          child: Icon(Icons.share),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.bookmark_border_outlined),
                        ),
                      ],
                    ),
                    Text(
                      "${(snapshot.data!.docs[index].data() as Map)['desc']}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void publicUserProfile(
      AsyncSnapshot snapshot, int index, AsyncSnapshot userSnapshot) async {
    String publicUid = (snapshot.data!.docs[index].data() as Map)["uid"];
    String myUid = GetStorage().read('uid');

    Future<QuerySnapshot> myFollowersCollection = FirebaseFirestore.instance
        .collection("userProfile")
        .doc(myUid)
        .collection('followers')
        .get();
    Future<QuerySnapshot> myFollowingCollection = FirebaseFirestore.instance
        .collection("userProfile")
        .doc(myUid)
        .collection('following')
        .get();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            height: 400,
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                ),
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            "${(snapshot.data!.docs[index].data() as Map)['image']}"),
                      ),
                      border: Border.all(color: Colors.black),
                      shape: BoxShape.circle),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "UserName:  ",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                    ),
                    Text(
                      "${(userSnapshot.data!.data() as Map)["full_name"]}",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                myUid == publicUid
                    ? FutureBuilder(
                        future: Future.wait(
                            [myFollowersCollection, myFollowingCollection]),
                        builder: (BuildContext context,
                            AsyncSnapshot followersAndFollowingSnapshot) {
                          if (followersAndFollowingSnapshot.connectionState ==
                              ConnectionState.done) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MyFollowerFollowingList(
                                                  myFollowerFollowingIdList:
                                                      (followersAndFollowingSnapshot
                                                                  .data[0]
                                                              as QuerySnapshot)
                                                          .docs
                                                          .map((e) => e.id)
                                                          .toList(),
                                                  lable: 'Followers',
                                                )));
                                  },
                                  child: Chip(
                                    label: Text(
                                        "Followers: ${(followersAndFollowingSnapshot.data[0] as QuerySnapshot).docs.length}"),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MyFollowerFollowingList(
                                                  myFollowerFollowingIdList:
                                                      (followersAndFollowingSnapshot
                                                                  .data[1]
                                                              as QuerySnapshot)
                                                          .docs
                                                          .map((e) => e.id)
                                                          .toList(),
                                                  lable: 'Following',
                                                )));
                                  },
                                  child: Chip(
                                    label: Text(
                                        "Following: ${(followersAndFollowingSnapshot.data[1] as QuerySnapshot).docs.length}"),
                                  ),
                                )
                              ],
                            );
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      )
                    : FutureBuilder(
                        future: Future.wait(
                            [myFollowersCollection, myFollowingCollection]),
                        builder: (BuildContext context,
                            AsyncSnapshot followersAndFollowingSnapshot) {
                          if (followersAndFollowingSnapshot.connectionState ==
                              ConnectionState.done) {
                            bool myFollowersMatch = false;
                            bool myFollowingMatch = false;

                            for (var doc in (followersAndFollowingSnapshot
                                    .data[0] as QuerySnapshot)
                                .docs) {
                              if (doc.id == publicUid) {
                                myFollowingMatch = true;
                                break;
                              }
                            }
                            for (var doc in (followersAndFollowingSnapshot
                                    .data[1] as QuerySnapshot)
                                .docs) {
                              if (doc.id == publicUid) {
                                myFollowersMatch = true;
                                break;
                              }
                            }

                            if (myFollowersMatch == false &&
                                myFollowingMatch == false) {
                              print('${myFollowersMatch}:${myFollowingMatch}');

                              return InkWell(
                                onTap: () async {
                                  String publicUid = (snapshot.data!.docs[index]
                                      .data() as Map)["uid"];
                                  String myUid = GetStorage().read('uid');

                                  print(
                                      'user uid: ${(snapshot.data!.docs[index].data() as Map)["uid"]}');
                                  print('My uid: ${GetStorage().read('uid')}');

                                  await FirebaseFirestore.instance
                                      .collection("userProfile")
                                      .doc(myUid)
                                      .collection('following')
                                      .doc(publicUid)
                                      .set({});

                                  await FirebaseFirestore.instance
                                      .collection("userProfile")
                                      .doc(publicUid)
                                      .collection('followers')
                                      .doc(myUid)
                                      .set({});

                                  Navigator.pop(context);

                                  // FirebaseFirestore.instance
                                  //     .collection(
                                  //     'userProfile')
                                  //     .doc(
                                  //     'pByPmDj2EYOdJYCqVZTlRgMGwNs2')
                                  //     .collection('follow')
                                  //     .add({
                                  //   'userid': GetStorage()
                                  //       .read(
                                  //       'uid') ==
                                  //       ((snapshot.data!
                                  //           .docs[index]
                                  //           .data()
                                  //       as Map)['uid'])
                                  //       ? SizedBox()
                                  //       : "${snapshot.data!.docs[index].id}",
                                  // });
                                },
                                child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [
                                            Color(0xffFEDA77),
                                            Color(0xffDD2A7B),
                                            Color(0xff8134AF),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Ink(
                                      height: 45,
                                      width: 150,
                                      child: Center(
                                        child: Text(
                                          "Follow",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );

                              return MaterialButton(
                                onPressed: () async {
                                  String publicUid = (snapshot.data!.docs[index]
                                      .data() as Map)["uid"];
                                  String myUid = GetStorage().read('uid');

                                  print(
                                      'user uid: ${(snapshot.data!.docs[index].data() as Map)["uid"]}');
                                  print('My uid: ${GetStorage().read('uid')}');

                                  await FirebaseFirestore.instance
                                      .collection("userProfile")
                                      .doc(myUid)
                                      .collection('following')
                                      .doc(publicUid)
                                      .set({});

                                  await FirebaseFirestore.instance
                                      .collection("userProfile")
                                      .doc(publicUid)
                                      .collection('followers')
                                      .doc(myUid)
                                      .set({});

                                  Navigator.pop(context);

                                  // FirebaseFirestore.instance
                                  //     .collection(
                                  //     'userProfile')
                                  //     .doc(
                                  //     'pByPmDj2EYOdJYCqVZTlRgMGwNs2')
                                  //     .collection('follow')
                                  //     .add({
                                  //   'userid': GetStorage()
                                  //       .read(
                                  //       'uid') ==
                                  //       ((snapshot.data!
                                  //           .docs[index]
                                  //           .data()
                                  //       as Map)['uid'])
                                  //       ? SizedBox()
                                  //       : "${snapshot.data!.docs[index].id}",
                                  // });
                                },
                                height: 40,
                                highlightColor: Colors.yellow,
                                elevation: 20,
                                shape: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusElevation: 20,
                                color: Colors.indigoAccent,
                                minWidth: 100,
                                child: Text(
                                  "Follow",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            } else if (myFollowersMatch == true &&
                                myFollowingMatch == false) {
                              print('${myFollowersMatch}:${myFollowingMatch}');
                              return MaterialButton(
                                onPressed: () {},
                                height: 40,
                                highlightColor: Colors.yellow,
                                elevation: 20,
                                shape: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusElevation: 20,
                                color: Colors.indigoAccent,
                                minWidth: 100,
                                child: Text(
                                  "Following",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            } else if (myFollowersMatch == false &&
                                myFollowingMatch == true) {
                              print('${myFollowersMatch}:${myFollowingMatch}');
                              return MaterialButton(
                                onPressed: () async {
                                  String publicUid = (snapshot.data!.docs[index]
                                      .data() as Map)["uid"];
                                  String myUid = GetStorage().read('uid');

                                  print(
                                      'user uid: ${(snapshot.data!.docs[index].data() as Map)["uid"]}');
                                  print('My uid: ${GetStorage().read('uid')}');

                                  await FirebaseFirestore.instance
                                      .collection("userProfile")
                                      .doc(publicUid)
                                      .collection('followers')
                                      .doc(myUid)
                                      .set({});

                                  await FirebaseFirestore.instance
                                      .collection("userProfile")
                                      .doc(myUid)
                                      .collection('following')
                                      .doc(publicUid)
                                      .set({});

                                  Navigator.pop(context);
                                },
                                height: 40,
                                highlightColor: Colors.yellow,
                                elevation: 20,
                                shape: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusElevation: 20,
                                color: Colors.indigoAccent,
                                minWidth: 100,
                                child: Text(
                                  "Follow back",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            } else {
                              print('${myFollowersMatch}:${myFollowingMatch}');
                              return MaterialButton(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection("userProfile")
                                      .doc(publicUid)
                                      .collection('followers')
                                      .doc(myUid)
                                      .delete();

                                  await FirebaseFirestore.instance
                                      .collection("userProfile")
                                      .doc(myUid)
                                      .collection('following')
                                      .doc(publicUid)
                                      .delete();

                                  Navigator.pop(context);
                                },
                                height: 40,
                                highlightColor: Colors.yellow,
                                elevation: 20,
                                shape: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusElevation: 20,
                                color: Colors.indigoAccent,
                                minWidth: 100,
                                child: Text(
                                  "Following",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                SizedBox(height: 10),
                publicUid == myUid
                    ? SizedBox()
                    : UnicornOutlineButton(
                        strokeWidth: 2,
                        radius: 10,
                        gradient: LinearGradient(
                            colors: [
                              Color(0xffFEDA77),
                              Color(0xffDD2A7B),
                              Color(0xff8134AF),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        child: SizedBox(
                            width: 150,
                            height: 18,
                            child: Center(
                              child: Text(
                                'Message',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400,),
                              ),
                            )),
                        onPressed: () {
                          Get.to(view.MessageScreen1(
                            receiver_uid: publicUid,
                            sender_uid: myUid,
                          ));
                        },
                      )
              ],
            ),
          ),
        );
      },
    );
  }
}

class PostCreate extends StatefulWidget {
  const PostCreate({Key? key}) : super(key: key);

  @override
  State<PostCreate> createState() => _PostCreateState();
}

class _PostCreateState extends State<PostCreate> {
  final nameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  File? image;
  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 30,
              ),
              Text(
                "CREATE POST",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          image == null
                              ? SizedBox()
                              : Image.file(image!, fit: BoxFit.cover),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: IconButton(
                              onPressed: () async {
                                final ImagePicker _picker = ImagePicker();
                                // Pick an image
                                final XFile? image = await _picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 50);
                                this.image = File(image!.path);
                                setState(() {});
                              },
                              icon: Icon(Icons.camera),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                keyboardType: TextInputType.text,
                controller: descriptionCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                    hintText: "Decriptions",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    )),
                onTap: () {},
              ),
              SizedBox(
                height: 30,
              ),
              // MaterialButton(
              //   textColor: Colors.white,
              //   height: 50,
              //   minWidth: double.infinity,
              //   color: Colors.pink,
              //   child: Text("Upload"),
              //   onPressed: () async {
              //     await createPost(image!, descriptionCtrl.text);
              //     Get.back();
              //   },
              // ),
              InkWell(
                onTap: () async {
                  await createPost(image!, descriptionCtrl.text);
                  Get.back();
                },
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Color(0xffFEDA77),
                      Color(0xffDD2A7B),
                      Color(0xff8134AF),
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Ink(
                      height: 55,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          "Upload",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createPost(File image, String desc) async {
    //image upload and get uploaded image url
    var uploadResponse = await FirebaseStorage.instance
        .ref()
        .child('userPost')
        .child('userpost_${GetStorage().read('uid')}_${DateTime.now()}')
        .putFile(image, SettableMetadata(contentType: "image/png"));
    String PostImageUrl = await uploadResponse.ref.getDownloadURL();

    //prepare user post data with image url
    Map<String, dynamic> post = {
      "uid": "${GetStorage().read('uid')}",
      "desc": desc,
      "image": PostImageUrl
    };
    await FirebaseFirestore.instance.collection("userPost").add(post);
  }
}
