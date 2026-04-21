import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/dictionary_entry.dart';
import '../services/dictionary_service.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final _service = DictionaryService.instance;
  List<DictionaryEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service.addListener(_reload);
    _load();
  }

  @override
  void dispose() {
    _service.removeListener(_reload);
    super.dispose();
  }

  void _reload() => _load();

  Future<void> _load() async {
    final entries = await _service.getAll();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _showAddDialog() async {
    final latinController = TextEditingController();
    final cyrillicController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Yangi so\'z qo\'shish'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: latinController,
              decoration: const InputDecoration(
                labelText: 'Lotincha',
                hintText: 'Masalan: iPhone',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cyrillicController,
              decoration: const InputDecoration(
                labelText: 'Kirillcha',
                hintText: 'Masalan: iPhone',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.orange),
            child: const Text('Qo\'shish'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final latin = latinController.text.trim();
      final cyrillic = cyrillicController.text.trim();
      if (latin.isNotEmpty && cyrillic.isNotEmpty) {
        await _service.add(latin, cyrillic);
      }
    }
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Barcha yozuvlarni o\'chirish'),
        content: const Text('Bu amalni bekor qilib bo\'lmaydi. Davom etasizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lug\'at'),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Hammasini o\'chirish',
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  itemCount: _entries.length,
                  itemBuilder: (context, i) {
                    final entry = _entries[i];
                    return Dismissible(
                      key: ValueKey(entry.id),
                      background: Container(
                        color: Theme.of(context).colorScheme.error,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.delete_rounded,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        if (entry.id != null) _service.delete(entry.id!);
                      },
                      child: ListTile(
                        title: Text(entry.latin),
                        subtitle: Text(entry.cyrillic),
                        leading: const Icon(
                          Icons.book_outlined,
                          color: AppColors.purple,
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.orange,
        child: const Icon(Icons.add_rounded, color: Colors.white),
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_rounded,
                size: 64, color: colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'Lug\'at bo\'sh',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Maxsus so\'zlar qo\'shing — masalan, ismlar yoki brend nomlari. '
              'Bu so\'zlar oddiy konvertatsiya qoidalaridan tashqari ishlatiladi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
