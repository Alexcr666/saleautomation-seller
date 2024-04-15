part of 'zipcode_restriction_bloc.dart';

@immutable
abstract class ZipcodeRestrictionState {}

class ZipcodeRestrictionInitial extends ZipcodeRestrictionState {}

class GetAllZipcodesInProgressState extends ZipcodeRestrictionState {}

class GetAllZipcodesCompletedState extends ZipcodeRestrictionState {
  final Zipcode zipcode;

  GetAllZipcodesCompletedState(this.zipcode);
}

class GetAllZipcodesFailedState extends ZipcodeRestrictionState {}

class UpdateZipcodesInProgressState extends ZipcodeRestrictionState {}

class UpdateZipcodesCompletedState extends ZipcodeRestrictionState {}

class UpdateZipcodesFailedState extends ZipcodeRestrictionState {}
