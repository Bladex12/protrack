import 'package:flutter/material.dart';

import '../models/videogame.dart';

class GameFilterChips extends StatelessWidget {
  final List<Videogame> games;
  final Videogame? selected;
  final ValueChanged<Videogame?> onSelected;

  const GameFilterChips({
    super.key,
    required this.games,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          for (final game in games)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(game.name),
                selected: selected?.id == game.id,
                onSelected: (_) => onSelected(game),
              ),
            ),
        ],
      ),
    );
  }
}
