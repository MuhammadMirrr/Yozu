import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// Input maydoni — o'zining `TextEditingController` listener bilan.
///
/// Character counter va Clear tugmasi faqat shu widget ichida rebuild qilinadi,
/// butun `ConverterScreen` emas.
class InputAreaWidget extends StatefulWidget {
  const InputAreaWidget({
    super.key,
    required this.controller,
    required this.isLatinToCyrillic,
    required this.onChanged,
    required this.onPaste,
    required this.onClear,
    required this.onImport,
  });

  final TextEditingController controller;
  final bool isLatinToCyrillic;
  final ValueChanged<String> onChanged;
  final VoidCallback onPaste;
  final VoidCallback onClear;
  final VoidCallback onImport;

  @override
  State<InputAreaWidget> createState() => _InputAreaWidgetState();
}

class _InputAreaWidgetState extends State<InputAreaWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = isDark
        ? colorScheme.surfaceContainerHighest
        : AppColors.cream;
    final inputText = widget.controller.text;
    final charCount = inputText.length;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          TextFormField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            maxLines: 4,
            minLines: 2,
            maxLength: 10000,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            buildCounter: (context,
                {required currentLength,
                required isFocused,
                required maxLength}) {
              if (currentLength > 9000) {
                return Text('$currentLength / $maxLength');
              }
              return null;
            },
            keyboardType: TextInputType.multiline,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : AppColors.textDark,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: widget.isLatinToCyrillic
                  ? 'Lotincha yozing...'
                  : 'Кириллча ёзинг...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : AppColors.textLight,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _MiniAction(
                icon: Icons.content_paste_rounded,
                onTap: widget.onPaste,
                tooltip: 'Qo\'yish',
              ),
              const SizedBox(width: 4),
              _MiniAction(
                icon: Icons.upload_file_rounded,
                onTap: widget.onImport,
                tooltip: 'Fayldan import (.txt, .docx)',
              ),
              const SizedBox(width: 4),
              _MiniAction(
                icon: Icons.close_rounded,
                onTap: inputText.isNotEmpty ? widget.onClear : null,
                tooltip: 'Tozalash',
              ),
              const Spacer(),
              AnimatedOpacity(
                opacity: inputText.isNotEmpty ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '$charCount ta belgi',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = onTap != null
        ? (isDark ? Colors.white54 : AppColors.textLight)
        : (isDark ? Colors.white24 : AppColors.cardBorder);
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      splashRadius: 20,
    );
  }
}
