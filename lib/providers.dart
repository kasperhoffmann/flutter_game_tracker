import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'models/enums.dart';
import 'models/game.dart';
import 'data/game_dao.dart';

final gameDaoProvider = Provider<GameDao>((ref) => GameDao());

class GameFilters {
  final String search;
  final GameStatus? status;
  final String? platform;
  final String sort;
  const GameFilters({
    this.search = '',
    this.status,
    this.platform,
    this.sort = 'updatedAt DESC',
  });

  GameFilters copyWith({
    String? search,
    GameStatus? status,
    String? platform,
    String? sort,
  }) => GameFilters(
    search: search ?? this.search,
    status: status ?? this.status,
    platform: platform ?? this.platform,
    sort: sort ?? this.sort,
  );
}

final filtersProvider = StateProvider<GameFilters>((ref) => const GameFilters());

final gameListProvider = FutureProvider.autoDispose((ref) async {
  final dao = ref.watch(gameDaoProvider);
  final f = ref.watch(filtersProvider);
  return dao.list(
    search: f.search,
    statusFilter: f.status,
    platformFilter: f.platform,
    sort: f.sort,
  );
});

final editingGameProvider = StateProvider<Game?>((ref) => null);

final uuidProvider = Provider<Uuid>((ref) => const Uuid());
