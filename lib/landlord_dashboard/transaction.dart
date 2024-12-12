import 'package:flutter/material.dart';

class Transaction extends StatelessWidget {
  const Transaction({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          'Transaction',
          style: TextStyle(color: Color.fromARGB(255, 235, 238, 238)),
        )),
        backgroundColor: Color.fromARGB(255, 12, 112, 117),
      ),
    );
  }
}
