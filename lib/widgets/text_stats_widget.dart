import 'package:flutter/material.dart';

class TextStatsWidget extends StatelessWidget {
  final TextEditingController controller;

  const TextStatsWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final text = controller.text;
    final charCount = text.length;
    final wordCount =
        text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;

    return AnimatedOpacity(
      opacity: text.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          '$charCount ta belgi · $wordCount ta so\'z',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
    );
  }
}
