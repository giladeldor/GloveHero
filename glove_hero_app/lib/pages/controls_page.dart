import 'package:flutter/material.dart';

class ControlsPage extends StatefulWidget {
  const ControlsPage({super.key});

  @override
  State<ControlsPage> createState() => _ControlsPage();
}

class _ControlsPage extends State<ControlsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/controls-glove.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
