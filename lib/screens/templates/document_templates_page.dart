import 'package:flutter/material.dart';
import '../../models/template.dart';
import '../../services/supabase_service.dart';

class DocumentTemplatesPage extends StatefulWidget {
  const DocumentTemplatesPage({super.key});

  @override
  State<DocumentTemplatesPage> createState() => _DocumentTemplatesPageState();
}

class _DocumentTemplatesPageState extends State<DocumentTemplatesPage> {
  bool _isLoading = true;
  List<Template> _templates = [];

  @override
  void initState() {
    super.initState();
    _fetchTemplates();
  }

  Future<void> _fetchTemplates() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final templates = await SupabaseService.getTemplates();
      if (mounted) {
        setState(() {
          _templates = templates;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des modèles: ${e.toString()}")),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modèles de Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Add new template
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                return ListTile(
                  title: Text(template.templateName),
                  subtitle: Text(template.templateType ?? 'N/A'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await SupabaseService.deleteTemplate(template.id);
                      _fetchTemplates();
                    },
                  ),
                  onTap: () {
                    // TODO: Edit template
                  },
                );
              },
            ),
    );
  }
}
