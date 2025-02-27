import 'package:multivendor_seller/models/order.dart';
import 'package:multivendor_seller/models/user.dart';
import 'package:multivendor_seller/repositories/user_data_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'manage_users_bloc.dart';

class UsersOrderBloc extends Bloc<ManageUsersEvent, ManageUsersState> {
  final UserDataRepository userDataRepository;

  UsersOrderBloc({@required this.userDataRepository}) : super(null);

  ManageUsersState get initialState => UsersOrderInitialState();

  @override
  Stream<ManageUsersState> mapEventToState(
    ManageUsersEvent event,
  ) async* {
    if (event is GetUsersOrderManageUsersEvent) {
      yield* mapGetUsersOrderManageUsersEventToState(event.orderIds);
    }
  }

  Stream<ManageUsersState> mapGetUsersOrderManageUsersEventToState(
      String orderIds) async* {
    yield GetUsersOrderInProgressState();
    try {
      List<Order> orders = await userDataRepository.getUsersOrder(orderIds);
      if (orders != null) {
        yield GetUsersOrderCompletedState(orders: orders);
      } else {
        yield GetUsersOrderFailedState();
      }
    } catch (e) {
      print(e);
      yield GetUsersOrderFailedState();
    }
  }
}
