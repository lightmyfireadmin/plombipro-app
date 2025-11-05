import 'package:flutter/material.dart';

class HydraulicCalculatorPage extends StatefulWidget {
  const HydraulicCalculatorPage({super.key});

  @override
  State<HydraulicCalculatorPage> createState() => _HydraulicCalculatorPageState();
}

class _HydraulicCalculatorPageState extends State<HydraulicCalculatorPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  double? _flowRate;
  double? _pipeLength;
  double? _heightDifference;

  // Calculation results
  double? _recommendedPipeDiameter;
  double? _pressureLoss;

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Placeholder for hydraulic calculations
      setState(() {
        _recommendedPipeDiameter = 25.0; // mm
        _pressureLoss = 0.5; // bar
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculateur Hydraulique'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Débit (L/min)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _flowRate = double.tryParse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Longeur de tuyau (m)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _pipeLength = double.tryParse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dénivelé (m)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _heightDifference = double.tryParse(value!),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _calculate,
                child: const Text('Calculer'),
              ),
              if (_recommendedPipeDiameter != null && _pressureLoss != null)
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Diamètre de tuyau recommandé: $_recommendedPipeDiameter mm'),
                      Text('Perte de charge: $_pressureLoss bar'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
