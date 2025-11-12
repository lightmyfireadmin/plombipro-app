import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Reusable cached image widget with lazy loading (Phase 9)
///
/// Features:
/// - Automatic image caching for better performance
/// - Shimmer loading effect
/// - Error handling with fallback icon
/// - Memory-efficient image loading
/// - Customizable aspect ratio and fit
class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final Widget? placeholder;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.placeholder,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ?? _buildShimmerPlaceholder(context),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildErrorWidget(context),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
      memCacheWidth: width != null ? (width! * 2).toInt() : null,
      memCacheHeight: height != null ? (height! * 2).toInt() : null,
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildShimmerPlaceholder(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: shimmerBaseColor ?? Colors.grey[300]!,
      highlightColor: shimmerHighlightColor ?? Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(
        Icons.broken_image,
        size: 48,
        color: Colors.grey[400],
      ),
    );
  }
}

/// Circular avatar with cached network image
class CachedAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? fallbackText;
  final Color? backgroundColor;

  const CachedAvatarWidget({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.fallbackText,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        child: Text(
          _getInitials(fallbackText ?? '?'),
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        child: Text(
          _getInitials(fallbackText ?? '?'),
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String text) {
    if (text.isEmpty) return '?';

    final parts = text.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return text[0].toUpperCase();
  }
}

/// Grid of cached images with lazy loading
class CachedImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final void Function(String imageUrl, int index)? onImageTap;

  const CachedImageGrid({
    super.key,
    required this.imageUrls,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
    this.childAspectRatio = 1,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        final imageUrl = imageUrls[index];
        return GestureDetector(
          onTap: () => onImageTap?.call(imageUrl, index),
          child: CachedImageWidget(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}

/// Lazy loading image list with pagination support
class LazyImageList extends StatelessWidget {
  final List<String> imageUrls;
  final ScrollController? scrollController;
  final Widget Function(BuildContext, String, int)? itemBuilder;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const LazyImageList({
    super.key,
    required this.imageUrls,
    this.scrollController,
    this.itemBuilder,
    this.itemHeight = 200,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        final imageUrl = imageUrls[index];

        if (itemBuilder != null) {
          return itemBuilder!(context, imageUrl, index);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SizedBox(
            height: itemHeight,
            child: CachedImageWidget(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}

/// Image carousel with caching
class CachedImageCarousel extends StatelessWidget {
  final List<String> imageUrls;
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;

  const CachedImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 250,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return SizedBox(
        height: height,
        child: Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.image_not_supported, size: 48),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return CachedImageWidget(
            imageUrl: imageUrls[index],
            fit: BoxFit.cover,
            width: double.infinity,
            height: height,
          );
        },
      ),
    );
  }
}

/// Utility class for image cache management
class ImageCacheManager {
  /// Clear all cached images
  static Future<void> clearCache() async {
    await CachedNetworkImage.evictFromCache(
      '',
      cacheKey: '',
    );
  }

  /// Precache images for better performance
  static Future<void> precacheImages(
    BuildContext context,
    List<String> imageUrls,
  ) async {
    for (final url in imageUrls) {
      try {
        await precacheImage(
          CachedNetworkImageProvider(url),
          context,
        );
      } catch (e) {
        // Ignore errors during precaching
        debugPrint('Failed to precache image: $url');
      }
    }
  }
}
