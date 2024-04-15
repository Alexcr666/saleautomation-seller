import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:multivendor_seller/blocs/products_bloc/products_bloc.dart';
import 'package:multivendor_seller/models/product.dart';
import 'package:multivendor_seller/repositories/user_data_repository.dart';
import 'package:meta/meta.dart';

class AddNewProductBloc extends Bloc<ProductsEvent, ProductsState> {
  final UserDataRepository userDataRepository;

  AddNewProductBloc({@required this.userDataRepository}) : super(null);

  ProductsState get initialState => AddNewProductInitialState();

  @override
  Stream<ProductsState> mapEventToState(
    ProductsEvent event,
  ) async* {
    if (event is AddNewProductEvent) {
      yield* mapAddNewProductEventToState(event.product);
    }
  }

  Stream<ProductsState> mapAddNewProductEventToState(
      Map<dynamic, dynamic> product) async* {
    yield AddNewProductInProgressState();
    try {
      bool isAdded = await userDataRepository.addNewProduct(product);
      if (isAdded) {
        yield AddNewProductCompletedState();
      } else {
        yield AddNewProductFailedState();
      }
    } catch (e) {
      print(e);
      yield AddNewProductFailedState();
    }
  }
}
