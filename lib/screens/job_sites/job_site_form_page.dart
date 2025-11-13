import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/job_site.dart';
import '../../models/client.dart';
import '../../services/supabase_service.dart';
import '../../config/plombipro_colors.dart';
import '../../widgets/glassmorphic/glass_card.dart';

/// Beautiful glassmorphic job site form page
class JobSiteFormPage extends StatefulWidget {
  final String? jobSiteId;

  const JobSiteFormPage({super.key, this.jobSiteId});

  @override
  State<JobSiteFormPage> createState() => _JobSiteFormPageState();
}

class _JobSiteFormPageState extends State<JobSiteFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form fields
  String? _jobName;
  String? _address;
  String? _city;
  String? _postalCode;
  Client? _selectedClient;
  List<Client> _clients = [];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fetchClients();
    if (widget.jobSiteId != null) {
      _fetchJobSite();
    } else {
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchClients() async {
    try {
      final clients = await SupabaseService.fetchClients();
      if (mounted) {
        setState(() {
          _clients = clients;
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
      }
    }
  }

  Future<void> _fetchJobSite() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final jobSite = await SupabaseService.getJobSiteById(widget.jobSiteId!);
      if (jobSite != null) {
        setState(() {
          _jobName = jobSite.jobName;
          _address = jobSite.address;
          _city = jobSite.city;
          _postalCode = jobSite.postalCode;
          _selectedClient = _clients.firstWhere(
            (c) => c.id == jobSite.clientId,
            orElse: () => Client(
              id: null,
              userId: Supabase.instance.client.auth.currentUser!.id,
              name: 'Client Inconnu',
              email: '',
              phone: '',
              address: null,
              city: null,
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur de chargement du chantier: ${e.toString()}"),
            backgroundColor: PlombiProColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _fadeController.forward();
      }
    }
  }

  Future<void> _saveJobSite() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final newJobSite = JobSite(
          id: widget.jobSiteId ?? const Uuid().v4(),
          userId: Supabase.instance.client.auth.currentUser!.id,
          clientId: _selectedClient!.id!,
          jobName: _jobName!,
          address: _address,
          city: _city,
          postalCode: _postalCode,
          createdAt: DateTime.now(),
        );

        if (widget.jobSiteId == null) {
          await SupabaseService.addJobSite(newJobSite);
        } else {
          await SupabaseService.updateJobSite(widget.jobSiteId!, newJobSite);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Chantier enregistré avec succès'),
              backgroundColor: PlombiProColors.success,
            ),
          );
          context.pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: PlombiProColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          _buildGradientBackground(),

          // Content
          SafeArea(
            child: _isLoading
                ? _buildLoadingState()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        _buildGlassAppBar(),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildForm(),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
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

  Widget _buildLoadingState() {
    return Center(
      child: GlassContainer(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        opacity: 0.2,
        child: const CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildGlassAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Back button
          AnimatedGlassContainer(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(0),
            borderRadius: BorderRadius.circular(12),
            opacity: 0.2,
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              widget.jobSiteId == null
                  ? 'Nouveau Chantier'
                  : 'Modifier le Chantier',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Save button
          AnimatedGlassContainer(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(0),
            borderRadius: BorderRadius.circular(12),
            opacity: 0.25,
            color: PlombiProColors.success,
            onTap: _isLoading ? null : _saveJobSite,
            child: const Icon(Icons.save, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.15,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PlombiProColors.secondaryOrange.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.construction, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Informations du chantier',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Client dropdown
            _buildGlassClientDropdown(),

            const SizedBox(height: 20),

            // Job Name
            _buildGlassTextField(
              labelText: 'Nom du chantier *',
              hintText: 'ex: Rénovation salle de bain',
              initialValue: _jobName,
              prefixIcon: Icons.work,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nom de chantier';
                }
                return null;
              },
              onSaved: (value) => _jobName = value,
            ),

            const SizedBox(height: 20),

            // Address
            _buildGlassTextField(
              labelText: 'Adresse',
              hintText: '123 rue Example',
              initialValue: _address,
              prefixIcon: Icons.location_on,
              onSaved: (value) => _address = value,
            ),

            const SizedBox(height: 20),

            // City & Postal Code row
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildGlassTextField(
                    labelText: 'Code postal',
                    hintText: '75001',
                    initialValue: _postalCode,
                    prefixIcon: Icons.markunread_mailbox,
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _postalCode = value,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _buildGlassTextField(
                    labelText: 'Ville',
                    hintText: 'Paris',
                    initialValue: _city,
                    prefixIcon: Icons.location_city,
                    onSaved: (value) => _city = value,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Save button (large)
            AnimatedGlassContainer(
              width: double.infinity,
              height: 56,
              borderRadius: BorderRadius.circular(16),
              opacity: 0.25,
              color: PlombiProColors.success,
              onTap: _isLoading ? null : _saveJobSite,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    widget.jobSiteId == null
                        ? 'Créer le chantier'
                        : 'Enregistrer les modifications',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Required fields note
            Center(
              child: Text(
                '* Champs requis',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required String labelText,
    required String hintText,
    required String? initialValue,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            initialValue: initialValue,
            keyboardType: keyboardType,
            validator: validator,
            onSaved: onSaved,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: Icon(
                prefixIcon,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassClientDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Client *',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<Client>(
            value: _selectedClient,
            decoration: InputDecoration(
              hintText: 'Sélectionner un client',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ),
            dropdownColor: PlombiProColors.backgroundDark,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            items: _clients.map((Client client) {
              return DropdownMenuItem<Client>(
                value: client,
                child: Text(client.name),
              );
            }).toList(),
            onChanged: (Client? newValue) {
              setState(() {
                _selectedClient = newValue;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Veuillez sélectionner un client';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
