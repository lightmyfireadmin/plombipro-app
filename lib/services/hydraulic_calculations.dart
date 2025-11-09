import 'dart:math';

/// Hydraulic calculations service for plumbing applications
/// Uses industry-standard formulas for accurate results
class HydraulicCalculations {
  // ===== PIPE SIZING CALCULATIONS =====

  /// Calculate recommended pipe diameter based on flow rate
  /// Uses velocity limits to determine appropriate pipe size
  ///
  /// Parameters:
  /// - flowRate: Flow rate in liters per minute (L/min)
  /// - maxVelocity: Maximum allowed velocity in m/s (default: 2.0 for potable water)
  /// - pipeType: Type of pipe material (affects standard sizes)
  ///
  /// Returns: Recommended pipe diameter in mm
  static double recommendPipeDiameter({
    required double flowRate,
    double maxVelocity = 2.0,
    PipeType pipeType = PipeType.copper,
  }) {
    // Convert flow rate from L/min to m³/s
    final Q = flowRate / 60000.0;

    // Calculate required area: A = Q / V
    final requiredArea = Q / maxVelocity;

    // Calculate diameter: D = sqrt(4 * A / π)
    final calculatedDiameter = sqrt((4 * requiredArea) / pi) * 1000; // Convert to mm

    // Round up to nearest standard pipe size
    return _roundToStandardPipeSize(calculatedDiameter, pipeType);
  }

  /// Round diameter to nearest standard pipe size
  static double _roundToStandardPipeSize(double diameter, PipeType pipeType) {
    final standardSizes = _getStandardSizes(pipeType);

    // Find the smallest standard size that meets or exceeds the calculated diameter
    for (final size in standardSizes) {
      if (size >= diameter) {
        return size;
      }
    }

    // If calculated diameter exceeds all standard sizes, return the largest
    return standardSizes.last;
  }

  /// Get standard pipe sizes for different pipe types
  static List<double> _getStandardSizes(PipeType pipeType) {
    switch (pipeType) {
      case PipeType.copper:
        return [10, 12, 14, 16, 18, 22, 28, 35, 42, 54, 64, 76, 108];
      case PipeType.pvc:
        return [12, 16, 20, 25, 32, 40, 50, 63, 75, 90, 110, 125, 160, 200, 250];
      case PipeType.per:
        return [12, 16, 20, 25, 32, 40, 50, 63, 75, 90, 110];
      case PipeType.multicouche:
        return [12, 14, 16, 20, 26, 32, 40, 50, 63];
    }
  }

  // ===== PRESSURE LOSS CALCULATIONS =====

  /// Calculate pressure loss using Hazen-Williams formula
  /// This is the industry standard for water distribution systems
  ///
  /// Parameters:
  /// - flowRate: Flow rate in L/min
  /// - pipeLength: Pipe length in meters
  /// - pipeDiameter: Internal diameter in mm
  /// - roughnessCoefficient: Hazen-Williams C coefficient
  ///
  /// Returns: Pressure loss in bar
  static double calculatePressureLoss({
    required double flowRate,
    required double pipeLength,
    required double pipeDiameter,
    double roughnessCoefficient = 130.0,
  }) {
    // Convert units
    final Q = flowRate / 60000.0; // L/min to m³/s
    final D = pipeDiameter / 1000.0; // mm to m
    final L = pipeLength; // already in meters
    final C = roughnessCoefficient;

    // Hazen-Williams formula:
    // hL = (10.67 * L * Q^1.852) / (C^1.852 * D^4.87)
    // where hL is head loss in meters

    final headLossMeters = (10.67 * L * pow(Q, 1.852)) /
        (pow(C, 1.852) * pow(D, 4.87));

    // Convert head loss to pressure loss
    // 1 meter of water column = 0.0980665 bar
    final pressureLossBar = headLossMeters * 0.0980665;

    return pressureLossBar;
  }

