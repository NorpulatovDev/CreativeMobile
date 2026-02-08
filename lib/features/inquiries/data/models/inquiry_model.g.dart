// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inquiry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InquiryModel _$InquiryModelFromJson(Map<String, dynamic> json) => InquiryModel(
  id: (json['id'] as num).toInt(),
  fullName: json['fullName'] as String,
  parentName: json['parentName'] as String,
  parentPhoneNumber: json['parentPhoneNumber'] as String,
  interestedCourses: json['interestedCourses'] as String?,
  status: $enumDecode(_$InquiryStatusEnumMap, json['status']),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$InquiryModelToJson(InquiryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'parentName': instance.parentName,
      'parentPhoneNumber': instance.parentPhoneNumber,
      'interestedCourses': instance.interestedCourses,
      'status': _$InquiryStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$InquiryStatusEnumMap = {
  InquiryStatus.newInquiry: 'NEW',
  InquiryStatus.contacted: 'CONTACTED',
  InquiryStatus.enrolled: 'ENROLLED',
  InquiryStatus.rejected: 'REJECTED',
};

InquiryRequest _$InquiryRequestFromJson(Map<String, dynamic> json) =>
    InquiryRequest(
      fullName: json['fullName'] as String,
      parentName: json['parentName'] as String,
      parentPhoneNumber: json['parentPhoneNumber'] as String,
      interestedCourses: json['interestedCourses'] as String?,
      status: $enumDecodeNullable(_$InquiryStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$InquiryRequestToJson(InquiryRequest instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'parentName': instance.parentName,
      'parentPhoneNumber': instance.parentPhoneNumber,
      'interestedCourses': instance.interestedCourses,
      'status': _$InquiryStatusEnumMap[instance.status],
      'notes': instance.notes,
    };
