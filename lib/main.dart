import 'package:capstone_mobile_app/src/config/presentations/authentication_screen/authentication_bloc/authentication_bloc.dart';
import 'package:capstone_mobile_app/src/config/presentations/authentication_screen/authentication_bloc/authentication_state.dart';
import 'package:capstone_mobile_app/src/config/presentations/authentication_screen/sign_in_screen/sign_in_bloc/sign_in_bloc.dart';
import 'package:capstone_mobile_app/src/config/presentations/authentication_screen/sign_in_screen/sign_in_screen.dart';
import 'package:capstone_mobile_app/src/config/presentations/authentication_screen/sign_up_screen/sign_up_bloc/sign_up_bloc.dart';
import 'package:capstone_mobile_app/src/config/presentations/authentication_screen/sign_up_screen/sign_up_screen.dart';
import 'package:capstone_mobile_app/src/config/presentations/ble_screen/ble_screen.dart';
import 'package:capstone_mobile_app/src/config/presentations/ble_screen/bloc/ble_bloc.dart';
import 'package:capstone_mobile_app/src/config/presentations/home_screen/home_screen.dart';
import 'package:capstone_mobile_app/src/config/presentations/step_historical_screen/step_historical_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:user_repository/user_repository.dart';
import 'src/config/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_KEY'),
    appId: '1:799636338728:android:666d2068b61ff53db95d1d',
    messagingSenderId: '799636338728',
    projectId: 'health-care-app-ac9f4',
    storageBucket: 'health-care-app-ac9f4.firebasestorage.app',
  ));
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity
  );
  runApp(MyApp(FirebaseUserRepository()));
}

class MyApp extends StatelessWidget {
  final materialTheme = MaterialTheme(Typography.material2021().black);

  final UserRepository userRepository;

  MyApp(this.userRepository, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return RepositoryProvider(
      create: (context) => AuthenticationBloc(userRepository: userRepository),
      child: MultiBlocProvider(
        providers: [
          // BlocProvider(
          //   create: (context) => ThemeModeBloc(),
          // ),
          BlocProvider<SignInBloc>(
            create: (context) => SignInBloc(
                userRepository:
                    context.read<AuthenticationBloc>().userRepository),
          ),
          BlocProvider<BleBloc>(create: (context) => BleBloc()),
          BlocProvider<SignUpBloc>(
              create: (context) => SignUpBloc(userRepository: userRepository)),
          // BlocProvider<UpdateUserProfileBloc>(
          //   create: (context) => UpdateUserProfileBloc(
          //       userRepository:
          //           context.read<AuthenticationBloc>().userRepository),
          // ),
          // BlocProvider<MyUserBloc>(
          //     create: (context) => MyUserBloc(
          //         userRepository:
          //             context.read<AuthenticationBloc>().userRepository)
          //       ..add(GetUserData(
          //           userId:
          //               context.read<AuthenticationBloc>().state.user!.uid))),
        ],
        child: MaterialApp.router(
          title: 'Capstone Mobile App',
          theme: materialTheme.light(),
          routerConfig: _router,
        ),
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            return const HomeScreen(title: "Welcome Trung");
          } else {
            return const SignInScreen();
          }
        });
      },
    ),
    GoRoute(
      path: '/signup',
      builder: (BuildContext context, GoRouterState state) {
        return const SignUpScreen();
      },
    ),
    GoRoute(
      path: '/pedometer',
      builder: (BuildContext context, GoRouterState state) {
        return const StepHistoricalScreen();
      },
    ),
    GoRoute(
      path: '/ble',
      builder: (BuildContext context, GoRouterState state) {
        return const BleScreen();
      },
    ),
    GoRoute(
      path: '/select_device',
      builder: (BuildContext context, GoRouterState state) {
        return const SelectBluetoothDevice();
      },
    ),
  ],
);
