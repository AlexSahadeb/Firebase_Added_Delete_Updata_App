import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cloud_firestore_app/view/addnewcourse.dart';
import 'package:flutter_cloud_firestore_app/view/update_course.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);
  addNewCourse(context) {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => AddNewCourse());
  }

  final Stream<QuerySnapshot> _courseStream =
      FirebaseFirestore.instance.collection('courses').snapshots();
  Future<void> deletedCourse(selectedDocument) async {
    return FirebaseFirestore.instance
        .collection("courses")
        .doc(selectedDocument)
        .delete()
        .then((value) => print("Course han been deleted"))
        .catchError((error) => print(error));
  }

  Future<void> updateCourse(
      selectedDocumentID, title, description, img, context) async {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => UpdateACourse(
              selectedDocumentID,
              title,
              description,
              img,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Course"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () => addNewCourse(context), icon: Icon(Icons.add))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _courseStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(right: 20, left: 20),
                child: Stack(
                  children: [
                    Container(
                      height: 200,
                      child: Card(
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Container(
                                      width: double.maxFinite,
                                      child: Image.network(
                                        data["Image"],
                                        fit: BoxFit.cover,
                                      ))),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                data["Course Name"],
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 20),
                              ),
                              Text(data["Course Details"])
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        right: 0,
                        child: Card(
                          child: Container(
                            height: 60,
                            width: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    onPressed: () => updateCourse(
                                        document.id,
                                        data["Course Name"],
                                        data["Course Details"],
                                        data["Image"],
                                        context),
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.amber,
                                    )),
                                IconButton(
                                    onPressed: () => deletedCourse(document.id),
                                    icon: Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ))
                              ],
                            ),
                          ),
                        ))
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
