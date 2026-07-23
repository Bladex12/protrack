import 'package:flutter/foundation.dart';

import '../models/match.dart';
import '../models/videogame.dart';
import '../services/pandascore_service.dart';

class MatchesProvider extends ChangeNotifier {
  final PandaScoreService _service;

  MatchesProvider(this._service);

  List<Videogame> games = [];
  Videogame? selectedGame;
  List<Match> matches = [];
  bool isLoading = false;
  String? error;
  bool _gamesLoaded = false;

  Future<void> loadGames() async {
    if (_gamesLoaded) return;
    try {
      games = await _service.getVideogames();
      _gamesLoaded = true;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadMatches({Videogame? game}) async {
    selectedGame = game;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      matches = await _service.getUpcomingMatches(videogameSlug: game?.slug);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
