import 'package:flutter/material.dart';

class SyncStatusBar extends StatelessWidget {
  const SyncStatusBar({
    super.key,
    required this.isOnline,
    required this.message,
    required this.onConnectionChanged,
  });

  final bool isOnline;
  final String message;
  final ValueChanged<bool> onConnectionChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Row(
        children: [
          Icon(
            isOnline ? Icons.signal_wifi_4_bar : Icons.signal_wifi_off,
            color: isOnline ? colorScheme.primary : colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
          const SizedBox(width: 12),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                icon: Icon(Icons.wifi_off),
                label: Text('Offline'),
              ),
              ButtonSegment(
                value: true,
                icon: Icon(Icons.wifi),
                label: Text('Online'),
              ),
            ],
            selected: {isOnline},
            onSelectionChanged: (selection) {
              onConnectionChanged(selection.first);
            },
          ),
        ],
      ),
    );
  }
}
