import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SwapButton extends StatefulWidget {
  final VoidCallback onTap;

  const SwapButton({super.key, required this.onTap});

  @override
  State<SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<SwapButton> {
  double _rotationTurns = 0.0;

  void _handleTap() {
    setState(() {
      _rotationTurns += 0.5;
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Konvertatsiya yo\'nalishini almashtirish',
      button: true,
      child: Tooltip(
        message: 'Yo\'nalishni almashtirish',
        child: AnimatedRotation(
          turns: _rotationTurns,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Material(
            elevation: 4,
            shadowColor: AppColors.orange.withValues(alpha: 0.3),
            shape: const CircleBorder(),
            color: AppColors.orange,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _handleTap,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.swap_vert_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
