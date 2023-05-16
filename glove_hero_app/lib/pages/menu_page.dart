import 'package:flutter/material.dart';
import '../utils.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    const buttonPadding = EdgeInsets.symmetric(vertical: 8, horizontal: 0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/menu-background.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 36.0, bottom: 16.0),
              child: Text(
                "Glove Hero",
                style: titleTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: buttonPadding,
              child: _MenuButton(
                title: "Single Player",
                onPressed: () {},
                selected: true,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: _MenuButton(
                title: "Multiplayer",
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: _MenuButton(
                title: "Recording Mode",
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _MenuButton(
                title: "Leaderboard",
                onPressed: () {},
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: _MenuButton(
                title: "Statistics",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    // ignore: unused_element
    super.key,
    required this.title,
    this.onPressed,
    this.selected = false,
  });

  final String title;
  final void Function()? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = onPressed == null
        ? Colors.grey
        : const Color.fromARGB(255, 242, 255, 235);

    final label = FittedBox(
      child: Text(
        title,
        style: titleTextStyle.copyWith(
          fontSize: 25,
          color: color,
        ),
      ),
    );

    return selected
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: ImageIcon(
              const AssetImage("assets/hand-selector.png"),
              size: 30,
              color: color,
            ),
            label: label,
          )
        : OutlinedButton(
            onPressed: onPressed,
            child: label,
          );
  }
}
