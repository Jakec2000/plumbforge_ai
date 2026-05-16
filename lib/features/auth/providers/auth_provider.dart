import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/app_user.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AppUser?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  AuthNotifier() : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    
    // Simulate network delay for Firebase Auth
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'admin@plumbforge.ai') {
      state = AsyncValue.data(const AppUser(
        id: 'user_1',
        email: 'admin@plumbforge.ai',
        displayName: 'Master Plumber',
        role: UserRole.admin,
      ));
    } else if (email == 'apprentice@plumbforge.ai') {
      state = AsyncValue.data(const AppUser(
        id: 'user_2',
        email: 'apprentice@plumbforge.ai',
        displayName: 'Apprentice Bob',
        role: UserRole.apprentice,
      ));
    } else {
      state = AsyncValue.error('Invalid email or password', StackTrace.current);
      state = const AsyncValue.data(null); // Reset after error
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 500));
    state = const AsyncValue.data(null);
  }
}
