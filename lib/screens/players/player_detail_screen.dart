import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/match.dart';
import '../../models/player.dart';
import '../../providers/followed_players_provider.dart';
import '../../services/pandascore_service.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/match_card.dart';

class PlayerDetailScreen extends StatefulWidget {
  final Player player;

  const PlayerDetailScreen({super.key, required this.player});

  @override
  State<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
  Match? _nextMatch;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNextMatch();
  }

  Future<void> _loadNextMatch() async {
    final teamId = widget.player.currentTeam?.id;
    if (teamId == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final matches =
          await context.read<PandaScoreService>().getUpcomingMatchesForOpponent(teamId);
      setState(() => _nextMatch = matches.isNotEmpty ? matches.first : null);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final followedProvider = context.watch<FollowedPlayersProvider>();
    final following = followedProvider.isFollowing(player.id);

    return Scaffold(
      appBar: AppBar(title: Text(player.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundImage: player.imageUrl != null && player.imageUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(player.imageUrl!)
                  : null,
              child: player.imageUrl == null || player.imageUrl!.isEmpty
                  ? const Icon(Icons.person_outline, size: 48)
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(player.name, style: Theme.of(context).textTheme.headlineSmall),
          ),
          Center(
            child: Text(
              player.currentTeam?.name ?? 'No current team',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              icon: Icon(following ? Icons.star : Icons.star_outline),
              label: Text(following ? 'Unfollow' : 'Follow'),
              onPressed: () => following
                  ? context.read<FollowedPlayersProvider>().unfollow(player.id)
                  : context.read<FollowedPlayersProvider>().follow(player),
            ),
          ),
          const SizedBox(height: 24),
          Text('Next match', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildNextMatch(),
        ],
      ),
    );
  }

  Widget _buildNextMatch() {
    if (_loading) return const LoadingView();
    if (_error != null) return ErrorView(message: _error!, onRetry: _loadNextMatch);
    if (widget.player.currentTeam == null) {
      return const EmptyView(message: 'No team data available for this player.');
    }
    if (_nextMatch == null) {
      return const EmptyView(message: 'No upcoming match scheduled.');
    }
    return MatchCard(match: _nextMatch!);
  }
}
