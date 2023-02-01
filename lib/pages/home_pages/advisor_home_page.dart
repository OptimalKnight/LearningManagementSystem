import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../insufficient_data_page.dart';
import '../add_course_page.dart';

class AdvisorHomePage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final currentAdvisor;

  const AdvisorHomePage({
    super.key,
    required this.currentAdvisor,
  });

  @override
  State<AdvisorHomePage> createState() => _AdvisorHomePageState();
}

class _AdvisorHomePageState extends State<AdvisorHomePage> {
  void displayErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              message,
            ),
          ),
        );
      },
    );
  }

  void signUserOut() async {
    FirebaseAuth.instance.signOut();
  }

  void acceptRequest(List<dynamic> request) async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        );
      },
    );

    final currentCourse =
        FirebaseFirestore.instance.collection('courses').doc(request[3]);

    try {
      var json = {
        'status': (request[6] ? '3' : '1'),
        'student_entry_number': request[2],
        'student_id': request[5],
        'student_program': request[4],
      };
      await currentCourse.update({
        'enrollments': FieldValue.arrayRemove([json])
      });

      json = {
        'status': (request[6] ? '0' : '3'),
        'student_entry_number': request[2],
        'student_id': request[5],
        'student_program': request[4],
      };
      await currentCourse.update({
        'enrollments': FieldValue.arrayUnion([json])
      });
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      displayErrorMessage('request-accepted');
    } catch (e) {
      Navigator.pop(context);
      displayErrorMessage(e.toString());
    }
  }

  void rejectRequest(List<dynamic> request) async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        );
      },
    );

    final currentCourse =
        FirebaseFirestore.instance.collection('courses').doc(request[3]);

    try {
      var json = {
        'status': (request[6] ? '3' : '1'),
        'student_entry_number': request[2],
        'student_id': request[5],
        'student_program': request[4],
      };
      await currentCourse.update({
        'enrollments': FieldValue.arrayRemove([json])
      });

      json = {
        'status': (request[6] ? '4' : '2'),
        'student_entry_number': request[2],
        'student_id': request[5],
        'student_program': request[4],
      };
      await currentCourse.update({
        'enrollments': FieldValue.arrayUnion([json])
      });

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      displayErrorMessage('request-rejected');
    } catch (e) {
      Navigator.pop(context);
      displayErrorMessage(e.toString());
    }
  }

  Widget buildCourseTile(List<dynamic> request) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Card(
        color: Colors.grey[100],
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: const Icon(
              Icons.library_books,
              color: Colors.black,
              size: 30,
            ),
          ),
          title: Text(
            request[0].toString().toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            request[1] +
                '\n' +
                'COURSE REQUESTED BY ' +
                request[2].toString().toUpperCase() +
                (request[6] ? ' (ADVISOR' : ' (INSTRUCTOR') +
                ' REQUEST)',
          ),
          isThreeLine: true,
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: (() => acceptRequest(request)),
                style: ButtonStyle(
                  backgroundColor:
                      const MaterialStatePropertyAll<Color>(Colors.black),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(20.0)),
                ),
                child: const Text(
                  'Accept',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: (() => rejectRequest(request)),
                style: ButtonStyle(
                  backgroundColor:
                      const MaterialStatePropertyAll<Color>(Colors.black),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(20.0)),
                ),
                child: const Text(
                  'Reject',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          var currentRequests = [];
          if (snapshot.hasData) {
            for (var course in snapshot.data!.docs) {
              for (var enrollment in course.data()['enrollments']) {
                var data = [
                  course.data()['code'],
                  course.data()['name'],
                  enrollment['student_entry_number'],
                  course.data()['id'],
                  enrollment['student_program'],
                  enrollment['student_id'],
                  false,
                ];

                if (course.data()['instructor_id'] ==
                        widget.currentAdvisor['id'] &&
                    enrollment['status'] == '1') {
                  currentRequests.add(data);
                }

                if (enrollment['status'] == '3' &&
                    enrollment['student_program'] ==
                        widget.currentAdvisor['program']) {
                  data[6] = true;
                  currentRequests.add(data);
                }
              }
            }
          }

          return Scaffold(
            backgroundColor: Colors.grey[300],
            appBar: AppBar(
              title: Text(
                  // ignore: prefer_interpolation_to_compose_strings
                  '${'Advisor Home Page (Logged In As ' + widget.currentAdvisor['name']})'),
              backgroundColor: Colors.black,
              actions: [
                IconButton(
                  onPressed: signUserOut,
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            body: (snapshot.hasData
                ? (currentRequests.isEmpty
                    ? const InsufficientDataPage(
                        textToDisplay:
                            'No requests to process at the moment...',
                      )
                    : Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                for (var request in currentRequests)
                                  buildCourseTile(request)
                              ],
                            ),
                          ),
                        ],
                      ))
                : const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCoursePage(
                      currentUser: widget.currentAdvisor,
                      toInstructorHomePage: false,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.black,
              label: const Text('Add Course'),
              icon: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
