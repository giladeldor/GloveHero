import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glove_hero_app/models/ble.dart';
import 'package:glove_hero_app/utils/styles.dart';
import 'package:glove_hero_app/widgets/glove_controls.dart';

import '../models/controller_action.dart';

class GetNameDialog extends StatefulWidget {
  const GetNameDialog({super.key});

  @override
  State<GetNameDialog> createState() => _GetNameDialogState();
}

class _GetNameDialogState extends State<GetNameDialog> {
  final name = ['A', 'A', 'A'];
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return GloveControls(
      onTouch: _onTouch,
      child: AlertDialog(
        shadowColor: const Color.fromARGB(0, 0, 0, 0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        backgroundColor:
            const Color.fromARGB(255, 186, 203, 236).withAlpha(170),
        title: const Text(
          "Enter Your Name",
          textAlign: TextAlign.center,
          style: dialogTitleStyle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List<Widget>.generate(
                  3,
                  (i) => _LetterPicker(
                    letter: name[i],
                    selected: index == i,
                    onUp: () {
                      index = i;
                      _changeLetter(i, 1);
                    },
                    onDown: () {
                      index = i;
                      _changeLetter(i, -1);
                    },
                  ),
                )),
            TextButton(
              onPressed: () {
                Navigator.maybePop(context, name.join());
              },
              child: Text(
                "Save",
                style: highScoreTextStyle.copyWith(
                    fontSize: 25,
                    color: const Color.fromARGB(255, 246, 144, 119)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _incrementIndex() {
    index += 1;

    if (index >= name.length) {
      Navigator.maybePop(context, name.join());
    } else {
      setState(() {});
    }
  }

  void _decrementIndex() {
    setState(() {
      index = max(index - 1, 0);
    });
  }

  void _changeLetter(int index, int diff) {
    const alphabetLength = 26;
    final firstCodeUnit = 'A'.codeUnitAt(0);

    final letter = String.fromCharCode(
      firstCodeUnit +
          (name[index].codeUnitAt(0) - firstCodeUnit + diff) % alphabetLength,
    );

    setState(() {
      name[index] = letter;
    });
  }

  _onTouch(Input input) {
    final action = MenuAction.fromInput(input);

    switch (action) {
      case MenuAction.up:
        _changeLetter(index, 1);
        break;
      case MenuAction.down:
        _changeLetter(index, -1);
        break;
      case MenuAction.select:
        _incrementIndex();
        break;
      case MenuAction.back:
        _decrementIndex();
        break;
      default:
    }
  }
}

class _LetterPicker extends StatelessWidget {
  const _LetterPicker({
    required this.letter,
    required this.selected,
    this.onUp,
    this.onDown,
  });

  final String letter;
  final bool selected;
  final void Function()? onUp;
  final void Function()? onDown;

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color.fromARGB(179, 189, 31, 94);

    var textStyle = dialogTextStyle.copyWith(fontSize: 85);
    if (selected) {
      textStyle = textStyle.copyWith(color: selectedColor);
    }
    final iconColor = selected ? selectedColor : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _HandIconButton(
              direction: _Direction.up,
              onPress: onUp,
              color: iconColor,
            ),
            Text(
              letter,
              style: textStyle,
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 3.5)),
            _HandIconButton(
              direction: _Direction.down,
              onPress: onDown,
              color: iconColor,
            )
          ],
        )
      ],
    );
  }
}

enum _Direction {
  up,
  down;

  double get angle => this == _Direction.up ? -pi / 2 : pi / 2;
}

class _HandIconButton extends StatelessWidget {
  const _HandIconButton({
    required this.direction,
    required this.onPress,
    this.color,
  });

  final _Direction direction;
  final void Function()? onPress;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPress,
      icon: Transform.rotate(
        angle: direction.angle,
        child: ImageIcon(
          const AssetImage("assets/hand-selector.png"),
          size: 30,
          color: color ?? Colors.black54,
        ),
      ),
    );
  }
}
