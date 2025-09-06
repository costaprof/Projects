import 'package:flutter/material.dart';

class RezeptKartenButton extends StatefulWidget {
  final String initialLabel;
  final String confirmationLabel;
  final VoidCallback onPressed;
  final IconData? initialIcon;
  final IconData? confirmationIcon;

  const RezeptKartenButton({
    super.key,
    required this.initialLabel,
    required this.confirmationLabel,
    required this.onPressed,
    this.initialIcon,
    this.confirmationIcon,
  });

  @override
  State<RezeptKartenButton> createState() => _RezeptKartenButtonState();
}

class _RezeptKartenButtonState extends State<RezeptKartenButton> {
  bool isConfirmed = false;

  @override
  void initState() {
    super.initState();
    isConfirmed = false;
  }

  void _handlePressed() {
    widget.onPressed();
    setState(() {
      isConfirmed = !isConfirmed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _handlePressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isConfirmed
                ? (widget.confirmationIcon ?? Icons.remove)
                : (widget.initialIcon ?? Icons.add),
          ),
          const SizedBox(width: 8),
          Text(isConfirmed ? widget.confirmationLabel : widget.initialLabel),
        ],
      ),
    );
  }
}
