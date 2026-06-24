import 'package:flutter/material.dart';

import '../field_log_entry.dart';

class LogCard extends StatelessWidget {
  const LogCard({super.key, required this.log});

  final FieldLogEntry log;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (log.syncState) {
      SyncState.pending => (
        Icons.schedule,
        'Pending',
        Theme.of(context).colorScheme.tertiary,
      ),
      SyncState.synced => (
        Icons.cloud_done,
        'Synced',
        Theme.of(context).colorScheme.primary,
      ),
      SyncState.failed => (
        Icons.error_outline,
        'Retry',
        Theme.of(context).colorScheme.error,
      ),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    log.species,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  avatar: Icon(icon, color: color, size: 18),
                  label: Text(label),
                  side: BorderSide(color: color.withValues(alpha: 0.35)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('${log.count} sighted at ${_formatCoordinate(log)}'),
            const SizedBox(height: 8),
            Text(log.notes),
            if (log.photoNames.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: log.photoNames
                    .map(
                      (name) => Chip(
                        visualDensity: VisualDensity.compact,
                        avatar: const Icon(Icons.image, size: 16),
                        label: Text(name),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCoordinate(FieldLogEntry log) {
    return '${log.latitude.toStringAsFixed(4)}, ${log.longitude.toStringAsFixed(4)}';
  }
}
