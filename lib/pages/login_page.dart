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

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();
  var currentEmail = '-1';
  var currentOtp = '-1';

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
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password:
              (passwordController.text == '' ? '-1' : passwordController.text),
        );

        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        displayErrorMessage(e.code);
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
                    image: AssetImage('assets/images/background.webp'),
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
                        'Welcome home',
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
                        controller: otpController,
                        hintText: 'Verification Code',
                        obscureText: false,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      MyButton(
                        onTap: signUserUp,
                        text: 'Sign In',
                      ),
                      const SizedBox(
                        height: 50,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
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
                            imagePath: 'assets/images/google.png',
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
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
