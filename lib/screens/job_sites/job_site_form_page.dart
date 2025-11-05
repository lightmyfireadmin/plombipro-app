import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/job_site.dart';
import '../../models/client.dart';
import '../../services/supabase_service.dart';

class JobSiteFormPage extends StatefulWidget {
  final String? jobSiteId;

  const JobSiteFormPage({super.key, this.jobSiteId});

  @override
  State<JobSiteFormPage> createState() => _JobSiteFormPageState();
}

class _JobSiteFormPageState extends State<JobSiteFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form fields
  String? _jobName;
  String? _address;
  Client? _selectedClient;
  List<Client> _clients = [];

  @override
  void initState() {
    super.initState();
    _fetchClients();
    if (widget.jobSiteId != null) {
      _fetchJobSite();
    }
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
          SnackBar(content: Text("Erreur de chargement des clients: ${e.toString()}")),
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
          _selectedClient = _clients.firstWhere((c) => c.id == jobSite.clientId, orElse: () => Client(id: null, userId: Supabase.instance.client.auth.currentUser!.id, name: 'Client Inconnu', email: '', phone: '', address: null, city: null));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement du chantier: ${e.toString()}")),
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

  Future<void> _saveJobSite() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final newJobSite = JobSite(
          id: widget.jobSiteId ?? Uuid().v4(),
          userId: Supabase.instance.client.auth.currentUser!.id,
          clientId: _selectedClient!.id!,
          jobName: _jobName!,
          address: _address,
          createdAt: DateTime.now(),
        );

        if (widget.jobSiteId == null) {
          await SupabaseService.addJobSite(newJobSite);
        } else {
          await SupabaseService.updateJobSite(widget.jobSiteId!, newJobSite);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chantier enregistré avec succès')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}')),
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
      appBar: AppBar(
        title: Text(widget.jobSiteId == null ? 'Nouveau Chantier' : 'Modifier le Chantier'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveJobSite,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<Client>(
                      initialValue: _selectedClient,
                      decoration: const InputDecoration(labelText: 'Client'),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _jobName,
                      decoration: const InputDecoration(labelText: 'Nom du chantier'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nom de chantier';
                        }
                        return null;
                      },
                      onSaved: (value) => _jobName = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _address,
                      decoration: const InputDecoration(labelText: 'Adresse'),
                      onSaved: (value) => _address = value,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
