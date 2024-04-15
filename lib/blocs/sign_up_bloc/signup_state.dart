part of 'signup_bloc.dart';

@immutable
abstract class SignupState {}

class SignupInitial extends SignupState {
  @override
  String toString() => 'SignupInitialState';
}

class SignUpWithEmailInProgressState extends SignupState {}

class SignUpWithEmailFailedState extends SignupState {}

class SignUpWithEmailCompletedState extends SignupState {
  final String res;

  SignUpWithEmailCompletedState(this.res);
}
