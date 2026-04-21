import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/conversion_record.dart';
import '../services/history_service.dart';

/// Oxirgi konvertatsiyalar chiplari. `HistoryService.instance` ga reaktiv —
/// yangi record qo'shilsa avtomatik yangilanadi.
class RecentSection extends StatefulWidget {
  const RecentSection({super.key, required this.onTap});

  final ValueChanged<ConversionRecord> onTap;

  @override
  State<RecentSection> createState() => _RecentSectionState();
}

class _RecentSectionState extends State<RecentSection> {
  final _service = HistoryService.instance;
  List<ConversionRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _service.addListener(_onHistoryChanged);
    _loadRecords();
  }

  @override
  void dispose() {
    _service.removeListener(_onHistoryChanged);
    super.dispose();
  }

  void _onHistoryChanged() {
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await _service.getRecords();
    if (mounted) {
      setState(() {
        _records = records.take(6).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_records.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Oxirgi konvertatsiyalar',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white38 : AppColors.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _records.map((record) {
            final input = record.inputText.length > 12
                ? '${record.inputText.substring(0, 12)}…'
                : record.inputText;
            final output = record.outputText.length > 12
                ? '${record.outputText.substring(0, 12)}…'
                : record.outputText;

            return GestureDetector(
              onTap: () => widget.onTap(record),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : AppColors.cream,
                  border: Border.all(
                    color: isDark ? Colors.white12 : AppColors.cardBorder,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '$input → $output',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : AppColors.textDark,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
