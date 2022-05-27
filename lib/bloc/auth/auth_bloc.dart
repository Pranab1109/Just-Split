import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_split/Services/AuthRepo.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final FirebaseFirestoreRepo firebaseFirestoreRepo;
  AuthBloc({required this.authRepository, required this.firebaseFirestoreRepo})
      : super(UnAuthenticated()) {
    on<SignInRequested>((event, emit) async {
      emit(Loading());
      try {
        User? user = await authRepository.signIn(
            email: event.email, password: event.password);
        if (user != null) {
          emit(Authenticated(user: user));
        } else {
          emit(AuthError("Something went wrong."));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(UnAuthenticated());
      }
    });
    on<SignUpRequested>((event, emit) async {
      emit(Loading());
      try {
        User? user = await authRepository.signUp(
            email: event.email, password: event.password);
        if (user != null) {
          firebaseFirestoreRepo.addUser(event.username, event.avatar, user);
          emit(Authenticated(user: user));
        } else {
          emit(AuthError("Something went wrong."));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(UnAuthenticated());
      }
    });

    on<GoogleSignUpRequested>((event, emit) async {
      emit(Loading());
      try {
        User? user = await authRepository.signUpWithGoogle();
        if (user != null) {
          await firebaseFirestoreRepo.addUser(
              user.displayName!, event.avatar, user);
          emit(Authenticated(user: user));
        } else {
          emit(AuthError("Something went wrong."));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(UnAuthenticated());
      }
    });

    on<SignOutRequested>((event, emit) async {
      emit(Loading());
      await authRepository.signOut();
      emit(UnAuthenticated());
    });
  }
}
