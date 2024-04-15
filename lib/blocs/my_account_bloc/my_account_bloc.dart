import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:multivendor_seller/models/admin.dart';
import 'package:multivendor_seller/models/seller.dart';

import 'package:multivendor_seller/repositories/user_data_repository.dart';
import 'package:meta/meta.dart';

part 'my_account_event.dart';
part 'my_account_state.dart';

class MyAccountBloc extends Bloc<MyAccountEvent, MyAccountState> {
  final UserDataRepository userDataRepository;

  MyAccountBloc({@required this.userDataRepository}) : super(null);

  MyAccountState get initialState => MyAccountInitial();

  @override
  Stream<MyAccountState> mapEventToState(
    MyAccountEvent event,
  ) async* {
    if (event is GetMyAccountDetailsEvent) {
      yield* mapGetMyAccountDetailsEventToState();
    }
    if (event is UpdateAdminDetailsEvent) {
      yield* mapUpdateAdminDetailsEventToState(event.adminMap);
    }
    if (event is ChangePasswordEvent) {
      yield* mapChangePasswordEventToState(event.map);
    }
  }

  Stream<MyAccountState> mapGetMyAccountDetailsEventToState() async* {
    yield GetMyAccountDetailsInProgressState();
    try {
      Seller seller = await userDataRepository.getMyAccountDetails();
      if (seller != null) {
        yield GetMyAccountDetailsCompletedState(seller);
      } else {
        yield GetMyAccountDetailsFailedState();
      }
    } catch (e) {
      print(e);
      yield GetMyAccountDetailsFailedState();
    }
  }

  Stream<MyAccountState> mapUpdateAdminDetailsEventToState(
      Map adminMap) async* {
    yield UpdateAdminDetailsInProgressState();
    try {
      bool isUpdated = await userDataRepository.updateAdminDetails(adminMap);
      if (isUpdated) {
        yield UpdateAdminDetailsCompletedState();
      } else {
        yield UpdateAdminDetailsFailedState();
      }
    } catch (e) {
      print(e);
      yield UpdateAdminDetailsFailedState();
    }
  }

  Stream<MyAccountState> mapChangePasswordEventToState(Map adminMap) async* {
    yield ChangePasswordInProgressState();
    try {
      String res = await userDataRepository.changePassword(adminMap);
      if (res != null) {
        yield ChangePasswordCompletedState(res);
      } else {
        yield ChangePasswordFailedState();
      }
    } catch (e) {
      print(e);
      yield ChangePasswordFailedState();
    }
  }
}
