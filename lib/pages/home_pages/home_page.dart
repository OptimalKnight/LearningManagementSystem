import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'student_home_page.dart';
import 'instructor_home_page.dart';
import 'advisor_home_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void signUserOut() async {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.black,
                actions: [
                  IconButton(
                    onPressed: signUserOut,
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
              backgroundColor: Colors.grey[300],
              body: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            );
          } else {
            var currentUserRole = snapshot.data!['role'].toString();
            if (currentUserRole == 'student') {
              return StudentHomePage(
                currentStudent: snapshot.data,
              );
            } else if (currentUserRole == 'instructor') {
              return InstructorHomePage(
                currentInstructor: snapshot.data,
              );
            } else {
              return AdvisorHomePage(
                currentAdvisor: snapshot.data,
              );
            }
          }
        },
      ),
    );
  }
}
