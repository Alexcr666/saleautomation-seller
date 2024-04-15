import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:multivendor_seller/models/seller.dart';

import 'package:multivendor_seller/repositories/user_data_repository.dart';

import 'package:meta/meta.dart';

part 'zipcode_restriction_event.dart';
part 'zipcode_restriction_state.dart';

class ZipcodeRestrictionBloc
    extends Bloc<ZipcodeRestrictionEvent, ZipcodeRestrictionState> {
  final UserDataRepository userDataRepository;

  ZipcodeRestrictionBloc({this.userDataRepository})
      : super(ZipcodeRestrictionInitial());

  @override
  Stream<ZipcodeRestrictionState> mapEventToState(
    ZipcodeRestrictionEvent event,
  ) async* {
    if (event is GetAllZipcodes) {
      yield* mapGetAllZipcodesToState();
    }
    if (event is UpdateZipcodes) {
      yield* mapUpdateZipcodesToState(event.map);
    }
  }

  Stream<ZipcodeRestrictionState> mapGetAllZipcodesToState() async* {
    yield GetAllZipcodesInProgressState();
    try {
      Zipcode zipcode = await userDataRepository.getAllZipcodes();
      if (zipcode != null) {
        yield GetAllZipcodesCompletedState(zipcode);
      } else {
        yield GetAllZipcodesFailedState();
      }
    } catch (e) {
      print(e);
      yield GetAllZipcodesFailedState();
    }
  }

  Stream<ZipcodeRestrictionState> mapUpdateZipcodesToState(Map map) async* {
    yield UpdateZipcodesInProgressState();
    try {
      bool isUpdated = await userDataRepository.updateZipcodes(map);
      if (isUpdated) {
        yield UpdateZipcodesCompletedState();
      } else {
        yield UpdateZipcodesFailedState();
      }
    } catch (e) {
      print(e);
      yield UpdateZipcodesFailedState();
    }
  }
}
