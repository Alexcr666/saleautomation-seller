part of 'signup_bloc.dart';

@immutable
abstract class SignupEvent {}

class SignUpWithEmail extends SignupEvent {
  final Map map;

  SignUpWithEmail(this.map);
}
