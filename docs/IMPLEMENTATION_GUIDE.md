# PlombiPro Design System - Quick Implementation Guide

**Priority roadmap for implementing the UX/UI identity**

---

## Before You Start

1. **Read**: `DESIGN_SYSTEM.md` - Full design system documentation
2. **Reference**: `COLOR_PALETTE.md` - Color implementation details
3. **Understand**: `USER_FLOWS.md` - Key user journeys

---

## Phase 1: Critical UX Fixes (Week 1-2) 🚨

**Goal:** Fix the problems that make the app hard to use

### Priority 1: Navigation Structure

#### Problem: Users get trapped without back button, duplicate hamburger menus

#### Solution: Bottom Navigation + Proper Back Buttons

**File:** `lib/config/router.dart` + Create `lib/widgets/main_navigation.dart`

```dart
// lib/widgets/main_navigation.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigation extends StatelessWidget {
  final Widget child;

  const MainNavigation({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(location),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Chantiers',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Clients',
          ),
          NavigationDestination(
            icon: Icon(Icons.euro_outlined),
            selectedIcon: Icon(Icons.euro),
            label: 'Argent',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'Plus',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/home') || location == '/') return 0;
    if (location.startsWith('/job-sites')) return 1;
    if (location.startsWith('/clients')) return 2;
    if (location.startsWith('/invoices') ||
        location.startsWith('/quotes') ||
        location.startsWith('/payments')) return 3;
    return 4; // More
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/job-sites');
        break;
      case 2:
        context.go('/clients');
        break;
      case 3:
        context.go('/invoices');
        break;
      case 4:
        context.go('/more');
        break;
    }
  }
}
```

**Create "More" page:**
```dart
// lib/screens/more/more_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plus'),
      ),
      body: ListView(
        children: [
          // Profile Header
          UserAccountsDrawerHeader(
            accountName: Text('Nom Utilisateur'),
            accountEmail: Text('email@exemple.com'),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person, size: 40),
            ),
          ),

          // Menu Items
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profil'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => context.push('/profile'),
          ),
          ListTile(
            leading: Icon(Icons.business),
            title: Text('Entreprise'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => context.push('/company'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Rapports'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => context.push('/reports'),
          ),
          ListTile(
            leading: Icon(Icons.inventory),
            title: Text('Produits'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => context.push('/products'),
          ),
          ListTile(
            leading: Icon(Icons.build),
            title: Text('Outils'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => context.push('/tools'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Paramètres'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => context.push('/settings'),
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Aide'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => context.push('/help'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Déconnexion', style: TextStyle(color: Colors.red)),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion'),
        content: Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement logout
              Navigator.pop(context);
              context.go('/login');
            },
            child: Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
```

**Update router to use MainNavigation:**
```dart
// In lib/config/router.dart
ShellRoute(
  builder: (context, state, child) {
    return MainNavigation(child: child);
  },
  routes: [
    GoRoute(path: '/home', builder: (context, state) => HomePage()),
    GoRoute(path: '/job-sites', builder: (context, state) => JobSitesListPage()),
    GoRoute(path: '/clients', builder: (context, state) => ClientsListPage()),
    GoRoute(path: '/invoices', builder: (context, state) => InvoicesListPage()),
    GoRoute(path: '/more', builder: (context, state) => MorePage()),
  ],
),
```

**Add back button to all AppBars:**
```dart
// Standard AppBar pattern for all screens
AppBar(
  // Flutter automatically adds back button when Navigator.canPop()
  // But you can customize:
  leading: Navigator.canPop(context)
      ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        )
      : null,
  title: Text('Page Title'),
  actions: [/* contextual actions */],
)
```

---

### Priority 2: Loading States

#### Problem: Generic spinners, no feedback

#### Solution: Skeleton screens

**Create reusable skeleton widgets:**

```dart
// lib/widgets/skeleton_widgets.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonLine({
    this.width = double.infinity,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLine(width: 200, height: 20),
            SizedBox(height: 8),
            SkeletonLine(width: 150, height: 16),
            SizedBox(height: 8),
            SkeletonLine(width: double.infinity, height: 14),
            SizedBox(height: 4),
            SkeletonLine(width: double.infinity, height: 14),
          ],
        ),
      ),
    );
  }
}

class SkeletonListView extends StatelessWidget {
  final int itemCount;

  const SkeletonListView({this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => SkeletonCard(),
    );
  }
}
```

**Usage:**
```dart
// Instead of:
if (isLoading) {
  return Center(child: CircularProgressIndicator());
}

// Use:
if (isLoading) {
  return SkeletonListView(itemCount: 5);
}
```

**Add to pubspec.yaml:**
```yaml
dependencies:
  shimmer: ^3.0.0
```

---

## Phase 2: Visual Identity (Week 3-4) 🎨

**Goal:** Make the app look modern and distinctive

### Update Color System

**File:** `lib/config/app_theme.dart`

Add the extended color palette (see `COLOR_PALETTE.md` for full implementation):

