// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'teacher_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TeacherRequest _$TeacherRequestFromJson(Map<String, dynamic> json) {
  return _TeacherRequest.fromJson(json);
}

/// @nodoc
mixin _$TeacherRequest {
  String get fullName => throw _privateConstructorUsedError;
  String get phoneNumber => throw _privateConstructorUsedError;

  /// Serializes this TeacherRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherRequestCopyWith<TeacherRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherRequestCopyWith<$Res> {
  factory $TeacherRequestCopyWith(
    TeacherRequest value,
    $Res Function(TeacherRequest) then,
  ) = _$TeacherRequestCopyWithImpl<$Res, TeacherRequest>;
  @useResult
  $Res call({String fullName, String phoneNumber});
}

/// @nodoc
class _$TeacherRequestCopyWithImpl<$Res, $Val extends TeacherRequest>
    implements $TeacherRequestCopyWith<$Res> {
  _$TeacherRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? fullName = null, Object? phoneNumber = null}) {
    return _then(
      _value.copyWith(
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            phoneNumber: null == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeacherRequestImplCopyWith<$Res>
    implements $TeacherRequestCopyWith<$Res> {
  factory _$$TeacherRequestImplCopyWith(
    _$TeacherRequestImpl value,
    $Res Function(_$TeacherRequestImpl) then,
  ) = __$$TeacherRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String fullName, String phoneNumber});
}

/// @nodoc
class __$$TeacherRequestImplCopyWithImpl<$Res>
    extends _$TeacherRequestCopyWithImpl<$Res, _$TeacherRequestImpl>
    implements _$$TeacherRequestImplCopyWith<$Res> {
  __$$TeacherRequestImplCopyWithImpl(
    _$TeacherRequestImpl _value,
    $Res Function(_$TeacherRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? fullName = null, Object? phoneNumber = null}) {
    return _then(
      _$TeacherRequestImpl(
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        phoneNumber: null == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherRequestImpl implements _TeacherRequest {
  const _$TeacherRequestImpl({
    required this.fullName,
    required this.phoneNumber,
  });

  factory _$TeacherRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherRequestImplFromJson(json);

  @override
  final String fullName;
  @override
  final String phoneNumber;

  @override
  String toString() {
    return 'TeacherRequest(fullName: $fullName, phoneNumber: $phoneNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherRequestImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, fullName, phoneNumber);

  /// Create a copy of TeacherRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherRequestImplCopyWith<_$TeacherRequestImpl> get copyWith =>
      __$$TeacherRequestImplCopyWithImpl<_$TeacherRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherRequestImplToJson(this);
  }
}

abstract class _TeacherRequest implements TeacherRequest {
  const factory _TeacherRequest({
    required final String fullName,
    required final String phoneNumber,
  }) = _$TeacherRequestImpl;

  factory _TeacherRequest.fromJson(Map<String, dynamic> json) =
      _$TeacherRequestImpl.fromJson;

  @override
  String get fullName;
  @override
  String get phoneNumber;

  /// Create a copy of TeacherRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherRequestImplCopyWith<_$TeacherRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
