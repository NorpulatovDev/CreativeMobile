import 'package:hive_ce/hive.dart';

class SyncOperation {
  final String id;
  final String entityType;
  final String operationType; // 'create', 'update', 'delete'
  final int entityId;
  final Map<String, dynamic>? payload;
  final DateTime createdAt;
  int retryCount;
  String? error;

  SyncOperation({
    required this.id,
    required this.entityType,
    required this.operationType,
    required this.entityId,
    this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.error,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'entityType': entityType,
        'operationType': operationType,
        'entityId': entityId,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
        'error': error,
      };

  factory SyncOperation.fromMap(Map<dynamic, dynamic> map) => SyncOperation(
        id: map['id'] as String,
        entityType: map['entityType'] as String,
        operationType: map['operationType'] as String,
        entityId: map['entityId'] as int,
        payload: map['payload'] != null
            ? Map<String, dynamic>.from(map['payload'] as Map)
            : null,
        createdAt: DateTime.parse(map['createdAt'] as String),
        retryCount: map['retryCount'] as int? ?? 0,
        error: map['error'] as String?,
      );
}

class SyncQueue {
  static const String _boxName = 'sync_queue';
  late Box _box;

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> enqueue(SyncOperation operation) async {
    await _box.put(operation.id, operation.toMap());
  }

  List<SyncOperation> getAll() {
    final operations = <SyncOperation>[];
    for (final key in _box.keys) {
      final map = _box.get(key);
      if (map != null) {
        operations.add(SyncOperation.fromMap(Map<dynamic, dynamic>.from(map)));
      }
    }
    operations.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return operations;
  }

  int get pendingCount => _box.length;

  Future<void> remove(String operationId) async {
    await _box.delete(operationId);
  }

  Future<void> update(SyncOperation operation) async {
    await _box.put(operation.id, operation.toMap());
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
