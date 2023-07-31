import 'package:flutter/material.dart';

import '../models/controller_action.dart';
import '../utils/styles.dart';
import '../widgets/glove_controls.dart';

/// A page that displays the controls for the glove.
class ControlsPage extends StatelessWidget {
  const ControlsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GloveControls(
      onTouch: (input) {
        final action = MenuAction.fromInput(input);
        if (action == MenuAction.back) {
          Navigator.of(context).maybePop();
        }
      },
      child: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: AssetImage(
                "assets/backgrounds/controls-glove-background.jpg",
              ),
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
      ]),
    );
  }
}
