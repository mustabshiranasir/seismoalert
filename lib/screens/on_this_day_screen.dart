import 'package:flutter/material.dart';

class OnThisDayScreen extends StatelessWidget {
  const OnThisDayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('On This Day'),
      ),
      body: const Center(
        child: Text(
          'On This Day - Placeholder',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
