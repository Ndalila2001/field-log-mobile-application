import 'package:flutter/material.dart';
import '../field_log_api.dart';
import '../field_log_entry.dart';
import '../widgets/field_log_form.dart';
import '../widgets/field_log_queue_panel.dart';
import '../widgets/sync_status_bar.dart';

class FieldLogHomePage extends StatefulWidget {
  const FieldLogHomePage({super.key});

  @override
  State<FieldLogHomePage> createState() => _FieldLogHomePageState();
}

class _FieldLogHomePageState extends State<FieldLogHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _speciesController = TextEditingController();
  final _countController = TextEditingController(text: '1');
  final _latitudeController = TextEditingController(text: '-22.5609');
  final _longitudeController = TextEditingController(text: '17.0658');
  final _notesController = TextEditingController();
  final _photoController = TextEditingController();

  final List<FieldLogEntry> _logs = [
    FieldLogEntry(
      id: 'demo-oryx',
      species: 'Oryx',
      latitude: -22.5609,
      longitude: 17.0658,
      count: 4,
      notes: 'Small herd moving east near the dry riverbed.',
      photoNames: ['oryx-track.jpg'],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    FieldLogEntry(
      id: 'demo-elephant',
      species: 'Elephant',
      latitude: -18.8792,
      longitude: 16.9278,
      count: 7,
      notes: 'Adults with calves. No visible distress.',
      photoNames: ['waterhole-01.jpg', 'calves.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
    ),
  ];

  bool _isOnline = false;
  bool _isSyncing = false;
  String _syncMessage = 'Offline mode active. Logs remain on this device.';

  int get _pendingCount =>
      _logs.where((log) => log.syncState != SyncState.synced).length;

  @override
  void dispose() {
    _speciesController.dispose();
    _countController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _notesController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  void _captureCurrentLocation() {
    setState(() {
      _latitudeController.text = '-22.5749';
      _longitudeController.text = '17.0805';
    });
  }

  Future<void> _addLog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final photoNames = _photoController.text
        .split(',')
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    final log = FieldLogEntry(
      id: 'log-${DateTime.now().microsecondsSinceEpoch}',
      species: _speciesController.text.trim(),
      latitude: double.parse(_latitudeController.text.trim()),
      longitude: double.parse(_longitudeController.text.trim()),
      count: int.parse(_countController.text.trim()),
      notes: _notesController.text.trim(),
      photoNames: photoNames,
      createdAt: DateTime.now(),
    );

    setState(() {
      _logs.insert(0, log);
      _speciesController.clear();
      _countController.text = '1';
      _notesController.clear();
      _photoController.clear();
      _syncMessage = _isOnline
          ? 'Log saved locally. Syncing to the API...'
          : 'Log saved offline and queued for end-of-shift sync.';
    });

    if (_isOnline) {
      await _syncLogs([log], successMessage: 'Online log synced to the API.');
    }
  }

  Future<void> _syncPendingLogs() async {
    if (!_isOnline) {
      setState(() {
        _syncMessage =
            'No connection available. Pending logs are safe locally.';
      });
      return;
    }

    final pendingLogs = _logs
        .where((log) => log.syncState != SyncState.synced)
        .toList();
    if (pendingLogs.isEmpty) {
      setState(() {
        _syncMessage = 'Everything is already synced.';
      });
      return;
    }

    await _syncLogs(
      pendingLogs,
      successMessage: '${pendingLogs.length} pending logs synced to the API.',
    );
  }

  Future<void> _syncLogs(
    List<FieldLogEntry> logs, {
    required String successMessage,
  }) async {
    setState(() => _isSyncing = true);

    try {
      final syncedIds = await FieldLogApi.syncLogs(logs);
      setState(() {
        for (final log in logs) {
          log.syncState = syncedIds.contains(log.id)
              ? SyncState.synced
              : SyncState.failed;
        }
        _syncMessage = syncedIds.length == logs.length
            ? successMessage
            : '${syncedIds.length} of ${logs.length} logs synced to the API.';
      });
    } catch (_) {
      setState(() {
        for (final log in logs) {
          log.syncState = SyncState.failed;
        }
        _syncMessage =
            'Sync could not reach the API. Start the Node server and try again.';
      });
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Log'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                const Icon(Icons.cloud_queue),
                const SizedBox(width: 8),
                Text('$_pendingCount pending'),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 880;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: isWide
                  ? IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(flex: 5, child: _buildLogForm()),
                          const SizedBox(width: 16),
                          Expanded(flex: 4, child: _buildQueuePanel()),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLogForm(),
                        const SizedBox(height: 16),
                        _buildQueuePanel(),
                      ],
                    ),
            );
          },
        ),
      ),
      bottomNavigationBar: SyncStatusBar(
        isOnline: _isOnline,
        message: _syncMessage,
        onConnectionChanged: (isOnline) {
          setState(() {
            _isOnline = isOnline;
            _syncMessage = _isOnline
                ? 'Connection available. Ready to sync pending logs.'
                : 'Offline mode active. Logs remain on this device.';
          });
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSyncing ? null : _syncPendingLogs,
        icon: _isSyncing
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.sync),
        label: const Text('Sync shift'),
      ),
    );
  }

  Widget _buildLogForm() {
    return FieldLogForm(
      formKey: _formKey,
      speciesController: _speciesController,
      countController: _countController,
      latitudeController: _latitudeController,
      longitudeController: _longitudeController,
      photoController: _photoController,
      notesController: _notesController,
      onCaptureLocation: _captureCurrentLocation,
      onSave: _addLog,
      requiredTextValidator: _requiredText,
      positiveIntegerValidator: _positiveInteger,
      coordinateValidator: _coordinate,
    );
  }

  Widget _buildQueuePanel() {
    return FieldLogQueuePanel(logs: _logs, pendingCount: _pendingCount);
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _positiveInteger(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Enter a positive number';
    }
    return null;
  }

  String? _coordinate(String? value) {
    if (double.tryParse(value ?? '') == null) {
      return 'Enter a valid coordinate';
    }
    return null;
  }
}
