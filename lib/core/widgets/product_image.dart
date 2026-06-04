import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Smart product image.
///
/// Resolves the image source in this order:
///  1. An `assets/…` path  → bundled asset
///  2. A valid http(s) URL → cached network image
///  3. Anything else / load error / empty → a bundled fallback asset
///     (watch.png or screen.png), chosen deterministically from [seed] so each
///     product consistently shows the same picture.
class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final String seed;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.seed = '',
    this.fit = BoxFit.cover,
  });

  /// Bundled product images shipped in assets/images/.
  static const List<String> fallbackAssets = [
    'assets/images/watch.png',
    'assets/images/screen.png',
  ];

  String get _fallback {
    final key = seed.isNotEmpty ? seed : (imageUrl ?? '');
    final idx = key.hashCode.abs() % fallbackAssets.length;
    return fallbackAssets[idx];
  }

  bool get _isAsset => (imageUrl ?? '').startsWith('assets/');
  bool get _isNetwork {
    final u = imageUrl ?? '';
    return u.startsWith('http://') || u.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkCard
        : AppColors.backgroundGrey;

    if (_isAsset) {
      return Image.asset(imageUrl!, fit: fit,
          errorBuilder: (_, __, ___) => _asset(_fallback, fit));
    }

    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: fit,
        placeholder: (_, __) => Container(
          color: bg,
          child: const Center(
            child: SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.accentBright),
            ),
          ),
        ),
        // No usable network image → show a real bundled product picture.
        errorWidget: (_, __, ___) => _asset(_fallback, fit),
      );
    }

    // Empty / unrecognised → bundled fallback.
    return _asset(_fallback, fit);
  }

  Widget _asset(String path, BoxFit fit) =>
      Image.asset(path, fit: fit, errorBuilder: (_, __, ___) =>
          const ColoredBox(color: AppColors.darkCard));
}
