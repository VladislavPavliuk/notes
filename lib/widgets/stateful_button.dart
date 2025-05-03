import 'package:flutter/material.dart';

enum ButtonState { idle, loading, success, error, disabled }

class StatefulButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonState state;
  final IconData? successIcon;
  final IconData? errorIcon;
  final Color? color;
  final double height;
  final double width;

  const StatefulButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.state = ButtonState.idle,
    this.successIcon = Icons.check,
    this.errorIcon = Icons.close,
    this.color,
    this.height = 48.0,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = state == ButtonState.disabled || state == ButtonState.loading;

    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? Colors.grey
              : color ?? Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isDisabled ? null : onPressed,
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    switch (state) {
      case ButtonState.loading:
        return const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case ButtonState.success:
        return Icon(successIcon, color: Colors.white);
      case ButtonState.error:
        return Icon(errorIcon, color: Colors.white);
      case ButtonState.disabled:
      case ButtonState.idle:
      default:
        return Text(
          text,
          style: const TextStyle(color: Colors.white),
        );
    }
  }
}
