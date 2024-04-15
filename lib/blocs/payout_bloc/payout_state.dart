part of 'payout_bloc.dart';

@immutable
abstract class PayoutState {}

class PayoutInitial extends PayoutState {}

class GetAllPayoutsInProgressState extends PayoutState {}

class GetAllPayoutsFailedState extends PayoutState {}

class GetAllPayoutsCompletedState extends PayoutState {
  final List<Payouts> payout;

  GetAllPayoutsCompletedState(this.payout);
}

class GetPayoutAnalyticsInProgressState extends PayoutState {}

class GetPayoutAnalyticsFailedState extends PayoutState {}

class GetPayoutAnalyticsCompletedState extends PayoutState {
  final Payout payout;

  GetPayoutAnalyticsCompletedState(this.payout);
}

class RequestPayoutInProgressState extends PayoutState {}

class RequestPayoutFailedState extends PayoutState {}

class RequestPayoutCompletedState extends PayoutState {}

class ModifyRequestPayoutInProgressState extends PayoutState {}

class ModifyRequestPayoutFailedState extends PayoutState {}

class ModifyRequestPayoutCompletedState extends PayoutState {}

class CancelPayoutInProgressState extends PayoutState {}

class CancelPayoutFailedState extends PayoutState {}

class CancelPayoutCompletedState extends PayoutState {}

class GetCartInfoCompletedState extends PayoutState {
  final GlobalSettings globalSettings;
  GetCartInfoCompletedState(this.globalSettings);
}

class GetCartInfoFailedState extends PayoutState {}

class GetCartInfoInProgressState extends PayoutState {}
