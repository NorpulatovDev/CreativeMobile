import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

@JsonSerializable()
class PaymentModel {
  final int id;
  final int studentId;
  final String studentName;
  final int groupId;
  final String groupName;
  final double amount;
  final String paidForMonth;
  final DateTime paidAt;

  const PaymentModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.groupId,
    required this.groupName,
    required this.amount,
    required this.paidForMonth,
    required this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);
}

@JsonSerializable()
class PaymentRequest {
  final int studentId;
  final int groupId;
  final double amount;
  final String paidForMonth;

  const PaymentRequest({
    required this.studentId,
    required this.groupId,
    required this.amount,
    required this.paidForMonth,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentRequestToJson(this);
}