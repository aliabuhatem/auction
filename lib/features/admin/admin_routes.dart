import 'package:auction/features/admin/presentation/bloc/admin_auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/datasources/admin_auction_datasource.dart';
import 'data/datasources/admin_product_datasource.dart';
import 'data/datasources/admin_remote_datasource.dart';

class AdminProviders extends StatelessWidget {
  final Widget child;
  const AdminProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AdminRemoteDatasource()),
        RepositoryProvider(create: (_) => AdminAuctionDatasource()),
        RepositoryProvider(create: (_) => AdminProductDatasource()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => AdminAuthBloc(ctx.read<AdminRemoteDatasource>())
              ..add(AdminAuthStarted()),
          ),
        ],
        child: child,
      ),
    );
  }
}

// ── Placeholder widget used by the shell for pages not yet built ───────────────

class AdminComingSoon extends StatelessWidget {
  final String title;
  final int    part;
  const AdminComingSoon({super.key, required this.title, required this.part});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.construction_rounded, size: 56, color: Color(0xFFCBD5E1)),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 4),
        Text('Wordt gebouwd in Deel $part',
          style: const TextStyle(color: Color(0xFF8B9CB6), fontSize: 13)),
      ]),
    );
  }
}
