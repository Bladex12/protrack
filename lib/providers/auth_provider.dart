import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<AuthState>? _sub;

  User? currentUser;
  bool isLoading = false;
  String? errorMessage;

  AuthProvider(this._authService) {
    currentUser = _authService.currentUser;
    _sub = _authService.authStateChanges.listen((state) {
      currentUser = state.session?.user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) =>
      _run(() => _authService.signIn(email, password));

  Future<void> signUp(String email, String password) =>
      _run(() => _authService.signUp(email, password));

  Future<void> signOut() => _run(() => _authService.signOut());

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
