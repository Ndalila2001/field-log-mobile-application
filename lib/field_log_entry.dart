enum SyncState { pending, synced, failed }

class FieldLogEntry {
  FieldLogEntry({
    required this.id,
    required this.species,
    required this.latitude,
    required this.longitude,
    required this.count,
    required this.notes,
    required this.photoNames,
    required this.createdAt,
    this.syncState = SyncState.pending,
  });

  final String id;
  final String species;
  final double latitude;
  final double longitude;
  final int count;
  final String notes;
  final List<String> photoNames;
  final DateTime createdAt;
  SyncState syncState;

  Map<String, dynamic> toJson() => {
    'id': id,
    'species': species,
    'latitude': latitude,
    'longitude': longitude,
    'count': count,
    'notes': notes,
    'photoNames': photoNames,
    'createdAt': createdAt.toIso8601String(),
  };
}
