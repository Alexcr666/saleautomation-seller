import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multivendor_seller/blocs/faq_bloc/faq_bloc.dart';
import 'package:multivendor_seller/models/faq.dart';
import 'package:multivendor_seller/widgets/faq_item.dart';

class FaqPage extends StatefulWidget {
  @override
  _FaqPageState createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> with AutomaticKeepAliveClientMixin {
  FaqBloc faqBloc;
  SellerFaq sellerFaq;

  @override
  void initState() {
    super.initState();

    faqBloc = BlocProvider.of<FaqBloc>(context);
    faqBloc.add(GetAllFaqs());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: BlocBuilder(
        bloc: faqBloc,
        buildWhen: (previous, current) {
          if (current is GetAllFaqsInProgressState ||
              current is GetAllFaqsFailedState ||
              current is GetAllFaqsCompletedState) {
            return true;
          }
          return false;
        },
        builder: (context, state) {
          if (state is GetAllFaqsInProgressState) {
            return Center(child: CircularProgressIndicator());
          } else if (state is GetAllFaqsFailedState) {
            return Center(
              child: Text(
                'Failed to fetch faqs!',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          } else if (state is GetAllFaqsCompletedState) {
            sellerFaq = state.faqs;

            return sellerFaq.faqs.length == 0
                ? Center(
                    child: Text(
                      'No FAQ\'s found!',
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                    ),
                    itemBuilder: (context, index) {
                      return FaqItem(
                        faq: sellerFaq.faqs[index],
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 16.0,
                      );
                    },
                    itemCount: sellerFaq.faqs.length,
                  );
          }
          return SizedBox();
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
