part of 'zipcode_restriction_bloc.dart';

@immutable
abstract class ZipcodeRestrictionEvent {}

class GetAllZipcodes extends ZipcodeRestrictionEvent {}

class UpdateZipcodes extends ZipcodeRestrictionEvent {
  final Map map;

  UpdateZipcodes(this.map);
}
