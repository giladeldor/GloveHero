import 'package:flutter/material.dart';

import '../styles.dart';

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
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 8),
        child: FittedBox(
          child: Text(
            "Controls",
            style: titleTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      )
    ]);
  }
}
