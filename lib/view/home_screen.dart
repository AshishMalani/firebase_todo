import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('Product');

  CollectionReference favoriteCollection =
  FirebaseFirestore.instance.collection('favorite');

  late String uid;
  @override
  void initState() {
    uid = GetStorage().read("uid");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Products",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              GetStorage().remove("uid");
              Get.offAll(LoginScreen());
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black54,
        onPressed: () {},
        child: Icon(Icons.favorite),
      ),
      backgroundColor: Color(0xffD0D2CF),
      body: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Products',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: Color(0xffBCBBBC),
              thickness: 2,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: usersCollection.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  itemBuilder: (BuildContext context, int index) {
                    // List<Map<String, dynamic>> productJsonData = [];
                    //
                    // snapshot.data!.docs.forEach((element) {
                    //   productJsonData
                    //       .add(element.data() as Map<String, dynamic>);
                    // });
                    //
                    // ProductModel product = productModelFromJson(
                    //     jsonEncode(productJsonData))[index];

                    Map<String, dynamic> product = snapshot.data!.docs[index]
                        .data() as Map<String, dynamic>;

                    bool isFavorites = false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 30),
                        height: 160,
                        width: 200,
                        decoration: BoxDecoration(
                            color: Color(0xffF6F6F6),
                            borderRadius: BorderRadius.circular(30)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      product['title'],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      product['price'].toString(),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    // Text(
                                    //   product.rating.rate.toString(),
                                    // ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text("${product['category']}"),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 72,
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Image(
                                    image: NetworkImage(
                                      product['image'],
                                    ),
                                    height: 100,
                                    width: 100,
                                  ),
                                  StreamBuilder<DocumentSnapshot>(
                                      stream: favoriteCollection
                                          .doc(uid)
                                          .snapshots(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<DocumentSnapshot>
                                          favoriteSnapshot) {
                                        if (favoriteSnapshot.hasError) {
                                          return SizedBox();
                                        }
                                        if (favoriteSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: SizedBox(),
                                          );
                                        }

                                        bool isFavorite = false;
                                        for (var x
                                        in (favoriteSnapshot.data!.data()
                                        as Map<String, dynamic>)[
                                        'favorite']) {
                                          if (x ==
                                              snapshot.data!.docs[index].id) {
                                            isFavorite = true;
                                            break;
                                          }
                                        }
                                        return IconButton(
                                          onPressed: () {
                                            if (isFavorite) {
                                              favoriteCollection
                                                  .doc(uid)
                                                  .update({
                                                "favorite":
                                                FieldValue.arrayRemove([
                                                  snapshot
                                                      .data!.docs[index].id
                                                ])
                                              })
                                                  .then((value) =>
                                                  print('Item remove'))
                                                  .catchError((error) => print(
                                                  'Item not removed'));
                                            } else {
                                              favoriteCollection
                                                  .doc(uid)
                                                  .update({
                                                "favorite":
                                                FieldValue.arrayUnion([
                                                  snapshot
                                                      .data!.docs[index].id
                                                ])
                                              })
                                                  .then((value) =>
                                                  print('Item added'))
                                                  .catchError((error) =>
                                                  print('Item not added'));
                                            }
                                          },
                                          icon: Icon(
                                            Icons.favorite,
                                            color: isFavorite
                                                ? Colors.red
                                                : Colors.grey,
                                          ),
                                        );
                                      })
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: snapshot.data!.docs.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
