import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../../models/client.dart';
import '../../services/supabase_service.dart';
import '../../config/plombipro_colors.dart';
import '../../config/plombipro_spacing.dart';
import '../../config/glassmorphism_theme.dart';
import '../../widgets/glassmorphic/glass_card.dart';
import 'package:animate_do/animate_do.dart';

/// Premium glassmorphic clients list with modern design
class ClientsListPage extends StatefulWidget {
  const ClientsListPage({super.key});

  @override
  State<ClientsListPage> createState() => _ClientsListPageState();
}

class _ClientsListPageState extends State<ClientsListPage> with SingleTickerProviderStateMixin {
  List<Client> _clients = [];
  List<Client> _filteredClients = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fetchClients();
    _searchController.addListener(_filterClients);

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterClients);
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchClients() async {
    setState(() => _isLoading = true);
    try {
      final clients = await SupabaseService.fetchClients();
      if (mounted) {
        setState(() {
          _clients = clients;
          _filterClients();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur de chargement des clients: ${e.toString()}"),
            backgroundColor: PlombiProColors.error,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterClients() {
    final searchTerm = _searchController.text.toLowerCase();
    setState(() {
      _filteredClients = _clients.where((client) {
        final clientName = client.name.toLowerCase();
        final clientEmail = (client.email ?? '').toLowerCase();
        final clientPhone = (client.phone ?? '').toLowerCase();
        return clientName.contains(searchTerm) ||
               clientEmail.contains(searchTerm) ||
               clientPhone.contains(searchTerm);
      }).toList();
    });
  }

  void _navigateToClientForm({Client? client}) async {
    final result = await context.push(
      client != null ? '/clients/${client.id}' : '/clients/new',
      extra: client,
    );
    if (result == true && mounted) {
      _fetchClients();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: PlombiProColors.backgroundLight,
      appBar: _buildGlassAppBar(),
      body: Stack(
        children: [
          // Gradient background
          _buildGradientBackground(),

          // Main content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildGlassSearchBar(),
                const SizedBox(height: 16),
                _buildClientsHeader(),
                const SizedBox(height: 12),
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : RefreshIndicator(
                          onRefresh: _fetchClients,
                          color: Colors.white,
                          backgroundColor: PlombiProColors.primaryBlue,
                          child: _filteredClients.isEmpty
                              ? _buildEmptyState()
                              : _buildClientsList(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildGlassFAB(),
    );
  }

  PreferredSizeWidget _buildGlassAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Text(
              'Mes Clients',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlombiProColors.primaryBlue,
            PlombiProColors.tertiaryTeal,
            PlombiProColors.primaryBlueDark,
          ],
        ),
      ),
    );
  }

  Widget _buildGlassSearchBar() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Rechercher un client...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClientsHeader() {
    return FadeInLeft(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.people_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_filteredClients.length} client${_filteredClients.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    Text(
                      'sur ${_clients.length} total',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
            // Filter button
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
                onPressed: () {
                  // TODO: Implement filter
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement des clients...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person_off_rounded,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Aucun client trouvé',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _searchController.text.isEmpty
                  ? 'Commencez par ajouter votre premier client'
                  : 'Aucun résultat pour votre recherche',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildAddClientButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildClientsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _filteredClients.length,
      itemBuilder: (context, index) {
        final client = _filteredClients[index];
        return FadeInUp(
          delay: Duration(milliseconds: 50 * index),
          duration: const Duration(milliseconds: 400),
          child: _GlassClientCard(
            client: client,
            onTap: () => context.push('/clients/${client.id}', extra: client),
            onEdit: () => _navigateToClientForm(client: client),
          ),
        );
      },
    );
  }

  Widget _buildAddClientButton() {
    return GlassCard(
      onTap: () => _navigateToClientForm(),
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.person_add_rounded, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Text(
            'Ajouter un client',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassFAB() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: GestureDetector(
        onTapDown: (_) => _fabAnimationController.forward(),
        onTapUp: (_) {
          _fabAnimationController.reverse();
          _navigateToClientForm();
        },
        onTapCancel: () => _fabAnimationController.reverse(),
        child: AnimatedBuilder(
          animation: _fabAnimationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1 - (_fabAnimationController.value * 0.1),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      PlombiProColors.secondaryOrange,
                      PlombiProColors.secondaryOrangeDark,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: PlombiProColors.secondaryOrange.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Glassmorphic client card widget
class _GlassClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _GlassClientCard({
    required this.client,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: onTap,
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(),
            const SizedBox(width: 16),

            // Client info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          client.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (client.isFavorite)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          client.clientType == 'individual'
                              ? 'Particulier'
                              : 'Entreprise',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (client.email != null && client.email!.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.email_rounded,
                          size: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            client.email!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (client.phone != null && client.phone!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          client.phone!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Actions button
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white.withOpacity(0.9),
                ),
                color: PlombiProColors.primaryBlueDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'quote') {
                    context.push('/quotes/new', extra: client);
                  }
                  // TODO: Implement other actions
                },
                itemBuilder: (context) => [
                  _buildMenuItem('edit', Icons.edit_rounded, 'Éditer'),
                  _buildMenuItem('quote', Icons.description_rounded, 'Nouveau Devis'),
                  _buildMenuItem('invoice', Icons.receipt_long_rounded, 'Nouvelle Facture'),
                  const PopupMenuDivider(),
                  _buildMenuItem('delete', Icons.delete_rounded, 'Supprimer', isDestructive: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initial = client.name.isNotEmpty ? client.name[0].toUpperCase() : '?';
    final colors = [
      PlombiProColors.primaryBlue,
      PlombiProColors.secondaryOrange,
      PlombiProColors.tertiaryTeal,
      PlombiProColors.success,
    ];
    final colorIndex = client.name.hashCode % colors.length;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[colorIndex],
            colors[colorIndex].withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[colorIndex].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String text, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive ? PlombiProColors.error : Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isDestructive ? PlombiProColors.error : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
