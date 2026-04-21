import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/history_service.dart';
import '../services/stats_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Future<StatsData> _future;

  @override
  void initState() {
    super.initState();
    _future = StatsService.compute();
    HistoryService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    HistoryService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (mounted) {
      setState(() {
        _future = StatsService.compute();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistika'),
      ),
      body: FutureBuilder<StatsData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = snapshot.data;
          if (stats == null || stats.isEmpty) {
            return const _EmptyState();
          }
          return _StatsContent(stats: stats);
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded,
              size: 64, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'Hali konvertatsiyalar yo\'q',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent({required this.stats});
  final StatsData stats;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatsGrid(stats: stats),
        const SizedBox(height: 24),
        _DirectionBar(stats: stats),
        const SizedBox(height: 24),
        _DailyChart(dailyCounts: stats.dailyCounts),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});
  final StatsData stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          icon: Icons.translate_rounded,
          label: 'Jami',
          value: '${stats.totalCount}',
          color: AppColors.orange,
        ),
        _StatCard(
          icon: Icons.star_rounded,
          label: 'Sevimlilar',
          value: '${stats.favoritesCount}',
          color: AppColors.purple,
        ),
        _StatCard(
          icon: Icons.text_fields_rounded,
          label: 'Belgilar',
          value: _formatNum(stats.totalChars),
          color: AppColors.lightBlue,
        ),
        _StatCard(
          icon: Icons.trending_up_rounded,
          label: 'Eng uzun',
          value: '${stats.longestConversion}',
          color: AppColors.orange,
        ),
      ],
    );
  }

  String _formatNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionBar extends StatelessWidget {
  const _DirectionBar({required this.stats});
  final StatsData stats;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = stats.totalCount;
    final latinPct = total == 0 ? 0.0 : stats.latinToCyrillicCount / total;
    final cyrillicPct = total == 0 ? 0.0 : stats.cyrillicToLatinCount / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yo\'nalish taqsimoti',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 24,
            child: Row(
              children: [
                if (latinPct > 0)
                  Expanded(
                    flex: (latinPct * 1000).round(),
                    child: Container(color: AppColors.purple),
                  ),
                if (cyrillicPct > 0)
                  Expanded(
                    flex: (cyrillicPct * 1000).round(),
                    child: Container(color: AppColors.lightBlue),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Legend(
              color: AppColors.purple,
              label: 'Lotin → Kirill',
              value: '${stats.latinToCyrillicCount} (${(latinPct * 100).toStringAsFixed(0)}%)',
            ),
            _Legend(
              color: AppColors.lightBlue,
              label: 'Kirill → Lotin',
              value: '${stats.cyrillicToLatinCount} (${(cyrillicPct * 100).toStringAsFixed(0)}%)',
            ),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, required this.value});
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : AppColors.textLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyChart extends StatelessWidget {
  const _DailyChart({required this.dailyCounts});
  final List<int> dailyCounts;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxValue = dailyCounts.fold<int>(
        0, (max, v) => v > max ? v : max);
    final labels = _generateDayLabels();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Oxirgi 7 kun',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final index = 6 - i; // chapdan o'ngga: 6 kun oldingi → bugun
              final count = dailyCounts[index];
              final heightFraction = maxValue == 0 ? 0.0 : count / maxValue;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            height: 120 * heightFraction + 4,
                            decoration: BoxDecoration(
                              color: count > 0
                                  ? AppColors.orange
                                  : (isDark ? Colors.white12 : AppColors.cardBorder),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white54 : AppColors.textLight,
                        ),
                      ),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: count > 0
                              ? (isDark ? Colors.white : AppColors.textDark)
                              : (isDark ? Colors.white38 : AppColors.textLight),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  List<String> _generateDayLabels() {
    const weekdays = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return weekdays[day.weekday - 1];
    });
  }
}
