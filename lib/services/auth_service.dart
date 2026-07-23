import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final GoTrueClient _auth = Supabase.instance.client.auth;

  User? get currentUser => _auth.currentUser;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  Future<void> signUp(String email, String password) async {
    final res = await _auth.signUp(email: email, password: password);
    if (res.user == null) {
      throw Exception('Sign up failed');
    }
  }

  Future<void> signIn(String email, String password) async {
    final res = await _auth.signInWithPassword(email: email, password: password);
    if (res.user == null) {
      throw Exception('Sign in failed');
    }
  }

  Future<void> signOut() => _auth.signOut();
}
