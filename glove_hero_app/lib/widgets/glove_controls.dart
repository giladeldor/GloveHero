import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/ble.dart';

class GloveControls extends StatefulWidget {
  const GloveControls(
      {super.key,
      required this.child,
      this.onPress,
      this.onTouch,
      this.onPop,
      this.onLifecycleChange});

  final Widget child;
  final Function(Input input)? onPress;
  final Function(Input input)? onTouch;
  final Function()? onPop;
  final Function(AppLifecycleState state)? onLifecycleChange;

  @override
  State<GloveControls> createState() => _GloveControlsState();
}

class _GloveControlsState extends State<GloveControls>
    with WidgetsBindingObserver {
  late BleInput _input;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _input = context.read<BleInput>();

      if (widget.onPress != null) {
        _input.addPressListener(widget.onPress!);
      }

      if (widget.onTouch != null) {
        _input.addTouchListener(widget.onTouch!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: widget.child,
        onWillPop: () async {
          if (widget.onPress != null) {
            _input.removePressListener(widget.onPress!);
          }

          if (widget.onTouch != null) {
            _input.removeTouchListener(widget.onTouch!);
          }

          widget.onPop?.call();

          return true;
        });
  }

  @override
  void dispose() {
    super.dispose();

    if (widget.onPress != null) {
      _input.removePressListener(widget.onPress!);
    }

    if (widget.onTouch != null) {
      _input.removeTouchListener(widget.onTouch!);
    }

    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      widget.onLifecycleChange?.call(state);
}
