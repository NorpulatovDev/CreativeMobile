import 'package:json_annotation/json_annotation.dart';

part 'branch_model.g.dart';

@JsonSerializable()
class BranchModel {
  final int id;
  final String name;
  final String? address;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BranchModel({
    required this.id,
    required this.name,
    this.address,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) =>
      _$BranchModelFromJson(json);

  Map<String, dynamic> toJson() => _$BranchModelToJson(this);
}

@JsonSerializable()
class BranchRequest {
  final String name;
  final String? address;
  final String? phoneNumber;

  const BranchRequest({
    required this.name,
    this.address,
    this.phoneNumber,
  });

  factory BranchRequest.fromJson(Map<String, dynamic> json) =>
      _$BranchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BranchRequestToJson(this);
}
