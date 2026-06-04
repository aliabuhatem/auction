import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auction_list_bloc.dart';
import '../widgets/auction_grid.dart';
import '../../../../core/widgets/auction_card.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/auction_entity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<AuctionListBloc>().add(LoadAuctions());
    _scrollController.addListener(() {
      if (_isBottom) context.read<AuctionListBloc>().add(LoadMoreAuctions());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AuctionListBloc>().add(RefreshAuctions());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    return _scrollController.offset >=
        _scrollController.position.maxScrollExtent * 0.9;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  static const _categories = [
    (null, 'Alles'),
    (AuctionCategory.vacation, 'Vakantie'),
    (AuctionCategory.beauty, 'Beauty'),
    (AuctionCategory.sauna, 'Sauna'),
    (AuctionCategory.food, 'Eten'),
    (AuctionCategory.experiences, 'Beleving'),
    (AuctionCategory.sports, 'Sport'),
    (AuctionCategory.wellness, 'Wellness'),
    (AuctionCategory.dayTrips, 'Dagtrips'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.backgroundLight,
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (_, __) => [
            _AppBarSliver(isDark: isDark),
            SliverPersistentHeader(
              pinned: true,
              delegate: _CategoryBarDelegate(isDark: isDark),
            ),
          ],
          body: BlocBuilder<AuctionListBloc, AuctionListState>(
            builder: (context, state) {
              if (state is AuctionListLoading) {
                return const AuctionGridShimmer();
              }
              if (state is AuctionListError) {
                return _ErrorView(message: state.message);
              }
              if (state is AuctionListLoaded) return _ContentView(state: state);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _AppBarSliver extends StatelessWidget {
  final bool isDark;
  const _AppBarSliver({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    return SliverAppBar(
      pinned: true,
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.cardShadow,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.gavel_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'Vakantieveilingen',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 19,
              letterSpacing: -0.3,
              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
      actions: [
        _AppBarIconButton(
          icon: Icons.search_rounded,
          isDark: isDark,
          onTap: () => context.push('/search'),
        ),
        const SizedBox(width: 4),
        _UnreadBellButton(isDark: isDark),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _AppBarIconButton(
      {required this.icon, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ── Category bar ──────────────────────────────────────────────────────────────

class _CategoryBarDelegate extends SliverPersistentHeaderDelegate {
  final bool isDark;
  const _CategoryBarDelegate({required this.isDark});

  @override
  double get minExtent => 58;
  @override
  double get maxExtent => 58;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    return Container(
      color: bg,
      child: BlocBuilder<AuctionListBloc, AuctionListState>(
        builder: (context, state) {
          final sel =
              state is AuctionListLoaded ? state.selectedCategory : null;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: _HomePageState._categories.length,
            itemBuilder: (_, i) {
              final cat = _HomePageState._categories[i];
              final isSelected = sel == cat.$1;
              return _CategoryPill(
                label: cat.$2,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () => context
                    .read<AuctionListBloc>()
                    .add(FilterByCategory(category: cat.$1)),
              );
            },
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoryBarDelegate old) => old.isDark != isDark;
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  const _CategoryPill({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected
              ? null
              : (isDark ? AppColors.darkCard : AppColors.backgroundGrey),
          borderRadius: BorderRadius.circular(100),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: AppColors.primaryShadow,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF8892A4) : AppColors.textSecondary),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

// ── Content view ──────────────────────────────────────────────────────────────

class _ContentView extends StatelessWidget {
  final AuctionListLoaded state;
  const _ContentView({required this.state});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryRed,
      onRefresh: () async =>
          context.read<AuctionListBloc>().add(RefreshAuctions()),
      child: CustomScrollView(
        slivers: [
          // ── Featured / ending soon ────────────────────────────────────────
          if (state.endingSoonAuctions.isNotEmpty) ...[
            const _SectionHeader(
              title: '🔥 Snel sluitend',
              onMore: null,
            ),
            SliverToBoxAdapter(
              child: _FeaturedCarousel(auctions: state.endingSoonAuctions),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
          ],

          // ── All auctions grid ─────────────────────────────────────────────
          const _SectionHeader(
            title: 'Alle veilingen',
            onMore: null,
          ),
          AuctionGrid(
            auctions: state.auctions,
            hasMore: state.hasMore,
            isLoadingMore: state.isLoadingMore,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMore;
  const _SectionHeader({required this.title, this.onMore});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  letterSpacing: -0.2,
                  color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                ),
              ),
            ),
            if (onMore != null)
              GestureDetector(
                onTap: onMore,
                child: const Text(
                  'Alles',
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Featured horizontal carousel ──────────────────────────────────────────────

class _FeaturedCarousel extends StatelessWidget {
  final List<AuctionEntity> auctions;
  const _FeaturedCarousel({required this.auctions});

  @override
  Widget build(BuildContext context) {
    if (auctions.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: auctions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => SizedBox(
          width: 180,
          child: AuctionCard(auction: auctions[i]),
        ),
      ),
    );
  }
}

// ── Unread-badge bell button ──────────────────────────────────────────────────

class _UnreadBellButton extends StatelessWidget {
  final bool isDark;
  const _UnreadBellButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return _AppBarIconButton(
        icon: Icons.notifications_outlined,
        isDark: isDark,
        onTap: () => context.push('/notifications'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .limit(10)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.data?.docs.length ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _AppBarIconButton(
              icon: Icons.notifications_outlined,
              isDark: isDark,
              onTap: () => context.push('/notifications'),
            ),
            if (count > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  size: 36, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            const Text(
              'Verbindingsfout',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<AuctionListBloc>().add(LoadAuctions()),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(AppStrings.tryAgain(context)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(160, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
