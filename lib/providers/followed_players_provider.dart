import 'package:flutter/foundation.dart';

import '../models/followed_player.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../services/follows_repository.dart';
import '../services/pandascore_service.dart';

class FollowedPlayerItem {
  final FollowedPlayer player;
  Match? nextMatch;
  bool loadingMatch;

  FollowedPlayerItem(this.player, {this.nextMatch, this.loadingMatch = false});
}

class FollowedPlayersProvider extends ChangeNotifier {
  final FollowsRepository _repo;
  final PandaScoreService _pandaScore;
  String? userId;

  List<FollowedPlayerItem> items = [];
  bool isLoading = false;
  String? error;

  FollowedPlayersProvider(this._repo, this._pandaScore);

  void updateUser(String? newUserId) {
    if (newUserId == userId) return;
    userId = newUserId;
    items = [];
    if (userId != null) {
      loadFollowed();
    } else {
      notifyListeners();
    }
  }

  bool isFollowing(int playerId) =>
      items.any((i) => i.player.playerId == playerId);

  Future<void> loadFollowed() async {
    if (userId == null) return;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final list = await _repo.list(userId!);
      items = list.map((p) => FollowedPlayerItem(p)).toList();
      notifyListeners();
      await Future.wait(items.map(_loadNextMatch));
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadNextMatch(FollowedPlayerItem item) async {
    if (item.player.teamId == null) return;
    item.loadingMatch = true;
    notifyListeners();
    try {
      final matches =
          await _pandaScore.getUpcomingMatchesForOpponent(item.player.teamId!);
      item.nextMatch = matches.isNotEmpty ? matches.first : null;
    } catch (_) {
      // Leave nextMatch null; the row still renders with an unavailable state.
    } finally {
      item.loadingMatch = false;
      notifyListeners();
    }
  }

  Future<void> follow(Player player) async {
    if (userId == null) return;
    final followed = FollowedPlayer(
      id: '',
      playerId: player.id,
      playerName: player.name,
      playerImageUrl: player.imageUrl,
      teamId: player.currentTeam?.id,
      teamName: player.currentTeam?.name,
    );
    await _repo.follow(followed, userId!);
    await loadFollowed();
  }

  Future<void> unfollow(int playerId) async {
    if (userId == null) return;
    await _repo.unfollow(userId!, playerId);
    items.removeWhere((i) => i.player.playerId == playerId);
    notifyListeners();
  }
}
