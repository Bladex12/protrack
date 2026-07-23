import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/env.dart';
import 'providers/auth_provider.dart';
import 'providers/followed_players_provider.dart';
import 'providers/matches_provider.dart';
import 'services/auth_service.dart';
import 'services/follows_repository.dart';
import 'services/pandascore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );
  runApp(const ProTrackerApp());
}

class ProTrackerApp extends StatelessWidget {
  const ProTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => PandaScoreService()),
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(
          create: (ctx) => MatchesProvider(ctx.read<PandaScoreService>()),
        ),
        ChangeNotifierProxyProvider<AuthProvider, FollowedPlayersProvider>(
          create: (ctx) => FollowedPlayersProvider(
            FollowsRepository(),
            ctx.read<PandaScoreService>(),
          ),
          update: (ctx, auth, previous) =>
              previous!..updateUser(auth.currentUser?.id),
        ),
      ],
      child: MaterialApp(
        title: 'ProTracker',
        theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
        home: const AuthGate(),
      ),
    );
  }
}
