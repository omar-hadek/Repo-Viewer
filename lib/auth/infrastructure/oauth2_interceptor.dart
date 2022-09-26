import 'package:dio/dio.dart';
import 'package:github_app/auth/application/auth_notifier.dart';
import 'package:github_app/auth/infrastructure/github_authenticator.dart';

class OAuthInterceptor extends Interceptor {
  final GithubAuthenticator _authenticator;
  final AuthNotifier _authNotifier;
  final Dio _dio;

  OAuthInterceptor(this._authenticator, this._authNotifier, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final credentials = await _authenticator.getSignedInCredentials();
    final modifiedOptions = options
      ..headers.addAll(credentials == null
          ? {}
          : {'Authorization': 'bearer ${credentials.accessToken}'});
    handler.next(modifiedOptions);
  }

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    final errorResponse = err.response;

    if (errorResponse != null && errorResponse.statusCode == 401) {
      final credentials = await _authenticator.getSignedInCredentials();
      credentials != null && credentials.canRefresh
          ? await _authenticator.refresh(credentials)
          : await _authenticator.clearCredentialsStorage();

      await _authNotifier.checkAndUpdateAuthStatus();

      final refreshedCredentials =
          await _authenticator.getSignedInCredentials();

      if (refreshedCredentials != null) {
        handler.resolve(
          await _dio.fetch(
            errorResponse.requestOptions
              ..headers['Authorization'] =
                  'bearer ${refreshedCredentials.accessToken}',
          ),
        );
      } else {
        handler.next(err);
      }
    }
  }
}
