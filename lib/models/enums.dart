enum GameStatus { planned, playing, finished }

extension GameStatusX on GameStatus {
  String get label {
    switch (this) {
      case GameStatus.planned:
        return 'Planned';
      case GameStatus.playing:
        return 'Playing';
      case GameStatus.finished:
        return 'Finished';
    }
  }

  static GameStatus fromString(String s) {
    switch (s.toLowerCase()) {
      case 'planned':
        return GameStatus.planned;
      case 'playing':
        return GameStatus.playing;
      case 'finished':
        return GameStatus.finished;
      default:
        return GameStatus.planned;
    }
  }
}
