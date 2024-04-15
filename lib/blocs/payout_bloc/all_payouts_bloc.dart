import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:multivendor_seller/blocs/payout_bloc/payout_bloc.dart';
import 'package:multivendor_seller/models/order.dart';
import 'package:multivendor_seller/models/payout.dart';
import 'package:multivendor_seller/repositories/user_data_repository.dart';
import 'package:meta/meta.dart';

class AllPayoutsBloc extends Bloc<PayoutEvent, PayoutState> {
  final UserDataRepository userDataRepository;

  StreamSubscription newPayoutSubscription;

  AllPayoutsBloc({@required this.userDataRepository}) : super(null);

  PayoutState get initialState => PayoutInitial();

  @override
  Future<void> close() {
    print('Closing New Payout BLOC');
    newPayoutSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<PayoutState> mapEventToState(
    PayoutEvent event,
  ) async* {
    if (event is GetAllPayouts) {
      yield* mapGetAllPayoutsToState();
    }
    if (event is UpdateGetAllPayouts) {
      yield* mapUpdateGetAllPayoutsToState(event.payout);
    }
  }

  Stream<PayoutState> mapGetAllPayoutsToState() async* {
    yield GetAllPayoutsInProgressState();

    try {
      newPayoutSubscription?.cancel();
      newPayoutSubscription =
          userDataRepository.getAllPayouts().listen((newPayout) {
        add(UpdateGetAllPayouts(newPayout));
      }, onError: (err) {
        print(err);
        return GetAllPayoutsFailedState();
      });
    } catch (e) {
      print(e);
      yield GetAllPayoutsFailedState();
    }
  }

  Stream<PayoutState> mapUpdateGetAllPayoutsToState(
      List<Payouts> newPayout) async* {
    yield GetAllPayoutsCompletedState(newPayout);
  }
}
