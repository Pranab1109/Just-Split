import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_split/Services/AuthRepo.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import 'package:just_split/Services/PreferenceService.dart';
import 'package:just_split/screens/LandingPage.dart';
import 'package:just_split/screens/LoginPage.dart';

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
    return MultiRepositoryProvider(
        // create: (context) => AuthRepository(),
        providers: [
          RepositoryProvider<AuthRepository>(
              create: (context) => AuthRepository()),
          RepositoryProvider<FirebaseFirestoreRepo>(
              create: (context) => FirebaseFirestoreRepo()),
        ],
        child: BlocProvider(
            create: (context) => AuthBloc(
                  authRepository:
                      RepositoryProvider.of<AuthRepository>(context),
                  firebaseFirestoreRepo:
                      RepositoryProvider.of<FirebaseFirestoreRepo>(context),
                ),
            child: FutureBuilder(
              initialData: false,
              future: PreferenceService().getAuthStatus(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data == true) {
                    return MaterialApp(
                      theme: ThemeData(
                        textTheme: GoogleFonts.aBeeZeeTextTheme(
                          Theme.of(context).textTheme,
                        ),
                      ),
                      home: LandingPage(
                        user: AuthRepository().getUser(),
                      ),
                    );
                  }
                }
                return MaterialApp(
                  theme: ThemeData(
                    textTheme: GoogleFonts.aBeeZeeTextTheme(
                      Theme.of(context).textTheme,
                    ),
                  ),
                  home: LoginPage(),
                );
              },
            )));
  }
}


/*

*/