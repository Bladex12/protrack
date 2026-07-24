import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/match.dart';
import '../../models/player.dart';
import '../../providers/followed_players_provider.dart';
import '../../services/pandascore_service.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/player_list_tile.dart';
import '../players/player_detail_screen.dart';

class MatchDetailScreen extends StatefulWidget {
  final Match match;
  const MatchDetailScreen({super.key, required this.match});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  bool _loading = true;
  String? _error;
  
  final Map<int, List<Player>> _teamPlayers = {};

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = context.read<PandaScoreService>();
      
      await Future.wait(widget.match.opponents.map((opponent) async {
        final players = await service.getPlayersByTeam(opponent.id);
        _teamPlayers[opponent.id] = players;
      }));
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.match.title)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView();
    if (_error != null) return ErrorView(message: _error!, onRetry: _loadPlayers);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: widget.match.opponents.expand((opponent) {
        final players = _teamPlayers[opponent.id] ?? [];
        
        return [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              opponent.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (players.isEmpty)
             const Padding(
               padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
               child: Text('No hay jugadores registrados para este equipo.'),
             ),
          
          ...players.map((player) {
            final provider = context.watch<FollowedPlayersProvider>();
            final isFollowing = provider.isFollowing(player.id);

            return PlayerListTile(
              player: player,
              trailing: IconButton(
                icon: Icon(
                  isFollowing ? Icons.star : Icons.star_outline,
                  color: isFollowing ? Colors.amber : null,
                ),
                onPressed: () => isFollowing
                    ? provider.unfollow(player.id)
                    : provider.follow(player),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PlayerDetailScreen(player: player)),
              ),
            );
          }),
          const Divider(),
        ];
      }).toList(),
    );
  }
}