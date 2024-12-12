import 'package:flutter/material.dart';

class Messaging extends StatelessWidget {
  const Messaging({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          'Messages',
          style: TextStyle(color: Color.fromARGB(255, 235, 238, 238)),
        )),
        backgroundColor: Color.fromARGB(255, 12, 112, 117),
      ),
    );
  }
}
