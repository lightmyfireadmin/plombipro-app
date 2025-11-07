import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom AppBar widget for consistent navigation across all pages
/// Provides automatic back button handling and consistent styling
/// Impact: No more trapped users - consistent back navigation
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      leading: leading ?? _buildLeading(context),
      actions: actions,
      elevation: 0,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    // Check if we should show a back button
    if (!showBackButton) {
      return null;
    }

    // Check if we can pop (Navigator has previous route)
    final canPop = Navigator.of(context).canPop();

    if (!canPop) {
      return null;
    }

    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Retour',
      onPressed: () {
        if (onBackPressed != null) {
          onBackPressed!();
        } else {
          // Use Navigator.pop if available, otherwise use context.pop
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.pop();
          }
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Custom AppBar variant with a menu drawer for main pages
class CustomAppBarWithDrawer extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;

  const CustomAppBarWithDrawer({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      actions: actions,
      elevation: 0,
      // Leading will automatically show the drawer hamburger icon
      // when the Scaffold has a drawer
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Custom AppBar with search functionality
class CustomAppBarWithSearch extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Function(String)? onSearchChanged;
  final String? searchHint;

  const CustomAppBarWithSearch({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.onSearchChanged,
    this.searchHint,
  });

  @override
  State<CustomAppBarWithSearch> createState() => _CustomAppBarWithSearchState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarWithSearchState extends State<CustomAppBarWithSearch> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.searchHint ?? 'Rechercher...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: widget.onSearchChanged,
            )
          : Text(widget.title),
      leading: widget.showBackButton && Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Retour',
              onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                widget.onSearchChanged?.call('');
              }
            });
          },
        ),
        ...?widget.actions,
      ],
      elevation: 0,
    );
  }
}
