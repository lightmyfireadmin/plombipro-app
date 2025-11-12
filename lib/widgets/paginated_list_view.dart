import 'package:flutter/material.dart';

/// Reusable paginated list view widget (Phase 9)
///
/// Features:
/// - Infinite scroll (load more on scroll to bottom)
/// - Pull-to-refresh
/// - Loading indicators
/// - Error handling
/// - Empty state
/// - Customizable item builder
class PaginatedListView<T> extends StatefulWidget {
  /// Function to fetch items - receives page number and page size, returns list of items
  final Future<List<T>> Function(int page, int pageSize) fetchItems;

  /// Builder for individual list items
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Widget to show when list is empty
  final Widget emptyState;

  /// Number of items per page
  final int pageSize;

  /// Whether to enable pull-to-refresh
  final bool enableRefresh;

  /// Optional custom loading indicator
  final Widget? loadingIndicator;

  /// Optional separator between items
  final Widget? separator;

  /// Padding for the list
  final EdgeInsetsGeometry? padding;

  const PaginatedListView({
    super.key,
    required this.fetchItems,
    required this.itemBuilder,
    required this.emptyState,
    this.pageSize = 20,
    this.enableRefresh = true,
    this.loadingIndicator,
    this.separator,
    this.padding,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();
  final List<T> _items = [];

  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when user is 200px from bottom
      _loadMore();
    }
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _items.clear();
      _hasMore = true;
    });

    await _loadItems();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage++;
    });

    await _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final newItems = await widget.fetchItems(_currentPage, widget.pageSize);

      if (mounted) {
        setState(() {
          _items.addAll(newItems);
          _isLoading = false;
          _hasMore = newItems.length >= widget.pageSize;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
          if (_currentPage > 1) {
            _currentPage--; // Revert page increment on error
          }
        });
      }
    }
  }

  Future<void> _refresh() async {
    await _loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    // Initial loading state
    if (_isLoading && _items.isEmpty && _error == null) {
      return Center(
        child: widget.loadingIndicator ?? const CircularProgressIndicator(),
      );
    }

    // Error state (first page load)
    if (_error != null && _items.isEmpty) {
      return _buildErrorState();
    }

    // Empty state
    if (_items.isEmpty) {
      return widget.emptyState;
    }

    // List with items
    final listView = ListView.separated(
      controller: _scrollController,
      padding: widget.padding ?? const EdgeInsets.all(16),
      itemCount: _items.length + (_hasMore ? 1 : 0), // +1 for loading indicator
      separatorBuilder: (context, index) =>
          widget.separator ?? const SizedBox(height: 12),
      itemBuilder: (context, index) {
        // Show loading indicator at the end
        if (index >= _items.length) {
          return _buildLoadingMore();
        }

        // Regular item
        return widget.itemBuilder(context, _items[index], index);
      },
    );

    // Wrap with refresh indicator if enabled
    if (widget.enableRefresh) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Une erreur est survenue',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadFirstPage,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMore() {
    if (_error != null) {
      // Error loading more
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Erreur de chargement',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _error = null;
                });
                _loadMore();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    // Loading more
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: widget.loadingIndicator ??
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
      ),
    );
  }
}

/// Mixin to add pagination functionality to StatefulWidget state classes
mixin PaginationMixin<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();
  final List items = [];

  int currentPage = 1;
  int pageSize = 20;
  bool isLoadingMore = false;
  bool hasMore = true;

  /// Override this to provide the fetch function
  Future<List> fetchPage(int page, int pageSize);

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  Future<void> loadFirstPage() async {
    setState(() {
      currentPage = 1;
      items.clear();
      hasMore = true;
    });

    await loadMore();
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final newItems = await fetchPage(currentPage, pageSize);

      if (mounted) {
        setState(() {
          items.addAll(newItems);
          currentPage++;
          hasMore = newItems.length >= pageSize;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingMore = false;
        });
        // Handle error (show snackbar, etc.)
      }
    }
  }
}
