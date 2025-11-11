/// Database Audit Runner
/// Executes the ultimate SQL audit and provides analysis
///
/// Usage: dart run scripts/run_database_audit.dart

import 'dart:io';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🔍 ULTIMATE DATABASE AUDIT');
  print('=' * 80);
  print('');

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: Platform.environment['SUPABASE_URL'] ?? '',
      anonKey: Platform.environment['SUPABASE_ANON_KEY'] ?? '',
    );

    final supabase = Supabase.instance.client;

    // Read the SQL file
    final sqlFile = File('database_audit_ultimate.sql');
    if (!await sqlFile.exists()) {
      print('❌ Error: database_audit_ultimate.sql not found!');
      exit(1);
    }

    final sqlQuery = await sqlFile.readAsString();
    print('📋 Executing ultimate audit query...\n');

    // Execute the query
    final response = await supabase.rpc('exec_sql', params: {'query': sqlQuery});

    final auditData = response as Map<String, dynamic>;

    // Parse and display results
    _displayAuditResults(auditData);

    // Save to file
    final outputFile = File('database_audit_${DateTime.now().millisecondsSinceEpoch}.json');
    await outputFile.writeAsString(JsonEncoder.withIndent('  ').convert(auditData));
    print('\n📁 Full audit saved to: ${outputFile.path}');

  } catch (e) {
    print('❌ Error executing audit: $e');
    exit(1);
  }
}

void _displayAuditResults(Map<String, dynamic> audit) {
  print('📊 DATABASE AUDIT RESULTS');
  print('=' * 80);

  // Database info
  final db = audit['database'] as Map<String, dynamic>;
  print('\n🗄️  DATABASE INFO:');
  print('   Name: ${db['name']}');
  print('   Size: ${(db['size_bytes'] / 1024 / 1024).toStringAsFixed(2)} MB');
  print('   Version: ${db['version']}');
  print('   Encoding: ${db['encoding']}');
  print('   Owner: ${db['owner']}');

  // Statistics
  final stats = audit['statistics'] as Map<String, dynamic>;
  print('\n📈 STATISTICS:');
  print('   Tables: ${stats['total_tables']}');
  print('   Columns: ${stats['total_columns']}');
  print('   Functions: ${stats['total_functions']}');
  print('   Policies: ${stats['total_policies']}');
  print('   Indexes: ${stats['total_indexes']}');
  print('   Triggers: ${stats['total_triggers']}');
  print('   Foreign Keys: ${stats['total_foreign_keys']}');
  print('   Enums: ${stats['total_enums']}');
  print('   Database Size: ${stats['database_size_mb']} MB');

  // Tables summary
  final tables = audit['tables'] as List<dynamic>;
  print('\n📋 TABLES (${tables.length}):');
  for (var table in tables) {
    final t = table as Map<String, dynamic>;
    final cols = (t['columns'] as List).length;
    final fks = (t['foreign_keys'] as List).length;
    final policies = (t['policies'] as List).length;
    final rlsEnabled = (t['rls'] as Map)['rls_enabled'] as bool;

    print('   ${t['schema']}.${t['name']}');
    print('     └─ $cols columns, $fks foreign keys, $policies policies, RLS: ${rlsEnabled ? '✅' : '❌'}');
  }

  // Functions summary
  final functions = audit['functions'] as List<dynamic>?;
  if (functions != null && functions.isNotEmpty) {
    print('\n⚡ FUNCTIONS (${functions.length}):');
    for (var func in functions) {
      final f = func as Map<String, dynamic>;
      print('   ${f['schema']}.${f['name']}(${f['arguments']})');
      print('     └─ Returns: ${f['return_type']}, Language: ${f['language']}, Volatility: ${f['volatility']}');
    }
  }

  // Enums summary
  final enums = audit['enums'] as List<dynamic>?;
  if (enums != null && enums.isNotEmpty) {
    print('\n🏷️  ENUMS (${enums.length}):');
    for (var enumType in enums) {
      final e = enumType as Map<String, dynamic>;
      final values = (e['values'] as List).join(', ');
      print('   ${e['schema']}.${e['name']}: [$values]');
    }
  }

  // Extensions summary
  final extensions = audit['extensions'] as List<dynamic>?;
  if (extensions != null && extensions.isNotEmpty) {
    print('\n🔌 EXTENSIONS (${extensions.length}):');
    for (var ext in extensions) {
      final e = ext as Map<String, dynamic>;
      print('   ${e['name']} v${e['version']} (schema: ${e['schema']})');
    }
  }

  // Security audit
  print('\n🔒 SECURITY AUDIT:');
  int rlsEnabledCount = 0;
  int rlsDisabledCount = 0;
  int totalPolicies = 0;

  for (var table in tables) {
    final t = table as Map<String, dynamic>;
    final rlsEnabled = (t['rls'] as Map)['rls_enabled'] as bool;
    final policies = (t['policies'] as List).length;

    if (rlsEnabled) {
      rlsEnabledCount++;
      totalPolicies += policies;
    } else {
      rlsDisabledCount++;
    }
  }

  print('   RLS Enabled: $rlsEnabledCount tables ✅');
  print('   RLS Disabled: $rlsDisabledCount tables ${rlsDisabledCount > 0 ? '⚠️' : '✅'}');
  print('   Total Policies: $totalPolicies');

  // Relationship analysis
  print('\n🔗 RELATIONSHIPS:');
  int totalForeignKeys = 0;
  for (var table in tables) {
    final t = table as Map<String, dynamic>;
    totalForeignKeys += (t['foreign_keys'] as List).length;
  }
  print('   Total Foreign Keys: $totalForeignKeys');
  print('   Average FKs per table: ${(totalForeignKeys / tables.length).toStringAsFixed(2)}');

  // Data integrity
  print('\n✅ DATA INTEGRITY:');
  int tablesWithPK = 0;
  int tablesWithoutPK = 0;

  for (var table in tables) {
    final t = table as Map<String, dynamic>;
    if (t['primary_key'] != null) {
      tablesWithPK++;
    } else {
      tablesWithoutPK++;
      print('   ⚠️  Table without PK: ${t['schema']}.${t['name']}');
    }
  }

  print('   Tables with Primary Keys: $tablesWithPK ✅');
  if (tablesWithoutPK > 0) {
    print('   Tables without Primary Keys: $tablesWithoutPK ⚠️');
  }

  print('\n' + '=' * 80);
  print('✨ AUDIT COMPLETE!');
  print('=' * 80);
}
