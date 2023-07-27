import 'package:flutter/material.dart';
import 'package:glove_hero_app/models/controller_action.dart';
import '../utils/styles.dart';
import '../widgets/glove_controls.dart';

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
      ]),
    );
  }
}
