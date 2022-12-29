import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:image_picker/image_picker.dart';

import 'login_screen.dart';

class PopupScreen extends StatefulWidget {
  const PopupScreen({Key? key}) : super(key: key);

  @override
  State<PopupScreen> createState() => _PopupScreenState();
}

class _PopupScreenState extends State<PopupScreen> {
  int Count = 0;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    CollectionReference userPostCollection =
        FirebaseFirestore.instance.collection('userPost');

    CollectionReference userProfileCollection =
        FirebaseFirestore.instance.collection('userProfile');
    List<Map<String, dynamic>> iconsList = [
      {"icon": Icons.share, 'name': "Share"},
      {"icon": Icons.link, 'name': "Link"},
      {"icon": Icons.bookmark_border_outlined, 'name': "Save"},
      {"icon": Icons.add_comment_outlined, 'name': "Remix"},
      {"icon": Icons.qr_code_outlined, 'name': "QR code"},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Social Media",
          style: TextStyle(color: Colors.black),
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.image),
        onPressed: () {
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
                          return Center(child: Text("Something went wrong"));
                        }
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Text("loading"),
                          );
                        }

                        print("title: ${userSnapshot.data!.data()}");
                        return Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(
                                          "${(userSnapshot.data!.data() as Map)['user_profile']}")),
                                  border: const GradientBoxBorder(
                                    gradient: LinearGradient(colors: [
                                      Colors.blue,
                                      Colors.red,
                                      Colors.yellow
                                    ]),
                                    width: 2,
                                  ),
                                  shape: BoxShape.circle),
                            ),
                            SizedBox(
                              width: width * 0.04,
                            ),
                            // GetStorage().read('uid') ==
                            //         ((snapshot.data!.docs[index].data()
                            //             as Map)['uid'])
                            //     ? Text("Me")
                            //     : Text(
                            //         "${(userSnapshot.data!.data() as Map)['full_name']}",
                            //         style: TextStyle(
                            //             fontSize: 18,
                            //             fontWeight: FontWeight.w400),
                            //       ),
                            // Spacer(),
                            // GetStorage().read('uid') ==
                            //         ((snapshot.data!.docs[index].data()
                            //             as Map)['uid'])
                            //     ? PopupMenuButton<String>(
                            //         // Callback that sets the selected popup menu item.
                            //         onSelected: null,
                            //         itemBuilder: (BuildContext context) =>
                            //             <PopupMenuEntry<String>>[
                            //               const PopupMenuItem<String>(
                            //                 value: "Delete",
                            //                 child: Text('Delete'),
                            //               ),
                            //             ])
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                      ),
                                      height: 500,
                                      width: double.infinity,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: List.generate(
                                                5,
                                                (index) => Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {},
                                                      child: CircleAvatar(
                                                        backgroundColor: Colors
                                                            .grey.shade200,
                                                        child: Icon(
                                                          iconsList[index]
                                                              ['icon'],
                                                          color: Colors.black,
                                                          size: 25,
                                                        ),
                                                        radius: 30,
                                                      ),
                                                    ),
                                                    SizedBox(height: 9),
                                                    Text(
                                                      iconsList[index]['name'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            thickness: 0.5,
                                            color: Colors.black12,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Icon(Icons.more_vert_outlined),
                            ),
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
                        border: const GradientBoxBorder(
                          gradient: LinearGradient(
                              colors: [Colors.blue, Colors.red, Colors.yellow]),
                          width: 2,
                        ),
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
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.favorite_border),
                        ),
                        Image.asset(
                          "assets/images/comment.png",
                          height: 22,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Image.asset(
                          "assets/images/send.png",
                          height: 22,
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
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
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
                                    source: ImageSource.gallery);
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
              MaterialButton(
                textColor: Colors.white,
                height: 50,
                minWidth: double.infinity,
                color: Colors.pink,
                child: Text("Upload"),
                onPressed: () async {
                  await createPost(image!, descriptionCtrl.text);
                  Get.back();
                },
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
    FirebaseFirestore.instance.collection("userPost").add(post);
  }
}
