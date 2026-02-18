import '../../../../core/offline/id_mapping.dart';
import '../../../../core/offline/sync_engine.dart';
import '../../../../core/offline/sync_queue.dart';
import '../models/attendance_model.dart';
import 'attendance_local_datasource.dart';
import 'attendance_remote_datasource.dart';

class AttendanceSyncHandler implements SyncOperationHandler {
  final AttendanceRemoteDataSource _remote;
  final AttendanceLocalDataSource _local;

  AttendanceSyncHandler(this._remote, this._local);

  @override
  String get entityType => 'attendance';

  @override
  Future<int?> execute(SyncOperation op, IdMappingService idMapping) async {
    switch (op.operationType) {
      case 'create':
        final payload = Map<String, dynamic>.from(op.payload!);
        // Resolve temp group ID
        if (payload.containsKey('groupId')) {
          payload['groupId'] =
              idMapping.resolveId('group', payload['groupId'] as int);
        }
        // Resolve temp student IDs in absentStudentIds
        if (payload.containsKey('absentStudentIds') &&
            payload['absentStudentIds'] != null) {
          final ids = (payload['absentStudentIds'] as List)
              .map((id) => idMapping.resolveId('student', id as int))
              .toList();
          payload['absentStudentIds'] = ids;
        }
        final request = AttendanceRequest.fromJson(payload);
        final created = await _remote.createForGroup(request);
        // Cache all returned attendance records
        await _local.cacheAll(created);
        return null; // createForGroup returns a list, not a single entity
      case 'update':
        final realId = idMapping.resolveId(entityType, op.entityId);
        final request = AttendanceUpdateRequest.fromJson(op.payload!);
        final updated = await _remote.update(realId, request);
        await _local.cacheSingle(updated);
        return null;
      default:
        throw Exception('Unknown operation type: ${op.operationType}');
    }
  }
}
