import '../../../../core/offline/id_mapping.dart';
import '../../../../core/offline/sync_engine.dart';
import '../../../../core/offline/sync_queue.dart';
import '../models/enrollment_model.dart';
import 'enrollment_local_datasource.dart';
import 'enrollment_remote_datasource.dart';

class EnrollmentSyncHandler implements SyncOperationHandler {
  final EnrollmentRemoteDataSource _remote;
  final EnrollmentLocalDataSource _local;

  EnrollmentSyncHandler(this._remote, this._local);

  @override
  String get entityType => 'enrollment';

  @override
  Future<int?> execute(SyncOperation op, IdMappingService idMapping) async {
    switch (op.operationType) {
      case 'create':
        final payload = Map<String, dynamic>.from(op.payload!);
        final studentId =
            idMapping.resolveId('student', payload['studentId'] as int);
        final groupId =
            idMapping.resolveId('group', payload['groupId'] as int);
        final request =
            EnrollmentRequest(studentId: studentId, groupId: groupId);
        final created = await _remote.addStudentToGroup(request);
        await _local.remove(op.entityId);
        await _local.cacheSingle(created);
        return created.id;
      case 'delete':
        final payload = Map<String, dynamic>.from(op.payload!);
        final studentId =
            idMapping.resolveId('student', payload['studentId'] as int);
        final groupId =
            idMapping.resolveId('group', payload['groupId'] as int);
        await _remote.removeStudentFromGroup(studentId, groupId);
        return null;
      default:
        throw Exception('Unknown operation type: ${op.operationType}');
    }
  }
}
