import 'package:capstone_mobile_app/src/config/presentations/authentication_screen/sign_in_screen/sign_in_screen.dart';
import 'package:capstone_mobile_app/src/config/presentations/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'src/config/themes/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final materialTheme = MaterialTheme(Typography.material2021().black);
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Capstone Mobile App',
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SignInScreen();
      },
    ),
  ],
);
