// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StudentRequest _$StudentRequestFromJson(Map<String, dynamic> json) {
  return _StudentRequest.fromJson(json);
}

/// @nodoc
mixin _$StudentRequest {
  String get fullName => throw _privateConstructorUsedError;
  String get parentName => throw _privateConstructorUsedError;
  String get parentPhoneNumber => throw _privateConstructorUsedError;
  int? get activeGroupId => throw _privateConstructorUsedError;

  /// Serializes this StudentRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentRequestCopyWith<StudentRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentRequestCopyWith<$Res> {
  factory $StudentRequestCopyWith(
    StudentRequest value,
    $Res Function(StudentRequest) then,
  ) = _$StudentRequestCopyWithImpl<$Res, StudentRequest>;
  @useResult
  $Res call({
    String fullName,
    String parentName,
    String parentPhoneNumber,
    int? activeGroupId,
  });
}

/// @nodoc
class _$StudentRequestCopyWithImpl<$Res, $Val extends StudentRequest>
    implements $StudentRequestCopyWith<$Res> {
  _$StudentRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? parentName = null,
    Object? parentPhoneNumber = null,
    Object? activeGroupId = freezed,
  }) {
    return _then(
      _value.copyWith(
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
            activeGroupId: freezed == activeGroupId
                ? _value.activeGroupId
                : activeGroupId // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentRequestImplCopyWith<$Res>
    implements $StudentRequestCopyWith<$Res> {
  factory _$$StudentRequestImplCopyWith(
    _$StudentRequestImpl value,
    $Res Function(_$StudentRequestImpl) then,
  ) = __$$StudentRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String fullName,
    String parentName,
    String parentPhoneNumber,
    int? activeGroupId,
  });
}

/// @nodoc
class __$$StudentRequestImplCopyWithImpl<$Res>
    extends _$StudentRequestCopyWithImpl<$Res, _$StudentRequestImpl>
    implements _$$StudentRequestImplCopyWith<$Res> {
  __$$StudentRequestImplCopyWithImpl(
    _$StudentRequestImpl _value,
    $Res Function(_$StudentRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? parentName = null,
    Object? parentPhoneNumber = null,
    Object? activeGroupId = freezed,
  }) {
    return _then(
      _$StudentRequestImpl(
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
        activeGroupId: freezed == activeGroupId
            ? _value.activeGroupId
            : activeGroupId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentRequestImpl implements _StudentRequest {
  const _$StudentRequestImpl({
    required this.fullName,
    required this.parentName,
    required this.parentPhoneNumber,
    this.activeGroupId,
  });

  factory _$StudentRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentRequestImplFromJson(json);

  @override
  final String fullName;
  @override
  final String parentName;
  @override
  final String parentPhoneNumber;
  @override
  final int? activeGroupId;

  @override
  String toString() {
    return 'StudentRequest(fullName: $fullName, parentName: $parentName, parentPhoneNumber: $parentPhoneNumber, activeGroupId: $activeGroupId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentRequestImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.parentName, parentName) ||
                other.parentName == parentName) &&
            (identical(other.parentPhoneNumber, parentPhoneNumber) ||
                other.parentPhoneNumber == parentPhoneNumber) &&
            (identical(other.activeGroupId, activeGroupId) ||
                other.activeGroupId == activeGroupId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    fullName,
    parentName,
    parentPhoneNumber,
    activeGroupId,
  );

  /// Create a copy of StudentRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentRequestImplCopyWith<_$StudentRequestImpl> get copyWith =>
      __$$StudentRequestImplCopyWithImpl<_$StudentRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentRequestImplToJson(this);
  }
}

abstract class _StudentRequest implements StudentRequest {
  const factory _StudentRequest({
    required final String fullName,
    required final String parentName,
    required final String parentPhoneNumber,
    final int? activeGroupId,
  }) = _$StudentRequestImpl;

  factory _StudentRequest.fromJson(Map<String, dynamic> json) =
      _$StudentRequestImpl.fromJson;

  @override
  String get fullName;
  @override
  String get parentName;
  @override
  String get parentPhoneNumber;
  @override
  int? get activeGroupId;

  /// Create a copy of StudentRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentRequestImplCopyWith<_$StudentRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
