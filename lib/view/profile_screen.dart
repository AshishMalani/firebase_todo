import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: Get.height * 0.02,
                  ),
                  Row(
                    children: [
                      Icon(Icons.lock_open),
                      SizedBox(
                        width: Get.width * 0.008,
                      ),
                      Text(
                        "User Name",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(
                        width: Get.width * 0.005,
                      ),
                      Icon(Icons.arrow_drop_down),
                      SizedBox(
                        width: Get.width * 0.01,
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.add_box_outlined),
                      ),
                      SizedBox(
                        width: Get.width * 0.015,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.menu),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Get.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CircleAvatar(radius: 38),
                      SizedBox(
                        width: Get.width * 0.01,
                      ),
                      Column(
                        children: [
                          Text(
                            "4",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: Get.height * 0.003,
                          ),
                          Text(
                            "Post",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "1 K",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: Get.height * 0.003,
                          ),
                          Text(
                            "Followers",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "100",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: Get.height * 0.003,
                          ),
                          Text(
                            "Following",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Get.height * 0.02,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: Get.height * 0.005,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: Get.height * 0.05,
                        width: Get.width * 0.78,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade300,
                        ),
                        child: Center(
                          child: Text(
                            "Edit profile",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        height: Get.height * 0.05,
                        width: Get.width * 0.11,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.person_add_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 50,
              width: double.infinity,
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: Colors.black,
                controller: tabController,
                tabs: [
                  Icon(
                    Icons.grid_view,
                    color: Colors.black,
                    size: 28,
                  ),
                  Icon(
                    Icons.bookmark_border,
                    color: Colors.black,
                    size: 28,
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  GridView.builder(
                    itemCount: 4,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        height: 100,
                        width: 89,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  Center(
                    child: Text("Saved Posts"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
