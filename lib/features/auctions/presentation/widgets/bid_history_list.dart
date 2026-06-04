import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/bid_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class BidHistoryList extends StatelessWidget {
  final String auctionId;
  const BidHistoryList({super.key, required this.auctionId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor  = isDark ? const Color(0xFF8892A4) : AppColors.textSecondary;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('auctions')
          .doc(auctionId)
          .collection('bids')
          .orderBy('placedAt', descending: true)
          .limit(30)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Text(AppStrings.bidLoadError(context),
                style: TextStyle(color: subColor)),
          );
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gavel, size: 48, color: subColor),
                const SizedBox(height: 8),
                Text(AppStrings.noBids(context),
                    style: TextStyle(color: subColor)),
              ],
            ),
          );
        }
        final bids = snap.data!.docs
            .map((d) => BidModel.fromFirestore(d))
            .toList();
        return ListView.builder(
          itemCount: bids.length,
          itemBuilder: (_, i) {
            final bid  = bids[i];
            final isTop = i == 0;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isTop
                    ? AppColors.primaryRed
                    : (isDark ? const Color(0xFF2D3748) : AppColors.backgroundGrey),
                child: Text(
                  bid.maskedUserName.isNotEmpty
                      ? bid.maskedUserName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: isTop
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                bid.maskedUserName,
                style: TextStyle(
                  fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
              ),
              subtitle: Text(
                  DateFormatter.timeAgo(bid.placedAt,
                      locale: Localizations.localeOf(context).languageCode),
                  style: TextStyle(color: subColor, fontSize: 12)),
              trailing: Text(
                CurrencyFormatter.format(bid.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isTop ? AppColors.primaryRed : textColor,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
