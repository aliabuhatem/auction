import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/bid_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class BidHistoryList extends StatelessWidget {
  final String auctionId;
  const BidHistoryList({super.key, required this.auctionId});

  @override
  Widget build(BuildContext context) {
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
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gavel, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('Nog geen biedingen', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        final bids = snap.data!.docs.map((d) => BidModel.fromFirestore(d)).toList();
        return ListView.builder(
          itemCount: bids.length,
          itemBuilder: (_, i) {
            final bid = bids[i];
            final isTop = i == 0;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isTop ? const Color(0xFFE63946) : Colors.grey[200],
                child: Text(
                  bid.maskedUserName.isNotEmpty ? bid.maskedUserName[0].toUpperCase() : '?',
                  style: TextStyle(color: isTop ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                bid.maskedUserName,
                style: TextStyle(fontWeight: isTop ? FontWeight.bold : FontWeight.normal),
              ),
              subtitle: Text(DateFormatter.timeAgo(bid.placedAt)),
              trailing: Text(
                CurrencyFormatter.format(bid.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isTop ? const Color(0xFFE63946) : Colors.black87,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
