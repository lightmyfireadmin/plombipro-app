import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/database_diagnostic.dart';

/// Database Diagnostic Page
/// Helps identify database connection and RLS policy issues
class DatabaseDiagnosticPage extends StatefulWidget {
  const DatabaseDiagnosticPage({super.key});

  @override
  State<DatabaseDiagnosticPage> createState() => _DatabaseDiagnosticPageState();
}

class _DatabaseDiagnosticPageState extends State<DatabaseDiagnosticPage> {
  bool _isRunning = false;
  String _results = 'Tap "Run Diagnostics" to start';
  Map<String, dynamic>? _diagnosticData;

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
      _results = 'Running diagnostics...';
    });

    try {
      final diagnosticData = await DatabaseDiagnostic.runDiagnostics();
      final formatted = DatabaseDiagnostic.formatResults(diagnosticData);

      setState(() {
        _diagnosticData = diagnosticData;
        _results = formatted;
        _isRunning = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _results = 'ERROR: $e\n\nStack Trace:\n$stackTrace';
        _isRunning = false;
      });
    }
  }

  Future<void> _testClientCreation() async {
    setState(() {
      _isRunning = true;
      _results = 'Testing client creation...';
    });

    try {
      final result = await DatabaseDiagnostic.testClientCreation();

      final buffer = StringBuffer();
      buffer.writeln('=== CLIENT CREATION TEST ===');
      buffer.writeln('Success: ${result['success']}');

      if (result['success']) {
        buffer.writeln('Inserted ID: ${result['inserted_id']}');
        buffer.writeln('Read Back: ${result['read_back']}');
        buffer.writeln('Deleted: ${result['deleted']}');
        buffer.writeln('');
        buffer.writeln('✅ ALL CRUD OPERATIONS WORKING!');
      } else {
        buffer.writeln('Error: ${result['error']}');
        buffer.writeln('');
        buffer.writeln('Stack Trace:');
        buffer.writeln(result['stack_trace']);
      }

      setState(() {
        _results = buffer.toString();
        _isRunning = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _results = 'ERROR: $e\n\nStack Trace:\n$stackTrace';
        _isRunning = false;
      });
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _results));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyToClipboard,
            tooltip: 'Copy to clipboard',
          ),
        ],
      ),
      body: Column(
        children: [
          // Control Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? null : _runDiagnostics,
                        icon: _isRunning
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.play_arrow),
                        label: const Text('Run Full Diagnostics'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? null : _testClientCreation,
                        icon: const Icon(Icons.science),
                        label: const Text('Test Client CRUD'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Information Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This tool diagnoses database connection, RLS policies, and CRUD operations.',
                          style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results Display
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _results,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),

          // Quick Actions
          if (_diagnosticData != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Quick Analysis',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildQuickAnalysis(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAnalysis() {
    if (_diagnosticData == null) return const SizedBox.shrink();

    final auth = _diagnosticData!['authentication'] as Map?;
    final isAuthenticated = auth?['is_authenticated'] ?? false;

    final conn = _diagnosticData!['connection'] as Map?;
    final isConnected = conn?['connected'] ?? false;

    final counts = _diagnosticData!['data_counts'] as Map?;
    final clientsCount = counts?['clients'];
    final quotesCount = counts?['quotes'];

    return Column(
      children: [
        _buildStatusChip(
          'Authentication',
          isAuthenticated,
          isAuthenticated ? 'User logged in' : 'Not authenticated',
        ),
        const SizedBox(height: 8),
        _buildStatusChip(
          'Database Connection',
          isConnected,
          isConnected ? 'Connected' : 'Connection failed',
        ),
        if (clientsCount != null) ...[
          const SizedBox(height: 8),
          _buildInfoChip('Clients', '$clientsCount'),
        ],
        if (quotesCount != null) ...[
          const SizedBox(height: 8),
          _buildInfoChip('Quotes', '$quotesCount'),
        ],
      ],
    );
  }

  Widget _buildStatusChip(String label, bool isSuccess, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess ? Colors.green.shade300 : Colors.red.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green.shade900 : Colors.red.shade900,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
