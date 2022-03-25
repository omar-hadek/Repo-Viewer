import 'package:flutter/material.dart';
import 'package:github_app/auth/application/auth_notifier.dart';
import 'package:github_app/auth/shared/auth_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'routes/app_router.gr.dart';

final initializationProvider = FutureProvider((ref) async {
  final authNotifier = ref.read(authNotifierProvider.notifier);
  await authNotifier.checkAndUpdateAuthStatus();
});

class AppWidget extends ConsumerWidget {
  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.maybeMap(
        orElse: () {},
        authenticated: (_) {
          appRouter.pushAndPopUntil(
            const StarredReposRoute(),
            predicate: (route) => false,
          );
        },
        unauthenticated: (_) {
          appRouter.pushAndPopUntil(
            const SignInRoute(),
            predicate: (route) => false,
          );
        },
      );
    });
    return MaterialApp.router(
      title: 'Github reppos',
      routerDelegate: appRouter.delegate(),
      routeInformationParser: appRouter.defaultRouteParser(),
    );
  }
}
