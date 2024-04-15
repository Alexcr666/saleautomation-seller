import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:multivendor_seller/repositories/authentication_repository.dart';
import 'package:multivendor_seller/repositories/user_data_repository.dart';

import 'package:meta/meta.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthenticationRepository authenticationRepository;
  final UserDataRepository userDataRepository;

  SignupBloc({
    this.authenticationRepository,
    this.userDataRepository,
  }) : super(null);

  SignupState get initialState => SignupInitial();

  @override
  Stream<SignupState> mapEventToState(SignupEvent event) async* {
    print(event);

    if (event is SignUpWithEmail) {
      yield* mapSignUpWithEmailEventToState(
        map: event.map,
      );
    }
  }

  Stream<SignupState> mapSignUpWithEmailEventToState({Map map}) async* {
    yield SignUpWithEmailInProgressState();

    try {
      String result = await authenticationRepository.signUpWithEmail(map);
      if (result != null) {
        yield SignUpWithEmailCompletedState(result);
      } else {
        yield SignUpWithEmailFailedState();
      }
    } catch (e) {
      print('ERROR');
      print(e);
      yield SignUpWithEmailFailedState();
    }
  }
}
