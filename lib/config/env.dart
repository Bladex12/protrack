import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => dotenv.get('SUPABASE_URL');
  static String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY');
  static String get pandaScoreApiKey => dotenv.get('PANDASCORE_API_KEY');
}
