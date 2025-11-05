import 'package:flutter/material.dart';

class TemplateBrowserPage extends StatelessWidget {
  const TemplateBrowserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parcourir les Modèles'),
      ),
      body: const Center(
        child: Text('UI pour parcourir les 50+ modèles pré-construits'),
      ),
    );
  }
}
