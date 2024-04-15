part of 'faq_bloc.dart';

@immutable
abstract class FaqState {}

class FaqInitial extends FaqState {}

class GetAllFaqsInProgressState extends FaqState {}

class GetAllFaqsFailedState extends FaqState {}

class GetAllFaqsCompletedState extends FaqState {
  final SellerFaq faqs;

  GetAllFaqsCompletedState(this.faqs);
}
