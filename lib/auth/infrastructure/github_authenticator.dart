import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:github_app/core/shared/encoders.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart';

import '../domain/auth_failure.dart';
import 'credentials_storage/credentials_storage.dart';

class GithubOAuthHttpClient extends http.BaseClient {
  final httpClient = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['accept'] = 'application/json';
    return httpClient.send(request);
  }
}

class GithubAuthenticator {
  final CredentialsStorage _credentialsStorage;
  final Dio _dio;
  var queryParams;
  GithubAuthenticator(this._credentialsStorage, this._dio);
  static const clientId = '39524830abe838732be';
  static const clientSecret = '328ef8be21f06225ef31618e93d63c06382f81c7';
  static const scopes = ['read:user', 'repo'];
  static final authorizationEndPoint =
      Uri.parse('https://github.com/login/oauth/authorize');
  static final tokenEndPoint =
      Uri.parse('https://github.com/login/oauth/access_token');
  static final revocationEndPoint =
      Uri.parse('https://api.github.com/applcations/$clientId/token');
  static final redirectUrl = Uri.parse('http://localhost:3000/callback');

  // get signed in user's and refresh credentials

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

  //whether the user signed in or not
  Future<bool> isSignedIn() =>
      getSignedInCredentials().then((credentials) => credentials != null);

  // create authorization code grant
  AuthorizationCodeGrant createGrant() {
    return AuthorizationCodeGrant(
      clientId,
      authorizationEndPoint,
      tokenEndPoint,
      secret: clientSecret,
      httpClient: GithubOAuthHttpClient(),
    );
  }

  // passing the parameters to the authorization url and
  //generate the authorization url for us
  Uri getAuthorizationUrl(AuthorizationCodeGrant grant) {
    return grant.getAuthorizationUrl(redirectUrl, scopes: scopes);
  }

  // handle the granted response
  Future<Either<AuthFailure, Unit>> handleAuthorizationUrl(
    AuthorizationCodeGrant grant,
    Map<String, String> queryParams,
  ) async {
    try {
      final httpClient = await grant.handleAuthorizationResponse(queryParams);
      await _credentialsStorage.save(httpClient.credentials);
      return right(unit);
    } on FormatException {
      return left(const AuthFailure.server());
    } on AuthorizationException catch (e) {
      return left(AuthFailure.server('${e.error} : ${e.description}'));
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }

  // sign out
  Future<Either<AuthFailure, Unit>> signOut() async {
    try {
      final acessToken = await _credentialsStorage
          .read()
          .then((credentials) => credentials?.accessToken);
      final usernameAndPassword =
          stringToBase64.encode('$clientId:$clientSecret');
      _dio.deleteUri(
        revocationEndPoint,
        data: {
          'acess_token': acessToken,
        },
        options: Options(
          headers: {
            'Authorization': 'basic $usernameAndPassword',
          },
        ),
      );

      return clearCredentialsStorage();
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }

  Future<Either<AuthFailure, Unit>> clearCredentialsStorage() async {
    try {
      await _credentialsStorage.clear();
      return right(unit);
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }

  // refresh credentials method

  Future<Either<AuthFailure, Credentials>> refresh(
      Credentials credentials) async {
    try {
      final refreshedCredentiels = await credentials.refresh(
        identifier: clientId,
        secret: clientSecret,
        httpClient: GithubOAuthHttpClient(),
      );

      await _credentialsStorage.save(refreshedCredentiels);
      right(refreshedCredentiels);
    } on FormatException {
      return left(const AuthFailure.server());
    } on AuthorizationException catch (e) {
      return left(AuthFailure.server('${e.error} : ${e.description}'));
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
    return left(const AuthFailure.server());
  }
}
