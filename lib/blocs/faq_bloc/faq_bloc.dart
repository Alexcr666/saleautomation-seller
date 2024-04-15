import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:multivendor_seller/models/faq.dart';
import 'package:multivendor_seller/repositories/user_data_repository.dart';
import 'package:meta/meta.dart';

part 'faq_event.dart';
part 'faq_state.dart';

class FaqBloc extends Bloc<FaqEvent, FaqState> {
  final UserDataRepository userDataRepository;

  FaqBloc({this.userDataRepository}) : super(FaqInitial());

  @override
  Stream<FaqState> mapEventToState(
    FaqEvent event,
  ) async* {
    if (event is GetAllFaqs) {
      yield* mapGetAllFaqsToState();
    }
  }

  Stream<FaqState> mapGetAllFaqsToState() async* {
    yield GetAllFaqsInProgressState();
    try {
      SellerFaq sellerFaq = await userDataRepository.getAllFaqs();
      if (sellerFaq != null) {
        yield GetAllFaqsCompletedState(sellerFaq);
      } else {
        yield GetAllFaqsFailedState();
      }
    } catch (e) {
      print(e);
      yield GetAllFaqsFailedState();
    }
  }
}