  /// Get Hazen-Williams roughness coefficient for different materials
  static double getRoughnessCoefficient(PipeType pipeType) {
    switch (pipeType) {
      case PipeType.copper:
        return 130.0; // Smooth copper pipe
      case PipeType.pvc:
        return 150.0; // Very smooth PVC
      case PipeType.per:
        return 140.0; // Smooth PER
      case PipeType.multicouche:
        return 140.0; // Smooth multilayer
    }
  }

  // ===== VELOCITY CALCULATIONS =====

  /// Calculate flow velocity in pipe
  ///
  /// Parameters:
  /// - flowRate: Flow rate in L/min
  /// - pipeDiameter: Internal diameter in mm
  ///
  /// Returns: Velocity in m/s
  static double calculateVelocity({
    required double flowRate,
    required double pipeDiameter,
  }) {
    // Convert units
    final Q = flowRate / 60000.0; // L/min to m³/s
    final D = pipeDiameter / 1000.0; // mm to m

    // Calculate cross-sectional area
    final area = pi * pow(D / 2, 2); // m²

    // Calculate velocity: V = Q / A
    final velocity = Q / area; // m/s

    return velocity;
  }

  /// Check if velocity is within acceptable limits
  /// Returns recommendation object
  static VelocityCheck checkVelocity(double velocity) {
    if (velocity < 0.5) {
      return VelocityCheck(
        isAcceptable: false,
        message: 'Vitesse trop faible - risque de sédimentation',
        recommendation: 'Réduire le diamètre du tuyau',
      );
    } else if (velocity > 2.5) {
      return VelocityCheck(
        isAcceptable: false,
        message: 'Vitesse trop élevée - risque de bruit et d\'érosion',
        recommendation: 'Augmenter le diamètre du tuyau',
      );
    } else if (velocity > 2.0) {
      return VelocityCheck(
        isAcceptable: true,
        message: 'Vitesse acceptable mais élevée',
        recommendation: 'Considérer un diamètre supérieur pour plus de confort',
      );
    } else {
      return VelocityCheck(
        isAcceptable: true,
        message: 'Vitesse optimale',
        recommendation: null,
      );
    }
  }

  // ===== TANK SIZING =====

  /// Calculate hot water tank size based on usage
  ///
  /// Parameters:
  /// - numberOfPeople: Number of people in household
  /// - usagePattern: Light, medium, or heavy usage
  ///
  /// Returns: Recommended tank capacity in liters
  static int calculateTankSize({
    required int numberOfPeople,
    UsagePattern usagePattern = UsagePattern.medium,
  }) {
    // Base consumption per person (liters/day at 60°C)
    final baseConsumption = {
      UsagePattern.light: 30,
      UsagePattern.medium: 50,
      UsagePattern.heavy: 70,
    };

    final dailyConsumption = numberOfPeople * baseConsumption[usagePattern]!;

    // Standard tank sizes in liters
    final standardSizes = [50, 75, 100, 150, 200, 250, 300, 400, 500];

    // Find the smallest tank that covers daily consumption
    for (final size in standardSizes) {
      if (size >= dailyConsumption) {
        return size;
      }
    }

    return standardSizes.last;
  }

  // ===== PUMP SIZING =====

  /// Calculate required pump power
  ///
  /// Parameters:
  /// - flowRate: Required flow rate in L/min
  /// - totalHead: Total head (pressure + elevation) in meters
  /// - efficiency: Pump efficiency (0.0 - 1.0, default: 0.7)
  ///
  /// Returns: Required pump power in Watts
  static double calculatePumpPower({
    required double flowRate,
    required double totalHead,
    double efficiency = 0.7,
  }) {
    // Convert flow rate to m³/s
    final Q = flowRate / 60000.0;

    // Hydraulic power: P = ρ * g * Q * H
    // where:
    // ρ = water density (1000 kg/m³)
    // g = gravity (9.81 m/s²)
    // Q = flow rate (m³/s)
    // H = total head (m)

    final hydraulicPower = 1000 * 9.81 * Q * totalHead;

    // Actual power needed considering efficiency
    final requiredPower = hydraulicPower / efficiency;

    return requiredPower;
  }

  // ===== EXPANSION VESSEL SIZING =====

