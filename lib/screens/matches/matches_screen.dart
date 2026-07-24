import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/matches_provider.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/game_filter_chips.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/match_card.dart';
import 'match_detail_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<MatchesProvider>();
      await provider.loadGames();
      await provider.loadMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchesProvider>();

    return Column(
      children: [
        const SizedBox(height: 8),
        GameFilterChips(
          games: provider.games,
          selected: provider.selectedGame,
          onSelected: (game) => context.read<MatchesProvider>().loadMatches(game: game),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context
                .read<MatchesProvider>()
                .loadMatches(game: provider.selectedGame),
            child: _buildBody(provider),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(MatchesProvider provider) {
    if (provider.isLoading && provider.matches.isEmpty) {
      return const LoadingView();
    }
    if (provider.error != null && provider.matches.isEmpty) {
      return ErrorView(
        message: provider.error!,
        onRetry: () => context.read<MatchesProvider>().loadMatches(game: provider.selectedGame),
      );
    }
    if (provider.matches.isEmpty) {
      return const EmptyView(message: 'No upcoming matches found.');
    }
    return ListView.builder(
      itemCount: provider.matches.length,
      itemBuilder: (context, index) {
        final match = provider.matches[index];
        return MatchCard(
          match: match,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MatchDetailScreen(match: match),
            ),
          ),
        );
      },
    );
  }
}
