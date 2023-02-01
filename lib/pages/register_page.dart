import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import '../components/email_text_field.dart';
import '../components/my_text_field.dart';
import '../components/my_button.dart';
import '../components/my_tile.dart';

class RegisterPage extends StatefulWidget {
  final Function()? togglePages;

  const RegisterPage({
    super.key,
    required this.togglePages,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();
  var currentEmail = 'advisor.one@iitrpr.ac.in';
  var currentOtp = '000';

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

  String generateOtp() {
    var num = Random();
    var newOtp = '';
    for (var i = 0; i < 10; i++) {
      newOtp = newOtp + num.nextInt(10).toString();
    }
    return newOtp;
  }

  Future sendEmail({
    required String toEmail,
    required String subject,
    required String message,
  }) async {
    const serviceId = 'service_rljav5j';
    const templateId = 'template_wl07e7f';
    const userId = 'NoIKuJYIW8bkIoVj1';

    try {
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      await http.post(
        url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'to_email': toEmail,
            'user_subject': subject,
            'user_message': message,
          },
        }),
      );
    } catch (e) {
      displayErrorMessage('emailjs-server-error');
    }
  }

  void sendOtp() async {
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

    var res = EmailValidator.validate(emailController.text);
    if (res) {
      currentEmail = emailController.value.text;
      currentOtp = generateOtp();

      try {
        await sendEmail(
          toEmail: emailController.value.text,
          subject: 'OTP Verification',
          message:
              'Greetings from LMS\nHere is your verification code: $currentOtp',
        );

        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        displayErrorMessage('otp-sent-successfully');
      } catch (e) {
        Navigator.pop(context);
        displayErrorMessage('could\'nt-send-otp');
      }
    } else {
      Navigator.pop(context);
      displayErrorMessage('invalid-email');
    }
  }

  void signUserUp() async {
    if (emailController.value.text == currentEmail &&
        otpController.value.text == currentOtp) {
      if (passwordController.value.text ==
          confirmPasswordController.value.text) {
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

        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: (passwordController.text == ''
                ? '-1'
                : passwordController.text),
          );
          // ignore: use_build_context_synchronously
          Navigator.pop(context);

          final docUser = FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid);
          final json = {
            'email': emailController.value.text,
            'id': FirebaseAuth.instance.currentUser?.uid,
            'role': 'student',
            'program': 'csb',
          };

          await docUser.set(json).onError(
              (error, stackTrace) => displayErrorMessage(error.toString()));
        } on FirebaseAuthException catch (e) {
          Navigator.pop(context);
          displayErrorMessage(e.code);
        }
      } else {
        displayErrorMessage('passwords-don\'t-match');
      }
    } else {
      displayErrorMessage('invalid-email-otp-combination');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.dashboard,
                  size: 100,
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  'I\'ve got a good feeling about this',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                EmailTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                  onPressed: sendOtp,
                ),
                const SizedBox(
                  height: 10,
                ),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                MyTextField(
                  controller: otpController,
                  hintText: 'Verification Code',
                  obscureText: false,
                ),
                const SizedBox(
                  height: 25,
                ),
                MyButton(
                  onTap: signUserUp,
                  text: 'Sign Up',
                ),
                const SizedBox(
                  height: 35,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    MyTile(
                      imagePath: '../assets/images/google.png',
                    )
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member?',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: const Text(
                        'Login now',
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
    );
  }
}
