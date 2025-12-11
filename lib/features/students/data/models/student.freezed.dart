// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Student _$StudentFromJson(Map<String, dynamic> json) {
  return _Student.fromJson(json);
}

/// @nodoc
mixin _$Student {
  int get id => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get parentName => throw _privateConstructorUsedError;
  String get parentPhoneNumber => throw _privateConstructorUsedError;
  bool get smsLinked => throw _privateConstructorUsedError;
  String get smsLinkCode => throw _privateConstructorUsedError;
  double get totalPaid => throw _privateConstructorUsedError;
  int? get activeGroupId => throw _privateConstructorUsedError;
  String? get activeGroupName => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Student to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentCopyWith<Student> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentCopyWith<$Res> {
  factory $StudentCopyWith(Student value, $Res Function(Student) then) =
      _$StudentCopyWithImpl<$Res, Student>;
  @useResult
  $Res call({
    int id,
    String fullName,
    String parentName,
    String parentPhoneNumber,
    bool smsLinked,
    String smsLinkCode,
    double totalPaid,
    int? activeGroupId,
    String? activeGroupName,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$StudentCopyWithImpl<$Res, $Val extends Student>
    implements $StudentCopyWith<$Res> {
  _$StudentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? parentName = null,
    Object? parentPhoneNumber = null,
    Object? smsLinked = null,
    Object? smsLinkCode = null,
    Object? totalPaid = null,
    Object? activeGroupId = freezed,
    Object? activeGroupName = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            parentName: null == parentName
                ? _value.parentName
                : parentName // ignore: cast_nullable_to_non_nullable
                      as String,
            parentPhoneNumber: null == parentPhoneNumber
                ? _value.parentPhoneNumber
                : parentPhoneNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            smsLinked: null == smsLinked
                ? _value.smsLinked
                : smsLinked // ignore: cast_nullable_to_non_nullable
                      as bool,
            smsLinkCode: null == smsLinkCode
                ? _value.smsLinkCode
                : smsLinkCode // ignore: cast_nullable_to_non_nullable
                      as String,
            totalPaid: null == totalPaid
                ? _value.totalPaid
                : totalPaid // ignore: cast_nullable_to_non_nullable
                      as double,
            activeGroupId: freezed == activeGroupId
                ? _value.activeGroupId
                : activeGroupId // ignore: cast_nullable_to_non_nullable
                      as int?,
            activeGroupName: freezed == activeGroupName
                ? _value.activeGroupName
                : activeGroupName // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentImplCopyWith<$Res> implements $StudentCopyWith<$Res> {
  factory _$$StudentImplCopyWith(
    _$StudentImpl value,
    $Res Function(_$StudentImpl) then,
  ) = __$$StudentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String fullName,
    String parentName,
    String parentPhoneNumber,
    bool smsLinked,
    String smsLinkCode,
    double totalPaid,
    int? activeGroupId,
    String? activeGroupName,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$StudentImplCopyWithImpl<$Res>
    extends _$StudentCopyWithImpl<$Res, _$StudentImpl>
    implements _$$StudentImplCopyWith<$Res> {
  __$$StudentImplCopyWithImpl(
    _$StudentImpl _value,
    $Res Function(_$StudentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? parentName = null,
    Object? parentPhoneNumber = null,
    Object? smsLinked = null,
    Object? smsLinkCode = null,
    Object? totalPaid = null,
    Object? activeGroupId = freezed,
    Object? activeGroupName = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$StudentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        parentName: null == parentName
            ? _value.parentName
            : parentName // ignore: cast_nullable_to_non_nullable
                  as String,
        parentPhoneNumber: null == parentPhoneNumber
            ? _value.parentPhoneNumber
            : parentPhoneNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        smsLinked: null == smsLinked
            ? _value.smsLinked
            : smsLinked // ignore: cast_nullable_to_non_nullable
                  as bool,
        smsLinkCode: null == smsLinkCode
            ? _value.smsLinkCode
            : smsLinkCode // ignore: cast_nullable_to_non_nullable
                  as String,
        totalPaid: null == totalPaid
            ? _value.totalPaid
            : totalPaid // ignore: cast_nullable_to_non_nullable
                  as double,
        activeGroupId: freezed == activeGroupId
            ? _value.activeGroupId
            : activeGroupId // ignore: cast_nullable_to_non_nullable
                  as int?,
        activeGroupName: freezed == activeGroupName
            ? _value.activeGroupName
            : activeGroupName // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentImpl implements _Student {
  const _$StudentImpl({
    required this.id,
    required this.fullName,
    required this.parentName,
    required this.parentPhoneNumber,
    required this.smsLinked,
    required this.smsLinkCode,
    required this.totalPaid,
    this.activeGroupId,
    this.activeGroupName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$StudentImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentImplFromJson(json);

  @override
  final int id;
  @override
  final String fullName;
  @override
  final String parentName;
  @override
  final String parentPhoneNumber;
  @override
  final bool smsLinked;
  @override
  final String smsLinkCode;
  @override
  final double totalPaid;
  @override
  final int? activeGroupId;
  @override
  final String? activeGroupName;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Student(id: $id, fullName: $fullName, parentName: $parentName, parentPhoneNumber: $parentPhoneNumber, smsLinked: $smsLinked, smsLinkCode: $smsLinkCode, totalPaid: $totalPaid, activeGroupId: $activeGroupId, activeGroupName: $activeGroupName, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.parentName, parentName) ||
                other.parentName == parentName) &&
            (identical(other.parentPhoneNumber, parentPhoneNumber) ||
                other.parentPhoneNumber == parentPhoneNumber) &&
            (identical(other.smsLinked, smsLinked) ||
                other.smsLinked == smsLinked) &&
            (identical(other.smsLinkCode, smsLinkCode) ||
                other.smsLinkCode == smsLinkCode) &&
            (identical(other.totalPaid, totalPaid) ||
                other.totalPaid == totalPaid) &&
            (identical(other.activeGroupId, activeGroupId) ||
                other.activeGroupId == activeGroupId) &&
            (identical(other.activeGroupName, activeGroupName) ||
                other.activeGroupName == activeGroupName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    fullName,
    parentName,
    parentPhoneNumber,
    smsLinked,
    smsLinkCode,
    totalPaid,
    activeGroupId,
    activeGroupName,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentImplCopyWith<_$StudentImpl> get copyWith =>
      __$$StudentImplCopyWithImpl<_$StudentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentImplToJson(this);
  }
}

abstract class _Student implements Student {
  const factory _Student({
    required final int id,
    required final String fullName,
    required final String parentName,
    required final String parentPhoneNumber,
    required final bool smsLinked,
    required final String smsLinkCode,
    required final double totalPaid,
    final int? activeGroupId,
    final String? activeGroupName,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$StudentImpl;

  factory _Student.fromJson(Map<String, dynamic> json) = _$StudentImpl.fromJson;

  @override
  int get id;
  @override
  String get fullName;
  @override
  String get parentName;
  @override
  String get parentPhoneNumber;
  @override
  bool get smsLinked;
  @override
  String get smsLinkCode;
  @override
  double get totalPaid;
  @override
  int? get activeGroupId;
  @override
  String? get activeGroupName;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentImplCopyWith<_$StudentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
