import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  CollectionReference favoriteCollection =
  FirebaseFirestore.instance.collection('favorite');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back),
                ),
                Text(
                  'Favorite items',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ],
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
              stream: favoriteCollection.snapshots(),
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
                return snapshot.data!.docs.length == 0
                    ? Center(
                  child: Text('No favorite collection'),
                )
                    : ListView.builder(
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

                    Map<String, dynamic> favorite =
                    snapshot.data!.docs[index].data()
                    as Map<String, dynamic>;

                    bool isFavorites = favorite['isFavorites'] ?? false;

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
                          padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      favorite['title'],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      favorite['price'].toString(),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      favorite['rating']['rate']
                                          .toString(),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text("${favorite['category']}"),
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
                                    image:
                                    NetworkImage(favorite['image']),
                                    height: 100,
                                    width: 100,
                                  ),
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
          )
        ],
      ),
    );
  }
}
