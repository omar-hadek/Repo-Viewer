// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:github_app/core/infrastructure/sembase_database.dart';
import 'package:github_app/github/core/infrastructure/github_headers.dart';
import 'package:sembast/sembast.dart';

class GithubHeadersCache {
  final SembastDatabase _sembastDatabase;
  final _store = stringMapStoreFactory.store('headers');
  GithubHeadersCache(
    this._sembastDatabase,
  );
  Future<void> saveHeaers(Uri uri, GithubHeaders headers) async {
    await _store
        .record(uri.toString())
        .put(_sembastDatabase.instance, headers.toJson());
  }

  Future<GithubHeaders?> getHeaders(Uri uri) async {
    final json =
        await _store.record(uri.toString()).get(_sembastDatabase.instance);
    return json == null ? null : GithubHeaders.fromJson(json);
  }

  Future<void> deleteHeaders(Uri uri) async {
    await _store.record(uri.toString()).delete(_sembastDatabase.instance);
  }
}
