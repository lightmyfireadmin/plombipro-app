import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Added
import '../../models/client.dart';
import '../../services/supabase_service.dart';
import 'client_form_page.dart';
import 'client_detail_page.dart'; // Added

class ClientsListPage extends StatefulWidget {
  const ClientsListPage({super.key});

  @override
  State<ClientsListPage> createState() => _ClientsListPageState();
}

class _ClientsListPageState extends State<ClientsListPage> {
  List<Client> _clients = [];
  List<Client> _filteredClients = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchClients();
    _searchController.addListener(_filterClients);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterClients);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchClients() async {
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
          SnackBar(content: Text("Erreur de chargement des clients: ${e.toString()}")),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterClients() {
    final searchTerm = _searchController.text.toLowerCase();
    setState(() {
      _filteredClients = _clients.where((client) {
        final clientName = client.name.toLowerCase();
        final clientEmail = client.email.toLowerCase() ?? '';
        final clientPhone = client.phone.toLowerCase() ?? '';
        return clientName.contains(searchTerm) ||
               clientEmail.contains(searchTerm) ||
               clientPhone.contains(searchTerm);
      }).toList();
    });
  }

  void _navigateToClientForm({Client? client}) async {
    final result = await context.push(
      client != null ? '/clients/${client.id}' : '/clients/new',
      extra: client, // Pass the client object if editing
    );
    if (result == true && mounted) {
      _fetchClients();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Clients'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchClients,
                    child: _filteredClients.isEmpty
                        ? const Center(child: Text('Aucun client trouvé.'))
                        : ListView.builder(
                            itemCount: _filteredClients.length,
                            itemBuilder: (context, index) {
                              final client = _filteredClients[index];
                              return _ClientCard(client: client, onEdit: () => _navigateToClientForm(client: client));
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToClientForm(),
        tooltip: 'Nouveau client',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Rechercher un client...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onEdit;

  const _ClientCard({required this.client, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        onTap: () => context.push('/clients/${client.id}', extra: client),
        leading: CircleAvatar(
          child: Text(client.name.isNotEmpty ? client.name[0].toUpperCase() : '?'),
        ),
        title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(client.email!),
            Text(client.phone!),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              // TODO: Implement delete functionality
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'edit', child: Text('Éditer')),
            const PopupMenuItem<String>(value: 'quote', child: Text('Nouveau Devis')),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(value: 'delete', child: Text('Supprimer', style: TextStyle(color: Colors.red))),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
