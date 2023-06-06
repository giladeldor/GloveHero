import 'package:flutter/material.dart';

class ControlsPage extends StatelessWidget {
  const ControlsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/controls-glove.jpg"),
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}
