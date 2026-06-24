import 'package:flutter/material.dart';

import '../field_log_entry.dart';
import 'log_card.dart';
import 'metric_tile.dart';

class FieldLogQueuePanel extends StatelessWidget {
  const FieldLogQueuePanel({
    super.key,
    required this.logs,
    required this.pendingCount,
  });

  final List<FieldLogEntry> logs;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final syncedCount = logs
        .where((log) => log.syncState == SyncState.synced)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                MetricTile(
                  label: 'Total',
                  value: '${logs.length}',
                  icon: Icons.assignment,
                ),
                MetricTile(
                  label: 'Pending',
                  value: '$pendingCount',
                  icon: Icons.pending_actions,
                ),
                MetricTile(
                  label: 'Synced',
                  value: '$syncedCount',
                  icon: Icons.cloud_done,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Shift queue', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...logs.map((log) => LogCard(log: log)),
      ],
    );
  }
}
