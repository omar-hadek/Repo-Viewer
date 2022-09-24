import 'package:auto_route/annotations.dart';
import 'package:github_app/auth/presentation/sign_in_page.dart';
import 'package:github_app/splash/presentation/splash_page.dart';

import '../../../github/repos/starred_repos/presentation/starred_repos_page.dart';

@MaterialAutoRouter(
  routes: [
    MaterialRoute(page: SplashPage, initial: true),
    MaterialRoute(
      page: SignInPage,
      path: '/sign-in',
    ),
    MaterialRoute(
      page: StarredReposPage,
      path: '/repos',
    ),
  ],
  replaceInRouteName: 'Page,Route',
)
class $AppRouter {}
