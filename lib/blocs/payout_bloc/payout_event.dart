part of 'payout_bloc.dart';

@immutable
abstract class PayoutEvent {}

class GetAllPayouts extends PayoutEvent {}

class UpdateGetAllPayouts extends PayoutEvent {
  final List<Payouts> payout;

  UpdateGetAllPayouts(this.payout);
}
class GetPayoutAnalytics extends PayoutEvent {}

class UpdateGetPayoutAnalytics extends PayoutEvent {
  final Payout payout;

  UpdateGetPayoutAnalytics(this.payout);
}

class RequestPayout extends PayoutEvent {
  final Map<String, dynamic> map;

  RequestPayout(this.map);
}

class CancelPayout extends PayoutEvent {
  final Map<String, dynamic> map;

  CancelPayout(this.map);
}

class ModifyRequestPayout extends PayoutEvent {
  final Map<String, dynamic> map;

  ModifyRequestPayout(this.map);
}

class GetCartInfo extends PayoutEvent {}
