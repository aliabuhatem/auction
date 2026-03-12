import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.payNow(context)),
      ),
      body: const Center(
        child: Text('Betaling wordt verwerkt...'),
      ),
    );
  }
}
