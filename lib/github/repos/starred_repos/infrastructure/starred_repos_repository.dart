import 'package:dartz/dartz.dart';
import 'package:github_app/core/infrastructure/network_exception.dart';
import 'package:github_app/github/core/domain/github_failure.dart';
import 'package:github_app/github/core/domain/github_repo.dart';
import 'package:github_app/github/core/infrastructure/github_repo_dto.dart';
import 'package:github_app/github/repos/starred_repos/infrastructure/starred_repos_local_service.dart';
import 'package:github_app/github/repos/starred_repos/infrastructure/starred_repos_remote_service.dart';

import '../../../../core/domain/fresh.dart';

class StarredReposRepository {
  final StarredReposRemoteService _remoteService;
  final StarredReposLocalService _localService;
  StarredReposRepository(this._remoteService, this._localService);

  Future<Either<GithubFailure, Fresh<List<GithubRepo>>>> getStarredReposPage(
      int page) async {
    try {
      final remotePageItems = await _remoteService.getStarredReposPage(page);
      return right(
        await remotePageItems.when(
            //todo: get intity from local service
            noConnection: (maxPage) async => Fresh.no(
                await _localService.getPage(maxPage).then((_) => _.toDomain()),
                isNextPagevailable: page < maxPage),
            notModified: (maxPage) async =>
                //todo: local service
                Fresh.no(
                    await _localService
                        .getPage(maxPage)
                        .then((_) => _.toDomain()),
                    isNextPagevailable: page < maxPage),
            withNewData: (data, maxPage) async {
              await _localService.upsertPage(data, page);
              return Fresh.yes(data.toDomain(),
                  isNextPagevailable: page < maxPage);
            }
            // todo: save data to local

            ),
      );
    } on RestApiException catch (e) {
      return left(GithubFailure.api(e.errorCode));
    }
  }
}

extension DTOListToDomainList on List<GithubRepoDTO> {
  List<GithubRepo> toDomain() {
    return map((e) => e.toDomain()).toList();
  }
}
