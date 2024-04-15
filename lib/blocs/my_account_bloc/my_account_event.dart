part of 'my_account_bloc.dart';

@immutable
abstract class MyAccountEvent {}

class GetMyAccountDetailsEvent extends MyAccountEvent {
  @override
  String toString() => 'GetMyAccountDetailsEvent';
}

class GetAllAdminsEvent extends MyAccountEvent {
  @override
  String toString() => 'GetAllAdminsEvent';
}

class UpdateAdminDetailsEvent extends MyAccountEvent {
  final Map adminMap;

  UpdateAdminDetailsEvent(this.adminMap);
  @override
  String toString() => 'UpdateAdminDetailsEvent';
}

class ChangePasswordEvent extends MyAccountEvent {
  final Map map;

  ChangePasswordEvent(this.map);
}
