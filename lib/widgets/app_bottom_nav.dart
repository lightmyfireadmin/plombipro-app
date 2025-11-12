import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/plombipro_colors.dart';

/// Bottom Navigation Bar for main app pages
/// Provides quick access to frequently used sections
class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({
    super.key,
    this.currentIndex = 0,
  });

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home-enhanced');
        break;
      case 1:
        context.go('/clients');
        break;
      case 2:
        context.go('/quotes');
        break;
      case 3:
        context.go('/invoices');
        break;
      case 4:
        // Open drawer instead of navigating
        Scaffold.of(context).openDrawer();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: PlombiProColors.primaryBlue,
      unselectedItemColor: PlombiProColors.textSecondaryLight,
      backgroundColor: Colors.white,
      elevation: 8,
      selectedFontSize: 12,
      unselectedFontSize: 11,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Accueil',
          tooltip: 'Tableau de bord',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Clients',
          tooltip: 'Gestion des clients',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.request_quote),
          label: 'Devis',
          tooltip: 'Gestion des devis',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Factures',
          tooltip: 'Gestion des factures',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Menu',
          tooltip: 'Ouvrir le menu',
        ),
      ],
    );
  }
}
