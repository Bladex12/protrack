import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/match.dart';
import '../utils/date_formatter.dart';

class MatchCard extends StatelessWidget {
  final Match match;

  const MatchCard({super.key, required this.match});

  Widget _opponentAvatar(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const CircleAvatar(radius: 16, child: Icon(Icons.shield_outlined, size: 16));
    }
    return CircleAvatar(
      radius: 16,
      backgroundImage: CachedNetworkImageProvider(imageUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(match.videogameName, style: const TextStyle(fontSize: 12)),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Spacer(),
                Text(DateFormatter.matchTime(match.beginAt),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (match.opponents.isNotEmpty) _opponentAvatar(match.opponents[0].imageUrl),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    match.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (match.opponents.length > 1) _opponentAvatar(match.opponents[1].imageUrl),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
