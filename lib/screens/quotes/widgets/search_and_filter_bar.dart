import 'package:flutter/material.dart';

class SearchAndFilterBar extends StatelessWidget {
  const SearchAndFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher par client ou numéro',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Chip(label: Text('Tous')),
                Chip(label: Text('Brouillon')),
                Chip(label: Text('Envoyés')),
                Chip(label: Text('Acceptés')),
                Chip(label: Text('Rejetés')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
