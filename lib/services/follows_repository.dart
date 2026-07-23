import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/followed_player.dart';

class FollowsRepository {
  final SupabaseClient _client = Supabase.instance.client;
  static const _table = 'followed_players';

  Future<List<FollowedPlayer>> list(String userId) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at');
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(FollowedPlayer.fromMap)
        .toList();
  }

  Future<void> follow(FollowedPlayer player, String userId) =>
      _client.from(_table).insert(player.toInsertMap(userId));

  Future<void> unfollow(String userId, int playerId) => _client
      .from(_table)
      .delete()
      .eq('user_id', userId)
      .eq('player_id', playerId);
}
