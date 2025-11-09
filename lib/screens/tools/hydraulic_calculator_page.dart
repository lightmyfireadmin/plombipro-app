import 'package:flutter/material.dart';
import '../../services/hydraulic_calculations.dart';

class HydraulicCalculatorPage extends StatefulWidget {
  const HydraulicCalculatorPage({super.key});

  @override
  State<HydraulicCalculatorPage> createState() => _HydraulicCalculatorPageState();
}

class _HydraulicCalculatorPageState extends State<HydraulicCalculatorPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculateur Hydraulique'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Diamètre Tuyau'),
            Tab(text: 'Perte de Charge'),
            Tab(text: 'Ballon ECS'),
            Tab(text: 'Puissance Pompe'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PipeSizeCalculator(),
          PressureLossCalculator(),
          TankSizeCalculator(),
          PumpPowerCalculator(),
        ],
      ),
    );
  }
}

// ===== PIPE SIZE CALCULATOR =====
class PipeSizeCalculator extends StatefulWidget {
  const PipeSizeCalculator({super.key});

  @override
  State<PipeSizeCalculator> createState() => _PipeSizeCalculatorState();
}

class _PipeSizeCalculatorState extends State<PipeSizeCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _flowRateController = TextEditingController();
  final _maxVelocityController = TextEditingController(text: '2.0');

  PipeType _selectedPipeType = PipeType.copper;
  double? _recommendedDiameter;
  double? _actualVelocity;
  VelocityCheck? _velocityCheck;

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      final flowRate = double.parse(_flowRateController.text);
      final maxVelocity = double.parse(_maxVelocityController.text);

      setState(() {
        _recommendedDiameter = HydraulicCalculations.recommendPipeDiameter(
          flowRate: flowRate,
          maxVelocity: maxVelocity,
          pipeType: _selectedPipeType,
        );

        _actualVelocity = HydraulicCalculations.calculateVelocity(
          flowRate: flowRate,
          pipeDiameter: _recommendedDiameter!,
        );

        _velocityCheck = HydraulicCalculations.checkVelocity(_actualVelocity!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Dimensionnement de Tuyauterie',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Calcule le diamètre optimal basé sur le débit et la vitesse maximale recommandée.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Flow rate input
            TextFormField(
              controller: _flowRateController,
              decoration: const InputDecoration(
                labelText: 'Débit requis',
                suffixText: 'L/min',
                border: OutlineInputBorder(),
                helperText: 'Débit total des appareils desservis',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un débit';
                }
                final number = double.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Veuillez entrer un nombre positif';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Pipe type selection
            DropdownButtonFormField<PipeType>(
              value: _selectedPipeType,
              decoration: const InputDecoration(
                labelText: 'Type de tuyau',
                border: OutlineInputBorder(),
              ),
              items: PipeType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.description),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPipeType = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // Max velocity input
            TextFormField(
              controller: _maxVelocityController,
              decoration: const InputDecoration(
                labelText: 'Vitesse maximale',
                suffixText: 'm/s',
                border: OutlineInputBorder(),
                helperText: 'Recommandé: 2.0 m/s pour eau potable',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une vitesse';
                }
                final number = double.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Veuillez entrer un nombre positif';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Calculate button
            ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            // Results
            if (_recommendedDiameter != null) ...[
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Résultats',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Recommended diameter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Diamètre recommandé:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${_recommendedDiameter!.toStringAsFixed(0)} mm',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Actual velocity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Vitesse réelle:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${_actualVelocity!.toStringAsFixed(2)} m/s',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _velocityCheck!.isAcceptable
                                ? Colors.green
                                : Colors.orange,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Velocity check
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _velocityCheck!.isAcceptable
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _velocityCheck!.isAcceptable
                                    ? Icons.check_circle
                                    : Icons.warning,
                                  color: _velocityCheck!.isAcceptable
                                    ? Colors.green
                                    : Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _velocityCheck!.message,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_velocityCheck!.recommendation != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _velocityCheck!.recommendation!,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flowRateController.dispose();
    _maxVelocityController.dispose();
    super.dispose();
  }
}

// ===== PRESSURE LOSS CALCULATOR =====
class PressureLossCalculator extends StatefulWidget {
  const PressureLossCalculator({super.key});

  @override
  State<PressureLossCalculator> createState() => _PressureLossCalculatorState();
}

class _PressureLossCalculatorState extends State<PressureLossCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _flowRateController = TextEditingController();
  final _pipeLengthController = TextEditingController();
  final _pipeDiameterController = TextEditingController();

  PipeType _selectedPipeType = PipeType.copper;
  double? _pressureLoss;
  double? _velocity;

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      final flowRate = double.parse(_flowRateController.text);
      final pipeLength = double.parse(_pipeLengthController.text);
      final pipeDiameter = double.parse(_pipeDiameterController.text);

      final roughness = HydraulicCalculations.getRoughnessCoefficient(_selectedPipeType);

      setState(() {
        _pressureLoss = HydraulicCalculations.calculatePressureLoss(
          flowRate: flowRate,
          pipeLength: pipeLength,
          pipeDiameter: pipeDiameter,
          roughnessCoefficient: roughness,
        );

        _velocity = HydraulicCalculations.calculateVelocity(
          flowRate: flowRate,
          pipeDiameter: pipeDiameter,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Calcul de Perte de Charge',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Utilise la formule de Hazen-Williams pour calculer la perte de charge.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            TextFormField(
              controller: _flowRateController,
              decoration: const InputDecoration(
                labelText: 'Débit',
                suffixText: 'L/min',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Requis';
                if (double.tryParse(value) == null) return 'Nombre invalide';
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _pipeLengthController,
              decoration: const InputDecoration(
                labelText: 'Longueur de tuyau',
                suffixText: 'm',
                border: OutlineInputBorder(),
                helperText: 'Longueur totale incluant les coudes',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Requis';
                if (double.tryParse(value) == null) return 'Nombre invalide';
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _pipeDiameterController,
              decoration: const InputDecoration(
                labelText: 'Diamètre du tuyau',
                suffixText: 'mm',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Requis';
                if (double.tryParse(value) == null) return 'Nombre invalide';
                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<PipeType>(
              value: _selectedPipeType,
              decoration: const InputDecoration(
                labelText: 'Matériau du tuyau',
                border: OutlineInputBorder(),
              ),
              items: PipeType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPipeType = value!;
                });
              },
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            if (_pressureLoss != null) ...[
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Résultats',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Perte de charge:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${_pressureLoss!.toStringAsFixed(3)} bar',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Vitesse d\'écoulement:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${_velocity!.toStringAsFixed(2)} m/s',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flowRateController.dispose();
    _pipeLengthController.dispose();
    _pipeDiameterController.dispose();
    super.dispose();
  }
}

// ===== TANK SIZE CALCULATOR =====
class TankSizeCalculator extends StatefulWidget {
  const TankSizeCalculator({super.key});

  @override
  State<TankSizeCalculator> createState() => _TankSizeCalculatorState();
}

class _TankSizeCalculatorState extends State<TankSizeCalculator> {
  final _formKey = GlobalKey<FormState>();
  int _numberOfPeople = 4;
  UsagePattern _usagePattern = UsagePattern.medium;
  int? _recommendedSize;

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _recommendedSize = HydraulicCalculations.calculateTankSize(
          numberOfPeople: _numberOfPeople,
          usagePattern: _usagePattern,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.water_drop, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Dimensionnement Ballon ECS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Calcule la capacité de ballon d\'eau chaude sanitaire basée sur le nombre d\'occupants et l\'usage.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Nombre de personnes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            Slider(
              value: _numberOfPeople.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$_numberOfPeople personnes',
              onChanged: (value) {
                setState(() {
                  _numberOfPeople = value.toInt();
                });
              },
            ),

            Text(
              '$_numberOfPeople ${_numberOfPeople > 1 ? "personnes" : "personne"}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            const Text(
              'Type d\'usage',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            ...UsagePattern.values.map((pattern) {
              return RadioListTile<UsagePattern>(
                title: Text(pattern.displayName),
                subtitle: Text(pattern.description),
                value: pattern,
                groupValue: _usagePattern,
                onChanged: (value) {
                  setState(() {
                    _usagePattern = value!;
                  });
                },
              );
            }).toList(),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            if (_recommendedSize != null) ...[
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.water_drop,
                        size: 48,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Capacité recommandée',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_recommendedSize litres',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ===== PUMP POWER CALCULATOR =====
class PumpPowerCalculator extends StatefulWidget {
  const PumpPowerCalculator({super.key});

  @override
  State<PumpPowerCalculator> createState() => _PumpPowerCalculatorState();
}

class _PumpPowerCalculatorState extends State<PumpPowerCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _flowRateController = TextEditingController();
  final _totalHeadController = TextEditingController();
  final _efficiencyController = TextEditingController(text: '70');

  double? _requiredPower;

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      final flowRate = double.parse(_flowRateController.text);
      final totalHead = double.parse(_totalHeadController.text);
      final efficiency = double.parse(_efficiencyController.text) / 100;

      setState(() {
        _requiredPower = HydraulicCalculations.calculatePumpPower(
          flowRate: flowRate,
          totalHead: totalHead,
          efficiency: efficiency,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.power, color: Colors.purple),
                        SizedBox(width: 8),
                        Text(
                          'Puissance Pompe Requise',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Calcule la puissance nécessaire basée sur le débit et la hauteur manométrique totale.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            TextFormField(
              controller: _flowRateController,
              decoration: const InputDecoration(
                labelText: 'Débit requis',
                suffixText: 'L/min',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Requis';
                if (double.tryParse(value) == null) return 'Nombre invalide';
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _totalHeadController,
              decoration: const InputDecoration(
                labelText: 'Hauteur manométrique totale (HMT)',
                suffixText: 'm',
                border: OutlineInputBorder(),
                helperText: 'Élévation + pertes de charge',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Requis';
                if (double.tryParse(value) == null) return 'Nombre invalide';
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _efficiencyController,
              decoration: const InputDecoration(
                labelText: 'Rendement de la pompe',
                suffixText: '%',
                border: OutlineInputBorder(),
                helperText: 'Typique: 70% (pompes standard)',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Requis';
                final number = double.tryParse(value);
                if (number == null || number <= 0 || number > 100) {
                  return 'Entre 1 et 100';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            if (_requiredPower != null) ...[
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Résultats',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Puissance requise:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${_requiredPower!.toStringAsFixed(0)} W',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'En kilowatts:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${(_requiredPower! / 1000).toStringAsFixed(2)} kW',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flowRateController.dispose();
    _totalHeadController.dispose();
    _efficiencyController.dispose();
    super.dispose();
  }
}
