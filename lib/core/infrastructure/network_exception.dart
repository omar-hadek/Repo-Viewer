// ignore_for_file: public_member_api_docs, sort_constructors_first
class RestApiException implements Exception {
  final int errorCode;
  RestApiException({
    required this.errorCode,
  });
}
