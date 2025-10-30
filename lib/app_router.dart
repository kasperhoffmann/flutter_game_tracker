import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/edit_game_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) => const EditGameScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => EditGameScreen(id: state.pathParameters['id']),
            )
          ],
        )
      ],
    ),
  ],
);
