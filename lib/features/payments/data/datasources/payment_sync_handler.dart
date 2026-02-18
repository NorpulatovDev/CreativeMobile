import '../../../../core/offline/id_mapping.dart';
import '../../../../core/offline/sync_engine.dart';
import '../../../../core/offline/sync_queue.dart';
import '../models/payment_model.dart';
import 'payment_local_datasource.dart';
import 'payment_remote_datasource.dart';

class PaymentSyncHandler implements SyncOperationHandler {
  final PaymentRemoteDataSource _remote;
  final PaymentLocalDataSource _local;

  PaymentSyncHandler(this._remote, this._local);

  @override
  String get entityType => 'payment';

  @override
  Future<int?> execute(SyncOperation op, IdMappingService idMapping) async {
    switch (op.operationType) {
      case 'create':
        final payload = Map<String, dynamic>.from(op.payload!);
        // Resolve temp student/group IDs
        if (payload.containsKey('studentId')) {
          payload['studentId'] =
              idMapping.resolveId('student', payload['studentId'] as int);
        }
        if (payload.containsKey('groupId')) {
          payload['groupId'] =
              idMapping.resolveId('group', payload['groupId'] as int);
        }
        final request = PaymentRequest.fromJson(payload);
        final created = await _remote.create(request);
        await _local.remove(op.entityId);
        await _local.cacheSingle(created);
        return created.id;
      case 'update':
        final realId = idMapping.resolveId(entityType, op.entityId);
        final payload = Map<String, dynamic>.from(op.payload!);
        if (payload.containsKey('studentId')) {
          payload['studentId'] =
              idMapping.resolveId('student', payload['studentId'] as int);
        }
        if (payload.containsKey('groupId')) {
          payload['groupId'] =
              idMapping.resolveId('group', payload['groupId'] as int);
        }
        final request = PaymentRequest.fromJson(payload);
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
