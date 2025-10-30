import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/enums.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const GameCard({super.key, required this.game, this.onTap, this.onDelete});

  Color _statusColor(GameStatus s, BuildContext context) {
    switch (s) {
      case GameStatus.planned: return Colors.blueGrey;
      case GameStatus.playing: return Theme.of(context).colorScheme.primary;
      case GameStatus.finished: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Text(game.title.isNotEmpty ? game.title[0].toUpperCase() : '?')),
        title: Text(game.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${game.platform} • ${game.status.label}'
            '${game.rating != null ? ' • ${game.rating}/10' : ''}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
