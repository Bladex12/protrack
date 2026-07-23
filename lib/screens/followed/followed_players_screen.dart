import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/player.dart';
import '../../providers/followed_players_provider.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/match_card.dart';
import '../../widgets/player_list_tile.dart';
import '../players/player_detail_screen.dart';

class FollowedPlayersScreen extends StatelessWidget {
  const FollowedPlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FollowedPlayersProvider>();

    if (provider.isLoading && provider.items.isEmpty) {
      return const LoadingView();
    }
    if (provider.error != null && provider.items.isEmpty) {
      return ErrorView(
        message: provider.error!,
        onRetry: () => context.read<FollowedPlayersProvider>().loadFollowed(),
      );
    }
    if (provider.items.isEmpty) {
      return const EmptyView(message: 'You are not following any players yet.');
    }

    return RefreshIndicator(
      onRefresh: () => context.read<FollowedPlayersProvider>().loadFollowed(),
      child: ListView.builder(
        itemCount: provider.items.length,
        itemBuilder: (context, index) {
          final item = provider.items[index];
          final player = Player(
            id: item.player.playerId,
            name: item.player.playerName,
            imageUrl: item.player.playerImageUrl,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlayerListTile(
                player: player,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PlayerDetailScreen(player: player)),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.star, color: Colors.amber),
                  onPressed: () =>
                      context.read<FollowedPlayersProvider>().unfollow(item.player.playerId),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: item.loadingMatch
                    ? const LoadingView()
                    : item.nextMatch != null
                        ? MatchCard(match: item.nextMatch!)
                        : const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('No upcoming match scheduled.'),
                          ),
              ),
              const Divider(height: 1),
            ],
          );
        },
      ),
    );
  }
}
