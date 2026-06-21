import 'package:json_annotation/json_annotation.dart';

part 'inquiry_model.g.dart';

enum InquiryStatus {
  @JsonValue('NEW')
  newInquiry,
  @JsonValue('CONTACTED')
  contacted,
}

@JsonSerializable()
class InquiryModel {
  final int id;
  final String fullName;
  final String parentName;
  final String parentPhoneNumber;
  final int? inquiryGroupId;
  final String? inquiryGroupName;
  final InquiryStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InquiryModel({
    required this.id,
    required this.fullName,
    required this.parentName,
    required this.parentPhoneNumber,
    this.inquiryGroupId,
    this.inquiryGroupName,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InquiryModel.fromJson(Map<String, dynamic> json) =>
      _$InquiryModelFromJson(json);

  Map<String, dynamic> toJson() => _$InquiryModelToJson(this);
}

@JsonSerializable()
class InquiryRequest {
  final String fullName;
  final String parentName;
  final String parentPhoneNumber;
  final int inquiryGroupId;
  final InquiryStatus? status;
  final String? notes;

  const InquiryRequest({
    required this.fullName,
    required this.parentName,
    required this.parentPhoneNumber,
    required this.inquiryGroupId,
    this.status,
    this.notes,
  });

  factory InquiryRequest.fromJson(Map<String, dynamic> json) =>
      _$InquiryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$InquiryRequestToJson(this);
}
