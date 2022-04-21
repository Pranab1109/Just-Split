part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested(this.email, this.password);
}

// When the user signing up with email and password this event is called and the [AuthRepository] is called to sign up the user
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final int avatar;
  final String username;

  SignUpRequested(this.email, this.password, this.avatar, this.username);
}

// When the user signing in with google this event is called and the [AuthRepository] is called to sign in the user
class GoogleSignUpRequested extends AuthEvent {
  final int avatar;

  GoogleSignUpRequested(this.avatar);
}

// When the user signing out this event is called and the [AuthRepository] is called to sign out the user
class SignOutRequested extends AuthEvent {}

class GoogleSignInRequested extends AuthEvent {}
