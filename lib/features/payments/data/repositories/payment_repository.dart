import 'package:injectable/injectable.dart';
import '../datasources/payment_remote_datasource.dart';
import '../models/models.dart';

abstract class PaymentRepository {
  Future<List<Payment>> getAll();
  Future<List<Payment>> getByStudentId(int studentId);
  Future<List<Payment>> getByGroupId(int groupId);
  Future<Payment> getById(int id);
  Future<Payment> create(PaymentRequest request);
}

@LazySingleton(as: PaymentRepository)
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remoteDataSource;

  PaymentRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Payment>> getAll() => _remoteDataSource.getAll();

  @override
  Future<List<Payment>> getByStudentId(int studentId) =>
      _remoteDataSource.getByStudentId(studentId);

  @override
  Future<List<Payment>> getByGroupId(int groupId) =>
      _remoteDataSource.getByGroupId(groupId);

  @override
  Future<Payment> getById(int id) => _remoteDataSource.getById(id);

  @override
  Future<Payment> create(PaymentRequest request) =>
      _remoteDataSource.create(request);
}