import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/player.dart';
import '../../services/pandascore_service.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/player_list_tile.dart';
import 'player_detail_screen.dart';

class PlayerSearchScreen extends StatefulWidget {
  const PlayerSearchScreen({super.key});

  @override
  State<PlayerSearchScreen> createState() => _PlayerSearchScreenState();
}

class _PlayerSearchScreenState extends State<PlayerSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Player> _results = [];
  bool _loading = false;
  String? _error;
  bool _searched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
    });
    try {
      final results = await context.read<PandaScoreService>().searchPlayers(query);
      setState(() => _results = results);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            onChanged: _onChanged,
            decoration: const InputDecoration(
              labelText: 'Search pro players',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView();
    if (_error != null) return ErrorView(message: _error!, onRetry: () => _search(_controller.text));
    if (!_searched) return const EmptyView(message: 'Search for a pro player by name.', icon: Icons.person_search);
    if (_results.isEmpty) return const EmptyView(message: 'No players found.');
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final player = _results[index];
        return PlayerListTile(
          player: player,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PlayerDetailScreen(player: player)),
          ),
        );
      },
    );
  }
}
