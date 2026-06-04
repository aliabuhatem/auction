// Bidding functionality is embedded in AuctionDetailPage via BiddingBloc.
// This file is kept as a standalone widget for modal/sheet bidding.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auctions/presentation/bloc/bidding_bloc.dart';
import '../../../core/widgets/bid_button.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class BiddingSheet extends StatelessWidget {
  final String auctionId;
  final double currentBid;
  final double minBidIncrement;

  const BiddingSheet({
    super.key,
    required this.auctionId,
    required this.currentBid,
    this.minBidIncrement = 1.0,
  });

  static Future<void> show(
    BuildContext context, {
    required String auctionId,
    required double currentBid,
    double minBidIncrement = 1.0,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BiddingSheet(
        auctionId: auctionId,
        currentBid: currentBid,
        minBidIncrement: minBidIncrement,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final next = currentBid + minBidIncrement;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(AppStrings.placeBidTitle(context),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            const SizedBox(height: 8),
            Text('${AppStrings.currentBid(context)}: ${CurrencyFormatter.format(currentBid)}',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${AppStrings.yourBid(context)}: ',
                      style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  Text(
                    CurrencyFormatter.format(next),
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryRed),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            BlocBuilder<BiddingBloc, BiddingState>(
              builder: (context, state) => BidButton(
                nextBid: next,
                isLoading: state is BiddingPlacing,
                onTap: state is BiddingPlacing
                    ? null
                    : () {
                        context
                            .read<BiddingBloc>()
                            .add(SubmitBid(auctionId: auctionId, amount: next));
                        Navigator.pop(context);
                      },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
