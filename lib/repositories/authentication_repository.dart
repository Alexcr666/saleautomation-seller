import 'package:multivendor_seller/providers/authentication_provider.dart';
import 'package:multivendor_seller/providers/base_provider.dart';
import 'package:multivendor_seller/repositories/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationRepository extends BaseRepository {
  BaseAuthenticationProvider authenticationProvider = AuthenticationProvider();

  @override
  void dispose() {
    authenticationProvider.dispose();
  }

  Future<bool> signOutUser() => authenticationProvider.signOutUser();

  Future<bool> checkIfSignedIn() => authenticationProvider.checkIfSignedIn();

  Future<User> getCurrentUser() => authenticationProvider.getCurrentUser();

  Future<String> signInWithEmail(String email, String password) =>
      authenticationProvider.signInWithEmail(email, password);

  Future<String> signUpWithEmail(Map map) =>
      authenticationProvider.signUpWithEmail(map);
}
