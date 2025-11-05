import 'package:flutter/material.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: Icon(Icons.description),
        title: Text('Devis #2024-001'),
        subtitle: Text('Client A'),
        trailing: Text('1,250€'),
      ),
    );
  }
}
