import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:github_app/infrastructure/github_authenticator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
part 'auth_notifier.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.unauthenticated() = _UnAuthenticated;
  const factory AuthState.authenticated() = _Authenticated;
  const factory AuthState.failure() = _Failure;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final GithubAuthenticator _authenticator;
  AuthNotifier(this._authenticator) : super(const AuthState.initial());

  Future<void> checkAndUpdateAuthStatus() async {
    state = (await _authenticator.isSignedIn())
        ? const AuthState.authenticated()
        : const AuthState.unauthenticated();
  }
}