```dart
class AppTheme {
  // Extended Primary Palette
  static const Color primaryDeep = Color(0xFF0D47A1);
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryBright = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryMist = Color(0xFFE3F2FD);

  // Semantic color getters for easy access
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'in_progress':
        return info;
      case 'completed':
      case 'paid':
        return success;
      case 'pending':
      case 'draft':
        return warning;
      case 'cancelled':
      case 'overdue':
        return error;
      default:
        return neutral500;
    }
  }

  static Color getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'in_progress':
        return infoMist;
      case 'completed':
      case 'paid':
        return successMist;
      case 'pending':
      case 'draft':
        return warningMist;
      case 'cancelled':
      case 'overdue':
        return errorMist;
      default:
        return neutral100;
    }
  }
}
```

---

### Create Reusable Components

**File:** `lib/widgets/plombi_components.dart`

```dart
import 'package:flutter/material.dart';

/// Elevated card with consistent styling
class PlombiCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool elevated;

  const PlombiCard({
    required this.child,
    this.onTap,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevated ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

/// Status chip with color coding
class StatusChip extends StatelessWidget {
  final String label;
  final String status;

  const StatusChip({
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getStatusColor(status);
    final bgColor = AppTheme.getStatusBackgroundColor(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text(actionLabel!),
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## Phase 3: Micro-interactions (Week 5-6) ✨

**Goal:** Add delight and feedback

### Quick Wins

#### 1. Button Press Feedback

```dart
// Wrap buttons with AnimatedScale
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const AnimatedButton({required this.child, this.onPressed});

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
```

#### 2. Success Feedback

```dart
// Show snackbar with success animation
void showSuccessMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      duration: Duration(seconds: 2),
    ),
  );
}
```

#### 3. Pull to Refresh

```dart
// Add to list views
RefreshIndicator(
  onRefresh: _handleRefresh,
  color: Theme.of(context).colorScheme.primary,
  child: ListView(...),
)

Future<void> _handleRefresh() async {
  // Reload data
  await Future.delayed(Duration(seconds: 1));
  setState(() {
    // Update state
  });
}
```

---

## Phase 4: UX Improvements (Week 7-8) 🎯

**Goal:** Streamline workflows

### Contextual Quick Actions

```dart
// Add to job detail page
List<Widget> _buildQuickActions(Job job) {
  List<Widget> actions = [];

  if (!job.hasInvoice && job.isCompleted) {
    actions.add(
      ElevatedButton.icon(
        icon: Icon(Icons.receipt),
        label: Text('Créer facture'),
        onPressed: () => _createInvoice(job),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
        ),
      ),
    );
  }

  if (job.isActive && !job.isTimerRunning) {
    actions.add(
      OutlinedButton.icon(
        icon: Icon(Icons.play_arrow),
        label: Text('Démarrer chrono'),
        onPressed: () => _startTimer(job),
      ),
    );
  }

  return actions;
}
```

### Search & Filter

```dart
// Add to list pages
AppBar(
  title: SearchBar(
    hintText: 'Rechercher...',
    leading: Icon(Icons.search),
    onChanged: (value) => _handleSearch(value),
  ),
  actions: [
    IconButton(
      icon: Icon(Icons.filter_list),
      onPressed: () => _showFilterSheet(),
    ),
  ],
)
```

---

## Testing Checklist

After each phase, verify:

### Phase 1
- [ ] Bottom navigation works on all main screens
- [ ] Back button appears and works on all detail screens
- [ ] No trapped pages
- [ ] Loading states show skeleton screens
- [ ] All screens accessible from navigation

### Phase 2
- [ ] New colors applied consistently
- [ ] Status chips use semantic colors
- [ ] Cards have proper elevation
- [ ] Typography follows design system
- [ ] Dark mode still works

### Phase 3
- [ ] Buttons provide press feedback
- [ ] Success messages appear for actions
- [ ] Pull-to-refresh works on lists
- [ ] Animations run at 60fps
- [ ] No janky animations

### Phase 4
- [ ] Contextual actions appear correctly
- [ ] Search works
- [ ] Filters work
- [ ] Empty states show helpful messages
- [ ] Error states are clear

---

## Quick Debugging

### Common Issues

**Bottom navigation doesn't update:**
```dart
// Make sure you're using state management properly
// Consider using StatefulWidget or state management solution
```

**Skeleton screens flicker:**
```dart
// Add key to skeleton widgets
SkeletonListView(key: ValueKey('skeleton'))
```

**Colors don't match design:**
```dart
// Always use AppTheme.colorName, never hard-coded values
// Good: color: AppTheme.primary
// Bad: color: Color(0xFF1976D2)
```

**Animations are janky:**
```dart
// Use const constructors where possible
// Avoid heavy computations in build()
// Consider using RepaintBoundary for complex widgets
```

---

## Resources

- **Full Design System**: `docs/DESIGN_SYSTEM.md`
- **Color Reference**: `docs/COLOR_PALETTE.md`
- **User Flows**: `docs/USER_FLOWS.md`
- **Flutter Docs**: https://docs.flutter.dev
- **Material Design 3**: https://m3.material.io

---

## Getting Help

If stuck:
1. Check the full design system docs
2. Look at example implementations in this guide
3. Test on device (not just simulator)
4. Review Flutter/Material Design 3 docs
5. Ask for help with specific error messages

---

## Next Steps After Phase 4

1. **User Testing**: Get real users to test the app
2. **Analytics**: Implement tracking to see how users navigate
3. **Iterate**: Based on feedback, refine the design
4. **Polish**: Add more advanced animations
5. **Optimize**: Improve performance

---

*Start with Phase 1 - it will make the biggest immediate impact on user experience!*
