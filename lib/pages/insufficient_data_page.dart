import 'package:flutter/material.dart';

class InsufficientDataPage extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final textToDisplay;
  const InsufficientDataPage({
    super.key,
    required this.textToDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.now_widgets,
            size: 50,
            color: Colors.black12,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            textToDisplay,
            style: const TextStyle(fontSize: 30),
            textAlign: TextAlign.center,
          ),
        ],
      )),
    );
  }
}
