import 'package:flutter/material.dart';
import '../../models/product_category.dart';
import '../../services/error_handler.dart';

/// Category and Tags Management Page (Phase 12)
///
/// Features:
/// - Create/Edit/Delete categories
/// - Create/Edit/Delete tags
/// - Assign icons and colors
/// - Reorder categories
/// - Search and filter
class CategoryTagsManagementPage extends StatefulWidget {
  const CategoryTagsManagementPage({super.key});

  @override
  State<CategoryTagsManagementPage> createState() =>
      _CategoryTagsManagementPageState();
}

class _CategoryTagsManagementPageState
    extends State<CategoryTagsManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ProductCategory> _categories = [];
  List<ProductTag> _tags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load from SupabaseService
      // For now, use default categories
      _categories = DefaultCategories.all;
      _tags = [];

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        context.handleError(e, customMessage: 'Erreur de chargement');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories et Tags'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.category), text: 'Catégories'),
            Tab(icon: Icon(Icons.label), text: 'Tags'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoriesTab(),
                _buildTagsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddCategoryDialog();
          } else {
            _showAddTagDialog();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? 'Catégorie' : 'Tag'),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    if (_categories.isEmpty) {
      return _buildEmptyState(
        icon: Icons.category,
        title: 'Aucune catégorie',
        message: 'Créez des catégories pour organiser vos produits',
        buttonText: 'Créer une catégorie',
        onPressed: _showAddCategoryDialog,
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _categories.length,
      onReorder: _reorderCategories,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _buildCategoryCard(category, index, key: ValueKey(category.name));
      },
    );
  }

  Widget _buildCategoryCard(ProductCategory category, int index, {Key? key}) {
    final color = category.color != null
        ? Color(int.parse(category.color!.replaceFirst('#', '0xFF')))
        : Colors.blue;

    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: category.icon != null
                ? Text(category.icon!, style: const TextStyle(fontSize: 24))
                : Icon(Icons.category, color: color),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: category.description != null
            ? Text(
                category.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditCategoryDialog(category, index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCategory(index),
            ),
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsTab() {
    if (_tags.isEmpty) {
      return _buildEmptyState(
        icon: Icons.label,
        title: 'Aucun tag',
        message: 'Créez des tags pour mieux identifier vos produits',
        buttonText: 'Créer un tag',
        onPressed: _showAddTagDialog,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tags.length,
      itemBuilder: (context, index) {
        final tag = _tags[index];
        return _buildTagCard(tag, index);
      },
    );
  }

  Widget _buildTagCard(ProductTag tag, int index) {
    final color = tag.color != null
        ? Color(int.parse(tag.color!.replaceFirst('#', '0xFF')))
        : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color),
          ),
          child: Text(
            tag.name,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditTagDialog(tag, index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTag(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  void _reorderCategories(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex--;
      }
      final category = _categories.removeAt(oldIndex);
      _categories.insert(newIndex, category);

      // Update sort order
      for (int i = 0; i < _categories.length; i++) {
        _categories[i] = _categories[i].copyWith(sortOrder: i);
      }
    });

    // TODO: Save to database
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => _CategoryFormDialog(
        onSave: (category) {
          setState(() {
            _categories.add(category);
          });
          context.showSuccess('Catégorie ajoutée');
        },
      ),
    );
  }

  void _showEditCategoryDialog(ProductCategory category, int index) {
    showDialog(
      context: context,
      builder: (context) => _CategoryFormDialog(
        category: category,
        onSave: (updatedCategory) {
          setState(() {
            _categories[index] = updatedCategory;
          });
          context.showSuccess('Catégorie modifiée');
        },
      ),
    );
  }

  void _deleteCategory(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la catégorie?'),
        content: const Text(
          'Cette action ne supprimera pas les produits associés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _categories.removeAt(index);
      });
      if (mounted) {
        context.showSuccess('Catégorie supprimée');
      }
    }
  }

  void _showAddTagDialog() {
    showDialog(
      context: context,
      builder: (context) => _TagFormDialog(
        onSave: (tag) {
          setState(() {
            _tags.add(tag);
          });
          context.showSuccess('Tag ajouté');
        },
      ),
    );
  }

  void _showEditTagDialog(ProductTag tag, int index) {
    showDialog(
      context: context,
      builder: (context) => _TagFormDialog(
        tag: tag,
        onSave: (updatedTag) {
          setState(() {
            _tags[index] = updatedTag;
          });
          context.showSuccess('Tag modifié');
        },
      ),
    );
  }

  void _deleteTag(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le tag?'),
        content: const Text(
          'Cette action ne supprimera pas les produits associés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _tags.removeAt(index);
      });
      if (mounted) {
        context.showSuccess('Tag supprimé');
      }
    }
  }
}

/// Category form dialog
class _CategoryFormDialog extends StatefulWidget {
  final ProductCategory? category;
  final Function(ProductCategory) onSave;

  const _CategoryFormDialog({
    this.category,
    required this.onSave,
  });

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String _selectedIcon = '📦';
  Color _selectedColor = Colors.blue;

  final List<String> _iconOptions = [
    '🔧', '🔥', '🚿', '⚡', '🔨', '⚙️', '📦', '🏗️', '🚰', '💧', '🌡️', '🔌'
  ];

  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
    Colors.grey,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _descriptionController =
        TextEditingController(text: widget.category?.description);

    if (widget.category?.icon != null) {
      _selectedIcon = widget.category!.icon!;
    }

    if (widget.category?.color != null) {
      try {
        _selectedColor = Color(
          int.parse(widget.category!.color!.replaceFirst('#', '0xFF')),
        );
      } catch (e) {
        _selectedColor = Colors.blue;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null
          ? 'Nouvelle catégorie'
          : 'Modifier la catégorie'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text('Icône:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _iconOptions.map((icon) {
                  final isSelected = icon == _selectedIcon;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withOpacity(0.2)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? _selectedColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(icon, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Couleur:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colorOptions.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final category = ProductCategory(
        id: widget.category?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        icon: _selectedIcon,
        color: '#${_selectedColor.value.toRadixString(16).substring(2)}',
        sortOrder: widget.category?.sortOrder,
      );

      widget.onSave(category);
      Navigator.pop(context);
    }
  }
}

/// Tag form dialog
class _TagFormDialog extends StatefulWidget {
  final ProductTag? tag;
  final Function(ProductTag) onSave;

  const _TagFormDialog({
    this.tag,
    required this.onSave,
  });

  @override
  State<_TagFormDialog> createState() => _TagFormDialogState();
}

class _TagFormDialogState extends State<_TagFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  Color _selectedColor = Colors.blue;

  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tag?.name);

    if (widget.tag?.color != null) {
      try {
        _selectedColor = Color(
          int.parse(widget.tag!.color!.replaceFirst('#', '0xFF')),
        );
      } catch (e) {
        _selectedColor = Colors.blue;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.tag == null ? 'Nouveau tag' : 'Modifier le tag'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom*',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Couleur:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorOptions.map((color) {
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Suggestions:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: DefaultCategories.tagSuggestions.map((suggestion) {
                return InkWell(
                  onTap: () {
                    _nameController.text = suggestion;
                  },
                  child: Chip(
                    label: Text(suggestion, style: const TextStyle(fontSize: 11)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final tag = ProductTag(
        id: widget.tag?.id,
        name: _nameController.text.trim(),
        color: '#${_selectedColor.value.toRadixString(16).substring(2)}',
      );

      widget.onSave(tag);
      Navigator.pop(context);
    }
  }
}
