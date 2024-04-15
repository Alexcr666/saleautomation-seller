import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:multivendor_seller/models/global_settings.dart';
import 'package:multivendor_seller/models/payout.dart';
import 'package:multivendor_seller/repositories/user_data_repository.dart';

import 'package:meta/meta.dart';

part 'payout_event.dart';
part 'payout_state.dart';

class PayoutBloc extends Bloc<PayoutEvent, PayoutState> {
  final UserDataRepository userDataRepository;
  StreamSubscription payoutsSubscription;

  PayoutBloc({this.userDataRepository}) : super(PayoutInitial());
  @override
  Future<void> close() {
    print('Closing Payout BLOC');
    payoutsSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<PayoutState> mapEventToState(
    PayoutEvent event,
  ) async* {
    if (event is RequestPayout) {
      yield* mapRequestPayoutToState(event.map);
    }
    if (event is ModifyRequestPayout) {
      yield* mapModifyRequestPayoutToState(event.map);
    }
    if (event is CancelPayout) {
      yield* mapCancelPayoutToState(event.map);
    }
    if (event is GetCartInfo) {
      yield* mapGetCartInfoToState();
    }
    if (event is GetPayoutAnalytics) {
      yield* mapGetPayoutAnalyticsToState();
    }
    if (event is UpdateGetPayoutAnalytics) {
      yield* mapUpdateGetPayoutAnalyticsToState(event.payout);
    }
  }

  Stream<PayoutState> mapGetCartInfoToState() async* {
    yield GetCartInfoInProgressState();
    try {
      GlobalSettings globalSettings = await userDataRepository.getCartInfo();
      if (globalSettings != null) {
        yield GetCartInfoCompletedState(globalSettings);
      } else {
        yield GetCartInfoFailedState();
      }
    } catch (e) {
      print(e);
      yield GetCartInfoFailedState();
    }
  }

  Stream<PayoutState> mapRequestPayoutToState(Map<String, dynamic> map) async* {
    yield RequestPayoutInProgressState();
    try {
      bool isDone = await userDataRepository.requestPayout(map);
      if (isDone) {
        yield RequestPayoutCompletedState();
      } else {
        yield RequestPayoutFailedState();
      }
    } catch (e) {
      print(e);
      yield RequestPayoutFailedState();
    }
  }

  Stream<PayoutState> mapModifyRequestPayoutToState(
      Map<String, dynamic> map) async* {
    yield ModifyRequestPayoutInProgressState();
    try {
      bool isDone = await userDataRepository.modifyRequestPayout(map);
      if (isDone) {
        yield ModifyRequestPayoutCompletedState();
      } else {
        yield ModifyRequestPayoutFailedState();
      }
    } catch (e) {
      print(e);
      yield ModifyRequestPayoutFailedState();
    }
  }

  Stream<PayoutState> mapCancelPayoutToState(Map<String, dynamic> map) async* {
    yield CancelPayoutInProgressState();
    try {
      bool isDone = await userDataRepository.cancelPayout(map);
      if (isDone) {
        yield CancelPayoutCompletedState();
      } else {
        yield CancelPayoutFailedState();
      }
    } catch (e) {
      print(e);
      yield CancelPayoutFailedState();
    }
  }

  Stream<PayoutState> mapGetPayoutAnalyticsToState() async* {
    yield GetPayoutAnalyticsInProgressState();

    try {
      payoutsSubscription?.cancel();
      payoutsSubscription =
          userDataRepository.getPayoutAnalytics().listen((newPayout) {
        add(UpdateGetPayoutAnalytics(newPayout));
      }, onError: (err) {
        print(err);
        return GetPayoutAnalyticsFailedState();
      });
    } catch (e) {
      print(e);
      yield GetPayoutAnalyticsFailedState();
    }
  }

  Stream<PayoutState> mapUpdateGetPayoutAnalyticsToState(
      Payout newPayout) async* {
    yield GetPayoutAnalyticsCompletedState(newPayout);
  }

  // Stream<PayoutState> mapGetPayoutAnalyticsToState() async* {
  //   yield GetPayoutAnalyticsInProgressState();
  //   try {
  //     Payout payout = await userDataRepository.getAllPayouts();
  //     if (payout != null) {
  //       yield GetPayoutAnalyticsCompletedState(payout);
  //     } else {
  //       yield GetPayoutAnalyticsFailedState();
  //     }
  //   } catch (e) {
  //     print(e);
  //     yield GetPayoutAnalyticsFailedState();
  //   }
  // }
}
