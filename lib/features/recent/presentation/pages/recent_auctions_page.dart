// lib/features/recent/presentation/pages/recent_auctions_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../auctions/presentation/widgets/auction_grid.dart';
import '../bloc/recent_bloc.dart';

/// /recente-veilingen — auctions the user recently opened, newest first.
class RecentAuctionsPage extends StatefulWidget {
  const RecentAuctionsPage({super.key});

  @override
  State<RecentAuctionsPage> createState() => _RecentAuctionsPageState();
}

class _RecentAuctionsPageState extends State<RecentAuctionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<RecentBloc>().add(const LoadRecent());
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.clearHistory(ctx)),
        content: Text(AppStrings.recentAuctions(ctx)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel(ctx)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.clearHistory(ctx)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<RecentBloc>().add(const ClearRecent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.recentAuctions(context),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          BlocBuilder<RecentBloc, RecentState>(
            builder: (context, state) {
              final hasItems = state is RecentLoaded && state.auctions.isNotEmpty;
              if (!hasItems) return const SizedBox.shrink();
              return TextButton(
                onPressed: _confirmClear,
                child: Text(
                  AppStrings.clearHistory(context),
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<RecentBloc, RecentState>(
        builder: (context, state) {
          if (state is RecentLoading || state is RecentInitial) {
            return const AuctionGridShimmer();
          }
          if (state is RecentError) {
            return _ErrorState(
              message: state.message,
              onRetry: () => context.read<RecentBloc>().add(const LoadRecent()),
            );
          }
          if (state is RecentLoaded) {
            if (state.auctions.isEmpty) return const _EmptyState();
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<RecentBloc>().add(const LoadRecent()),
              child: CustomScrollView(
                slivers: [
                  AuctionGrid(auctions: state.auctions),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppDimensions.spaceXL),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 38,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              AppStrings.recentEmpty(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppDimensions.fontXL,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceXL),
            FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              child: Text(AppStrings.allAuctions(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(AppStrings.retryBtn(context)),
            ),
          ],
        ),
      ),
    );
  }
}
