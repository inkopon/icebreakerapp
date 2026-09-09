import 'package:flutter/material.dart';

import '../../constants/general_constants.dart';

class Spinner extends StatefulWidget {
  const Spinner({super.key, this.backgroundColor, this.showText = false});

  final Color? backgroundColor;
  final bool showText;

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> {
  bool _displayText = false;

  @override
  void initState() {
    super.initState();

    if (widget.showText) {
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        setState(() {
          _displayText = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(
              backgroundColor: widget.backgroundColor ?? Colors.greenAccent,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 8.0),
            _displayText
                ? const Text(
                    'Vamos falar sobre...',
                    style: TextStyle(fontFamily: inkDefaultFont),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
