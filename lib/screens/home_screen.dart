import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/enums.dart';
import '../providers.dart';
import '../widgets/game_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGames = ref.watch(gameListProvider);
    final filters = ref.watch(filtersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Tracker'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search title/platform...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => ref.read(filtersProvider.notifier).state =
                        filters.copyWith(search: v),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  onSelected: (v) => ref.read(filtersProvider.notifier).state =
                      filters.copyWith(sort: v),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'updatedAt DESC', child: Text('Recent')),
                    PopupMenuItem(value: 'title ASC', child: Text('Title A-Z')),
                    PopupMenuItem(value: 'rating DESC', child: Text('Rating high→low')),
                    PopupMenuItem(value: 'finishedAt DESC', child: Text('Finished (newest)')),
                  ],
                )
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: filters.status == null,
                  onSelected: (_) => ref.read(filtersProvider.notifier).state =
                      filters.copyWith(status: null),
                ),
                const SizedBox(width: 8),
                for (final s in GameStatus.values) ...[
                  FilterChip(
                    label: Text(s.label),
                    selected: filters.status == s,
                    onSelected: (_) => ref.read(filtersProvider.notifier).state =
                        filters.copyWith(status: s),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: asyncGames.when(
              data: (games) => ListView.builder(
                itemCount: games.length,
                itemBuilder: (context, i) => GameCard(
                  game: games[i],
                  onTap: () => context.push('/edit/${games[i].id}'),
                  onDelete: () => _confirmDelete(context, ref, games[i].id),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/edit'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete game?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(gameDaoProvider).delete(id);
      ref.invalidate(gameListProvider);
    }
  }
}
