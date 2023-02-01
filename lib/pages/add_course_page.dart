import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';
import '../pages/home_pages/advisor_home_page.dart';
import '../pages/home_pages/instructor_home_page.dart';

class AddCoursePage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final currentUser;
  // ignore: prefer_typing_uninitialized_variables
  final toInstructorHomePage;

  const AddCoursePage({
    super.key,
    required this.currentUser,
    required this.toInstructorHomePage,
  });

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final courseCodeController = TextEditingController();
  final courseNameController = TextEditingController();
  final List<String> programs = <String>['csb', 'mcb', 'eeb', 'meb'];
  final List<bool> selectedPrograms = <bool>[false, false, false, false];

  List<Widget> programsTile = <Widget>[
    const Text('CSB'),
    const Text('MCB'),
    const Text('EEB'),
    const Text('MEB'),
  ];

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

  void addCourse() async {
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => (widget.toInstructorHomePage
            ? InstructorHomePage(
                currentInstructor: widget.currentUser,
              )
            : AdvisorHomePage(
                currentAdvisor: widget.currentUser,
              )),
      ),
    );

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

    var offeredFor = [];
    for (var i = 0; i < programs.length; i++) {
      if (selectedPrograms[i]) {
        offeredFor.add(programs[i]);
      }
    }

    try {
      final docRef =
          await FirebaseFirestore.instance.collection('courses').add({
        'code': courseCodeController.value.text.toLowerCase(),
        'enrollments': [],
        'id': '',
        'instructor_id': widget.currentUser['id'],
        'name': courseNameController.value.text,
        'offered_for': offeredFor,
      });

      await FirebaseFirestore.instance
          .collection('courses')
          .doc(docRef.id)
          .update(
        {'id': docRef.id},
      );

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      displayErrorMessage('course-added-successfully');
    } catch (e) {
      Navigator.pop(context);
      displayErrorMessage(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Stack(
          children: [
            ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [Colors.black, Colors.transparent],
              ).createShader(rect),
              blendMode: BlendMode.darken,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('../assets/images/background.webp'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black54,
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 600,
                  height: 800,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 10.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Icon(
                        Icons.dashboard,
                        size: 100,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Text(
                        'Art is all in the details',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      MyTextField(
                          controller: courseCodeController,
                          hintText: 'Course Code',
                          obscureText: false),
                      const SizedBox(
                        height: 10,
                      ),
                      MyTextField(
                        controller: courseNameController,
                        hintText: 'Course Name',
                        obscureText: false,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 110.0, vertical: 10.0),
                        child: Column(
                          children: [
                            Text(
                              'Course Offered For',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ToggleButtons(
                              direction: Axis.horizontal,
                              onPressed: (int index) {
                                // All buttons are selectable.
                                setState(() {
                                  selectedPrograms[index] =
                                      !selectedPrograms[index];
                                });
                              },
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              selectedBorderColor: Colors.white,
                              selectedColor: Colors.white,
                              fillColor: Colors.grey[500],
                              color: Colors.grey[500],
                              constraints: const BoxConstraints(
                                minHeight: 40.0,
                                minWidth: 80.0,
                              ),
                              isSelected: selectedPrograms,
                              children: programsTile,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      MyButton(
                        onTap: addCourse,
                        text: 'Add Course',
                      ),
                      const SizedBox(
                        height: 180,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Not feeling good?',
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          GestureDetector(
                            onTap: () => {
                              Navigator.pop(context),
                            },
                            child: const Text(
                              'Go back',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
