import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/player.dart';

class PlayerListTile extends StatelessWidget {
  final Player player;
  final VoidCallback? onTap;
  final Widget? trailing;

  const PlayerListTile({super.key, required this.player, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: player.imageUrl != null && player.imageUrl!.isNotEmpty
          ? CircleAvatar(backgroundImage: CachedNetworkImageProvider(player.imageUrl!))
          : const CircleAvatar(child: Icon(Icons.person_outline)),
      title: Text(player.name),
      subtitle: Text(player.currentTeam?.name ?? 'No current team'),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
