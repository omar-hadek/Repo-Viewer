import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part '../../../core/infrastructure/github_headers.freezed.dart';
part '../../../core/infrastructure/github_headers.g.dart';

@freezed
class GithubHeaders with _$GithubHeaders {
  const GithubHeaders._();
  const factory GithubHeaders({
    String? etag,
    PaginationLink? link,
  }) = _GithubHeaders;

  factory GithubHeaders.parse(Response response) {
    final link = response.headers.map["link"]?[0];
    return GithubHeaders(
      etag: response.headers.map['Etag']?[0],
      link: link == null
          ? null
          : PaginationLink.parse(
              link.split(','),
              requestUrl: response.requestOptions.uri.toString(),
            ),
    );
  }

  factory GithubHeaders.fromJson(Map<String, dynamic> json) =>
      _$GithubHeadersFromJson(json);
}

@freezed
class PaginationLink with _$PaginationLink {
  const PaginationLink._();
  const factory PaginationLink({
    required int maxPage,
  }) = _PaginationLink;

  factory PaginationLink.parse(List<String> values,
      {required String requestUrl}) {
    return PaginationLink(
      maxPage: _extractPageNumber(
        values.firstWhere((e) => e.contains('rel="last"'),
            orElse: () => requestUrl),
      ),
    );
  }

  static int _extractPageNumber(String value) {
    final uriString = RegExp(
            r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)')
        .stringMatch(value);

    return int.parse(Uri.parse(uriString!).queryParameters['page']!);
  }

  factory PaginationLink.fromJson(Map<String, dynamic> json) =>
      _$PaginationLinkFromJson(json);
}
