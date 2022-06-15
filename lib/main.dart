import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_split/Services/AuthRepo.dart';
import 'package:just_split/Services/AvatarRepo.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import 'package:just_split/Services/PreferenceService.dart';
import 'package:just_split/bloc/Avatar/avatarbloc_bloc.dart';
import 'package:just_split/screens/LandingPage.dart';
import 'package:just_split/screens/LoginPage.dart';
import 'package:just_split/utils/Cooloors.dart';

import 'bloc/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Cooloors cooloors = Cooloors();
    var themeData = ThemeData(
      textTheme: GoogleFonts.libreBaskervilleTextTheme(
        Theme.of(context).textTheme,
      ),
      scaffoldBackgroundColor: cooloors.darkBackgroundColor,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(cooloors.buttonColor),
          foregroundColor: MaterialStateProperty.all(cooloors.lightTextColor),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cooloors.darkBackgroundColor,
        elevation: 0.0,
      ),
      colorScheme:
          ColorScheme.fromSwatch().copyWith(secondary: cooloors.buttonColor),
    );
    return MultiRepositoryProvider(
      // create: (context) => AuthRepository(),
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
        child: FutureBuilder(
          initialData: false,
          future: PreferenceService().getAuthStatus(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data == true) {
              return MaterialApp(
                theme: themeData,
                home: LandingPage(
                  user: context.read<AuthRepository>().getUser()!,
                ),
              );
            }
            return MaterialApp(
              theme: themeData,
              home: LoginPage(),
            );
          },
        ),
      ),
    );
  }
}
