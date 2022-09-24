// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';
import 'package:github_app/core/infrastructure/network_exception.dart';
import 'package:github_app/core/infrastructure/remote_response.dart';
import 'package:github_app/github/core/infrastructure/github_headers.dart';
import 'package:github_app/github/core/infrastructure/github_repo_dto.dart';
import '../../../core/infrastructure/github_headers_cache.dart';
import '../../../../core/infrastructure/dio_extentions.dart';

class StarredReposRemoteService {
  final Dio _dio;
  final GithubHeadersCache _gihtubHeadersCache;
  StarredReposRemoteService(this._dio, this._gihtubHeadersCache);

  Future<RemoteResponse<List<GithubRepoDTO>>> getStarredReposPage(
      int page) async {
    const token = 'some token here';
    const accept = 'application/vnd.github.v3.html+json';
    final requestUri = Uri.https(
      'api.github.com',
      '/user/starred',
      {'page': '$page'},
    );
    final prevousHeaders = await _gihtubHeadersCache.getHeaders(requestUri);
    try {
      final response = await _dio.getUri(
        requestUri,
        options: Options(
          headers: {
            'Authorization': 'bearer $token',
            'Accept': accept,
            'If-None-Match': prevousHeaders?.etag ?? '',
          },
        ),
      );

      if (response.statusCode == 304) {
        return RemoteResponse.notModified(
            maxPage: prevousHeaders?.link?.maxPage ?? 0);
      } else if (response.statusCode == 200) {
        final headers = GithubHeaders.parse(response);
        final convertedData = (response.data as List<dynamic>)
            .map((e) => GithubRepoDTO.fromJson(e as Map<String, dynamic>))
            .toList();

        return RemoteResponse.withNewData(convertedData,
            maxPage: headers.link?.maxPage ?? 1);
      } else {
        throw RestApiException(errorCode: response.statusCode!);
      }
    } on DioError catch (e) {
      if (e.isNoConnectionError) {
        return RemoteResponse.noConnection(
            maxPage: prevousHeaders?.link?.maxPage ?? 0);
      }
      if (e.response != null) {
        throw RestApiException(errorCode: e.response!.statusCode!);
      } else {
        rethrow;
      }
    }
  }
}
