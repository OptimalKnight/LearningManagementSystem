import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../insufficient_data_page.dart';

class StudentHomePage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final currentStudent;

  const StudentHomePage({
    super.key,
    required this.currentStudent,
  });

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
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

  String getCourseStatus(String status) {
    if (status == '0') {
      return 'ENROLLED';
    } else if (status == '1') {
      return 'PENDING INSTRUCTOR APPROVAL';
    } else if (status == '2') {
      return 'REJECTED BY INSTRUCTOR';
    } else if (status == '3') {
      return 'PENDING ADVISOR APPROVAL';
    } else if (status == '4') {
      return 'REJECTED BY ADVISOR';
    } else if (status == '5') {
      return 'DROPPED BY STUDENT';
    } else {
      return 'AVAILABLE FOR ENROLLMENT';
    }
  }

  void enrolCourse(QueryDocumentSnapshot<Map<String, dynamic>> course) async {
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
        FirebaseFirestore.instance.collection('courses').doc(course['id']);
    final json = {
      'status': '1',
      'student_entry_number': widget.currentStudent['entry_number'],
      'student_id': widget.currentStudent['id'],
      'student_program': widget.currentStudent['program'],
    };

    try {
      await currentCourse.update({
        'enrollments': FieldValue.arrayUnion([json])
      });

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      displayErrorMessage('course-requested');
    } catch (e) {
      Navigator.pop(context);
      displayErrorMessage(e.toString());
    }
  }

  void dropCourse(
    QueryDocumentSnapshot<Map<String, dynamic>> course,
    String courseStatus,
  ) async {
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
        FirebaseFirestore.instance.collection('courses').doc(course['id']);

    try {
      var json = {
        'status': courseStatus,
        'student_entry_number': widget.currentStudent['entry_number'],
        'student_id': widget.currentStudent['id'],
        'student_program': widget.currentStudent['program'],
      };
      await currentCourse.update({
        'enrollments': FieldValue.arrayRemove([json])
      });

      json = {
        'status': '5',
        'student_entry_number': widget.currentStudent['entry_number'],
        'student_id': widget.currentStudent['id'],
        'student_program': widget.currentStudent['program'],
      };
      await currentCourse.update({
        'enrollments': FieldValue.arrayUnion([json])
      });

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      displayErrorMessage('course-dropped');
    } catch (e) {
      Navigator.pop(context);
      displayErrorMessage(e.toString());
    }
  }

  Widget buildCourseTile(QueryDocumentSnapshot<Map<String, dynamic>> course) {
    String courseStatus = '-1';
    for (var enrollment in course.data()['enrollments']) {
      if (enrollment['student_id'] == widget.currentStudent['id']) {
        courseStatus = enrollment['status'];
      }
    }
    courseStatus = getCourseStatus(courseStatus);

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
              course.data()['code'].toString().toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              course.data()['name'] + '\n' + courseStatus,
            ),
            isThreeLine: true,
            trailing: ((courseStatus == 'REJECTED BY INSTRUCTOR' ||
                    courseStatus == 'REJECTED BY ADVISOR' ||
                    courseStatus == 'DROPPED BY STUDENT')
                ? null
                : Container(
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
                      onPressed: (courseStatus == 'AVAILABLE FOR ENROLLMENT'
                          ? () => enrolCourse(course)
                          : () => dropCourse(
                              course,
                              (courseStatus == 'ENROLLED'
                                  ? '0'
                                  : (courseStatus ==
                                          'PENDING INSTRUCTOR APPROVAL'
                                      ? '1'
                                      : '3')))),
                      style: ButtonStyle(
                        backgroundColor:
                            const MaterialStatePropertyAll<Color>(Colors.black),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.all(20.0)),
                      ),
                      child: Text(
                        (courseStatus == 'AVAILABLE FOR ENROLLMENT'
                            ? 'Enrol'
                            : 'Drop'),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          var availableCourses = [];
          if (snapshot.hasData) {
            for (var course in snapshot.data!.docs) {
              for (var allowedCoursePrograms in course.data()['offered_for']) {
                if (allowedCoursePrograms == widget.currentStudent['program']) {
                  availableCourses.add(course);
                }
              }
            }
          }

          return Scaffold(
            backgroundColor: Colors.grey[300],
            appBar: AppBar(
              title: Text(
                  // ignore: prefer_interpolation_to_compose_strings
                  '${'Student Home Page (Logged In As ' + widget.currentStudent['name']})'),
              backgroundColor: Colors.black,
              actions: [
                IconButton(
                  onPressed: signUserOut,
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            body: (snapshot.hasData
                ? (availableCourses.isEmpty
                    ? const InsufficientDataPage(
                        textToDisplay: 'No available courses at the moment...',
                      )
                    : Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                for (var course in availableCourses)
                                  buildCourseTile(course)
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
          );
        },
      ),
    );
  }
}
