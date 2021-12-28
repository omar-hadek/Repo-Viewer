import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:github_app/domain/auth_failure.dart';
import 'package:github_app/infrastructure/credentials_storage/credentials_storage.dart';
import 'package:oauth2/oauth2.dart';

class GithubAuthenticator {
  final CredentialsStorage _credentialsStorage;

  var queryParams;
  GithubAuthenticator(this._credentialsStorage);
  static const clientId = '39524830abe838732be';
  static const clientSecret = '328ef8be21f06225ef31618e93d63c06382f81c7';
  static const scopes = ['read:user', 'repo'];
  static final authorizationEndPoint =
      Uri.parse('https://github.com/login/oauth/authorize');
  static final tokenEndPoint =
      Uri.parse('https://github.com/login/oauth/access_token');
  static final redirectUrl = Uri.parse('http://localhost:3000/callback');
  Future<Credentials?> getSignedInCredentials() async {
    try {
      final storedCredentials = await _credentialsStorage.read();
      if (storedCredentials != null) {
        if (storedCredentials.canRefresh && storedCredentials.isExpired) {
          // TODO: refresh
        }
      }
      return storedCredentials;
    } on PlatformException {
      return null;
    }
  }

  Future<void> signIn() =>
      getSignedInCredentials().then((credentials) => credentials != null);
  AuthorizationCodeGrant createGrant() {
    return AuthorizationCodeGrant(
      clientId,
      authorizationEndPoint,
      tokenEndPoint,
      secret: clientSecret,
    );
  }

  Uri getAuthorizationUrl(AuthorizationCodeGrant grant) {
    return grant.getAuthorizationUrl(redirectUrl, scopes: scopes);
  }

  Future<Either<AuthFailure,Unit>> handleAuthorizationUrl(
    AuthorizationCodeGrant grant,
    Map<String,String> queryParams,
  ) async{
    try{
      final httpClient = await grant.handleAuthorizationResponse(queryParams);
    await _credentialsStorage.save(httpClient.credentials);
    return right(unit);
    } on FormatException{
      return left(const AuthFailure.server());
    }on AuthorizationException catch (e) {

      return left(AuthFailure.server('${e.error} : ${e.description}'));
    }on PlatformException{
      return left(const AuthFailure.storage());
    }
  }
}
