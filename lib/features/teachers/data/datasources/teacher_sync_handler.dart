import '../../../../core/offline/id_mapping.dart';
import '../../../../core/offline/sync_engine.dart';
import '../../../../core/offline/sync_queue.dart';
import '../models/teacher_model.dart';
import 'teacher_local_datasource.dart';
import 'teacher_remote_datasource.dart';

class TeacherSyncHandler implements SyncOperationHandler {
  final TeacherRemoteDataSource _remote;
  final TeacherLocalDataSource _local;

  TeacherSyncHandler(this._remote, this._local);

  @override
  String get entityType => 'teacher';

  @override
  Future<int?> execute(SyncOperation op, IdMappingService idMapping) async {
    switch (op.operationType) {
      case 'create':
        final request = TeacherRequest.fromJson(op.payload!);
        final created = await _remote.create(request);
        await _local.remove(op.entityId);
        await _local.cacheSingle(created);
        return created.id;
      case 'update':
        final realId = idMapping.resolveId(entityType, op.entityId);
        final request = TeacherRequest.fromJson(op.payload!);
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
