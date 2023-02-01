import 'package:flutter/material.dart';

class EmailTextField extends StatefulWidget {
  final Function()? onPressed;
  final dynamic controller;
  final String hintText;
  final bool obscureText;

  const EmailTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.onPressed,
  });

  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextButton(
              onPressed: widget.onPressed,
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.focused)) {
                      return Colors.white54;
                    } else if (states.contains(MaterialState.hovered)) {
                      return Colors.white54;
                    } else if (states.contains(MaterialState.pressed)) {
                      return Colors.white54;
                    }
                    return Colors.grey[300];
                  },
                ),
              ),
              child: const Text(
                'Send OTP',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
