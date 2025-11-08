import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _userName = 'Utilisateur';
  String _userEmail = 'email@example.com';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userProfile = await SupabaseService.fetchUserProfile();
    if (userProfile != null && mounted) {
      setState(() {
        _userName = userProfile.firstName ?? userProfile.email ?? 'Utilisateur';
        _userEmail = userProfile.email ?? 'email@example.com';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(_userName),
            accountEmail: Text(_userEmail),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blueGrey),
            ),
            decoration: const BoxDecoration(
              color: Colors.blueGrey,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Tableau de bord'),
            onTap: () {
              context.go('/home');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Analytiques'),
            onTap: () {
              context.go('/analytics');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Rapports Avancés'),
            onTap: () {
              context.go('/advanced-reports');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.request_quote),
            title: const Text('Devis'),
            onTap: () {
              context.go('/quotes');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Factures'),
            onTap: () {
              context.go('/invoices');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.payments),
            title: const Text('Paiements'),
            onTap: () {
              context.go('/payments');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clients'),
            onTap: () {
              context.go('/clients');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Produits'),
            onTap: () {
              context.go('/products');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Catalogues'),
            onTap: () {
              context.go('/catalogs');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Scanner Facture'),
            onTap: () {
              context.go('/scan-invoice');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Outils'),
            onTap: () {
              context.go('/tools');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.construction),
            title: const Text('Chantiers'),
            onTap: () {
              context.go('/job-sites');
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              context.go('/settings');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mon Profil'),
            onTap: () {
              context.go('/profile');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Mon Entreprise'),
            onTap: () {
              context.go('/company-profile');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () async {
              await SupabaseService.signOut();
              if (mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}