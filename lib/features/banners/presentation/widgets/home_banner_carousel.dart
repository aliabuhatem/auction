// lib/features/banners/presentation/widgets/home_banner_carousel.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../../injection_container.dart' as di;
import '../../data/banner_datasource.dart';

/// Streams active promo banners and shows them as a swipeable carousel.
/// Renders nothing when there are no active banners (graceful when empty).
class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({super.key});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(BannerEntity banner) {
    switch (banner.linkType) {
      case 'auction':
        if (banner.linkId != null) {
          context.push(AppRoutes.auctionDetailPath(banner.linkId!));
        }
      case 'category':
        context.push(AppRoutes.allAuctions);
      case 'external':
        final url = banner.linkUrl;
        if (url != null && url.isNotEmpty) {
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BannerEntity>>(
      stream: di.sl<BannerDatasource>().watchActiveBanners(),
      builder: (context, snapshot) {
        final banners = snapshot.data ?? const <BannerEntity>[];
        if (banners.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            const SizedBox(height: AppDimensions.spaceM),
            SizedBox(
              height: 150,
              child: PageView.builder(
                controller: _pageController,
                itemCount: banners.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final b = banners[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM),
                    child: GestureDetector(
                      onTap: () => _onTap(b),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusXL),
                        child: ProductImage(
                          imageUrl: b.imageUrl,
                          seed: b.id,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (banners.length > 1) ...[
              const SizedBox(height: AppDimensions.spaceS),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(banners.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin:
                        const EdgeInsets.symmetric(horizontal: AppDimensions.spaceXXS),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? AppColors.gold : AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                    ),
                  );
                }),
              ),
            ],
          ],
        );
      },
    );
  }
}
