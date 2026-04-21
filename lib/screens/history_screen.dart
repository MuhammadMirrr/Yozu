import 'package:flutter/material.dart';
import '../models/conversion_record.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _historyService = HistoryService.instance;
  List<ConversionRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final records = await _historyService.getRecords();
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('HistoryScreen: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarixni yuklashda xatolik yuz berdi')),
        );
      }
    }
  }

  Future<void> _toggleFavorite(String id) async {
    try {
      await _historyService.toggleFavorite(id);
      await _loadRecords();
    } catch (e) {
      debugPrint('HistoryScreen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sevimliga qo\'shishda xatolik yuz berdi')),
        );
      }
    }
  }

  Future<void> _deleteRecord(ConversionRecord record, int index) async {
    try {
      await _historyService.deleteRecord(record.id);
      await _loadRecords();
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('O\'chirildi'),
            action: SnackBarAction(
              label: 'Bekor qilish',
              onPressed: () async {
                try {
                  await _historyService.insertRecord(record, index);
                  await _loadRecords();
                } catch (e) {
                  debugPrint('HistoryScreen: $e');
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('HistoryScreen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('O\'chirishda xatolik yuz berdi')),
        );
      }
      await _loadRecords();
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tarixni tozalash'),
        content: const Text('Barcha tarix o\'chirilsinmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _historyService.clearAll();
      await _loadRecords();
    }
  }

  void _onItemTap(ConversionRecord record) {
    Navigator.pop(context, record);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tarix'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Hammasini o\'chirish',
              onPressed: _records.isEmpty ? null : _clearAll,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tarix'),
              Tab(text: 'Sevimlilar'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildList(_records, emptyMessage: 'Tarix bo\'sh'),
                  _buildList(
                    _records.where((r) => r.isFavorite).toList(),
                    emptyMessage: 'Sevimlilar bo\'sh',
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List<ConversionRecord> records,
      {required String emptyMessage}) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordItem(record, index);
      },
    );
  }

  Widget _buildRecordItem(ConversionRecord record, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final directionLabel = record.isLatinToCyrillic ? 'Л→К' : 'К→Л';
    final dateStr =
        '${record.createdAt.day.toString().padLeft(2, '0')}.${record.createdAt.month.toString().padLeft(2, '0')} ${record.createdAt.hour.toString().padLeft(2, '0')}:${record.createdAt.minute.toString().padLeft(2, '0')}';

    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colorScheme.error,
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        await _deleteRecord(record, index);
        return true;
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onItemTap(record),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    directionLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.inputText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.outputText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        record.isFavorite ? Icons.star : Icons.star_border,
                        color: record.isFavorite
                            ? Colors.amber
                            : colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () => _toggleFavorite(record.id),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