  /// Calculate expansion vessel size for heating systems
  ///
  /// Parameters:
  /// - systemVolume: Total water volume in system (liters)
  /// - maxTemperature: Maximum system temperature (°C)
  /// - initialTemperature: Initial fill temperature (°C, default: 15)
  /// - maxPressure: Maximum system pressure (bar)
  /// - initialPressure: Initial fill pressure (bar)
  ///
  /// Returns: Minimum expansion vessel size in liters
  static double calculateExpansionVesselSize({
    required double systemVolume,
    required double maxTemperature,
    double initialTemperature = 15.0,
    required double maxPressure,
    required double initialPressure,
  }) {
    // Calculate expansion coefficient for water
    // Approximation: e = 0.0002 * ΔT (for water)
    final temperatureDifference = maxTemperature - initialTemperature;
    final expansionCoefficient = 0.0002 * temperatureDifference;

    // Calculate expansion volume
    final expansionVolume = systemVolume * expansionCoefficient;

    // Calculate acceptance factor
    final acceptanceFactor = (maxPressure - initialPressure) / (maxPressure + 1);

    // Calculate required vessel size
    final vesselSize = expansionVolume / acceptanceFactor;

    // Add 25% safety margin
    final vesselSizeWithMargin = vesselSize * 1.25;

    return vesselSizeWithMargin;
  }

  // ===== DRAINAGE CALCULATIONS =====

  /// Calculate drainage pipe size based on flow and slope
  ///
  /// Parameters:
  /// - flowRate: Peak flow rate in L/s
  /// - slope: Pipe slope in % (minimum 1%)
  ///
  /// Returns: Minimum drainage pipe diameter in mm
  static int calculateDrainagePipeSize({
    required double flowRate,
    required double slope,
  }) {
    // Ensure minimum slope
    final effectiveSlope = max(slope, 1.0);

    // Manning's formula for partially full pipes
    // For drainage, assume pipe is 70% full for safety
    final fillRatio = 0.7;

    // Standard drainage pipe sizes
    final drainageSizes = [40, 50, 63, 75, 90, 110, 125, 160, 200, 250, 315];

    // Simplified sizing based on flow rate and slope
    // Higher flow or lower slope requires larger pipe
    final sizeIndex = (flowRate / sqrt(effectiveSlope / 100)).round();
    final index = min(sizeIndex, drainageSizes.length - 1);

    return drainageSizes[max(0, index)];
  }
}

// ===== ENUMS AND HELPER CLASSES =====

enum PipeType {
  copper,
  pvc,
  per,
  multicouche,
}

enum UsagePattern {
  light,
  medium,
  heavy,
}

class VelocityCheck {
  final bool isAcceptable;
  final String message;
  final String? recommendation;

  VelocityCheck({
    required this.isAcceptable,
    required this.message,
    this.recommendation,
  });
}

// ===== EXTENSION FOR PIPE TYPE =====

extension PipeTypeExtension on PipeType {
  String get displayName {
    switch (this) {
      case PipeType.copper:
        return 'Cuivre';
      case PipeType.pvc:
        return 'PVC';
      case PipeType.per:
        return 'PER';
      case PipeType.multicouche:
        return 'Multicouche';
    }
  }

  String get description {
    switch (this) {
      case PipeType.copper:
        return 'Cuivre - Traditionnel, durable';
      case PipeType.pvc:
        return 'PVC - Économique, évacuation';
      case PipeType.per:
        return 'PER - Souple, résistant';
      case PipeType.multicouche:
        return 'Multicouche - Moderne, performant';
    }
  }
}

extension UsagePatternExtension on UsagePattern {
  String get displayName {
    switch (this) {
      case UsagePattern.light:
        return 'Léger';
      case UsagePattern.medium:
        return 'Moyen';
      case UsagePattern.heavy:
        return 'Intensif';
    }
  }

  String get description {
    switch (this) {
      case UsagePattern.light:
        return '1-2 douches/jour, peu de bain';
      case UsagePattern.medium:
        return '2-3 douches/jour, bain occasionnel';
      case UsagePattern.heavy:
        return 'Plusieurs douches/bains par jour';
    }
  }
}
