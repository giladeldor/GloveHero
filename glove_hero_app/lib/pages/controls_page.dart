import 'package:flutter/material.dart';
import '../utils/styles.dart';

class ControlsPage extends StatelessWidget {
  const ControlsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/controls-glove.jpg"),
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
      const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FittedBox(
            alignment: Alignment.center,
            child: Text(
              "Controls",
              style: titleTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ]);
  }
}
