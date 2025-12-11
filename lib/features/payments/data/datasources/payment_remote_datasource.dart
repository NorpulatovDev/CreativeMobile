import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_constants.dart';
import '../models/models.dart';

abstract class PaymentRemoteDataSource {
  Future<List<Payment>> getAll();
  Future<List<Payment>> getByStudentId(int studentId);
  Future<List<Payment>> getByGroupId(int groupId);
  Future<Payment> getById(int id);
  Future<Payment> create(PaymentRequest request);
}

@LazySingleton(as: PaymentRemoteDataSource)
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio _dio;

  PaymentRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Payment>> getAll() async {
    final response = await _dio.get(ApiConstants.payments);
    return (response.data as List)
        .map((json) => Payment.fromJson(json))
        .toList();
  }

  @override
  Future<List<Payment>> getByStudentId(int studentId) async {
    final response = await _dio.get('${ApiConstants.payments}/student/$studentId');
    return (response.data as List)
        .map((json) => Payment.fromJson(json))
        .toList();
  }

  @override
  Future<List<Payment>> getByGroupId(int groupId) async {
    final response = await _dio.get('${ApiConstants.payments}/group/$groupId');
    return (response.data as List)
        .map((json) => Payment.fromJson(json))
        .toList();
  }

  @override
  Future<Payment> getById(int id) async {
    final response = await _dio.get('${ApiConstants.payments}/$id');
    return Payment.fromJson(response.data);
  }

  @override
  Future<Payment> create(PaymentRequest request) async {
    final response = await _dio.post(
      ApiConstants.payments,
      data: request.toJson(),
    );
    return Payment.fromJson(response.data);
  }
}