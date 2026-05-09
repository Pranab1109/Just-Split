import 'package:firebase_core/firebase_core.dart';
import 'package:just_split/firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_split/Services/AuthRepo.dart';
import 'package:just_split/Services/AvatarRepo.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import 'package:just_split/Services/PreferenceService.dart';
import 'package:just_split/bloc/Avatar/avatarbloc_bloc.dart';
import 'package:just_split/screens/LandingPage.dart';
import 'package:just_split/screens/LoginPage.dart';
import 'package:flutter/foundation.dart';
import 'package:just_split/utils/Cooloors.dart';
import 'firebase_options.dart';

import 'bloc/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!kIsWeb) {
    await GoogleSignIn.instance.initialize();
  }

  // Lock to portrait mode for consistent UI
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set system UI overlay style for immersive dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Cooloors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
            create: (context) => AuthRepository()),
        RepositoryProvider<FirebaseFirestoreRepo>(
            create: (context) => FirebaseFirestoreRepo()),
        RepositoryProvider<AvatarRepo>(create: (context) => AvatarRepo()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (BuildContext context) => AuthBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
              firebaseFirestoreRepo:
                  RepositoryProvider.of<FirebaseFirestoreRepo>(context),
            ),
          ),
          BlocProvider<AvatarBloc>(
            create: (BuildContext context) => AvatarBloc(
              RepositoryProvider.of<AvatarRepo>(context),
            ),
          )
        ],
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (_, currentThemeMode, __) {
            return FutureBuilder(
              initialData: false,
              future: PreferenceService().getAuthStatus(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: Cooloors.neoLightTheme,
                    darkTheme: Cooloors.neoDarkTheme,
                    themeMode: currentThemeMode,
                    home: LandingPage(
                      user: context.read<AuthRepository>().getUser()!,
                    ),
                  );
                }
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: Cooloors.neoLightTheme,
                  darkTheme: Cooloors.neoDarkTheme,
                  themeMode: currentThemeMode,
                  home: LoginPage(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
