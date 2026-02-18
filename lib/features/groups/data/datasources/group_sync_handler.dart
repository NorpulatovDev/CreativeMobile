import '../../../../core/offline/id_mapping.dart';
import '../../../../core/offline/sync_engine.dart';
import '../../../../core/offline/sync_queue.dart';
import '../models/group_model.dart';
import 'group_local_datasource.dart';
import 'group_remote_datasource.dart';

class GroupSyncHandler implements SyncOperationHandler {
  final GroupRemoteDataSource _remote;
  final GroupLocalDataSource _local;

  GroupSyncHandler(this._remote, this._local);

  @override
  String get entityType => 'group';

  @override
  Future<int?> execute(SyncOperation op, IdMappingService idMapping) async {
    switch (op.operationType) {
      case 'create':
        final payload = Map<String, dynamic>.from(op.payload!);
        // Resolve temp teacher ID at sync time
        if (payload.containsKey('teacherId')) {
          payload['teacherId'] =
              idMapping.resolveId('teacher', payload['teacherId'] as int);
        }
        final request = GroupRequest.fromJson(payload);
        final created = await _remote.create(request);
        await _local.remove(op.entityId);
        await _local.cacheSingle(created);
        return created.id;
      case 'update':
        final realId = idMapping.resolveId(entityType, op.entityId);
        final payload = Map<String, dynamic>.from(op.payload!);
        if (payload.containsKey('teacherId')) {
          payload['teacherId'] =
              idMapping.resolveId('teacher', payload['teacherId'] as int);
        }
        final request = GroupRequest.fromJson(payload);
        final updated = await _remote.update(realId, request);
        await _local.cacheSingle(updated);
        return null;
      case 'delete':
        final realId = idMapping.resolveId(entityType, op.entityId);
        await _remote.delete(realId);
        await _local.remove(op.entityId);
        return null;
      default:
        throw Exception('Unknown operation type: ${op.operationType}');
    }
  }
}
