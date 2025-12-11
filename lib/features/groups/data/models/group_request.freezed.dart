// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GroupRequest _$GroupRequestFromJson(Map<String, dynamic> json) {
  return _GroupRequest.fromJson(json);
}

/// @nodoc
mixin _$GroupRequest {
  String get name => throw _privateConstructorUsedError;
  int get teacherId => throw _privateConstructorUsedError;
  double get monthlyFee => throw _privateConstructorUsedError;

  /// Serializes this GroupRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupRequestCopyWith<GroupRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupRequestCopyWith<$Res> {
  factory $GroupRequestCopyWith(
    GroupRequest value,
    $Res Function(GroupRequest) then,
  ) = _$GroupRequestCopyWithImpl<$Res, GroupRequest>;
  @useResult
  $Res call({String name, int teacherId, double monthlyFee});
}

/// @nodoc
class _$GroupRequestCopyWithImpl<$Res, $Val extends GroupRequest>
    implements $GroupRequestCopyWith<$Res> {
  _$GroupRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? teacherId = null,
    Object? monthlyFee = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            teacherId: null == teacherId
                ? _value.teacherId
                : teacherId // ignore: cast_nullable_to_non_nullable
                      as int,
            monthlyFee: null == monthlyFee
                ? _value.monthlyFee
                : monthlyFee // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GroupRequestImplCopyWith<$Res>
    implements $GroupRequestCopyWith<$Res> {
  factory _$$GroupRequestImplCopyWith(
    _$GroupRequestImpl value,
    $Res Function(_$GroupRequestImpl) then,
  ) = __$$GroupRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int teacherId, double monthlyFee});
}

/// @nodoc
class __$$GroupRequestImplCopyWithImpl<$Res>
    extends _$GroupRequestCopyWithImpl<$Res, _$GroupRequestImpl>
    implements _$$GroupRequestImplCopyWith<$Res> {
  __$$GroupRequestImplCopyWithImpl(
    _$GroupRequestImpl _value,
    $Res Function(_$GroupRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? teacherId = null,
    Object? monthlyFee = null,
  }) {
    return _then(
      _$GroupRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        teacherId: null == teacherId
            ? _value.teacherId
            : teacherId // ignore: cast_nullable_to_non_nullable
                  as int,
        monthlyFee: null == monthlyFee
            ? _value.monthlyFee
            : monthlyFee // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupRequestImpl implements _GroupRequest {
  const _$GroupRequestImpl({
    required this.name,
    required this.teacherId,
    required this.monthlyFee,
  });

  factory _$GroupRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupRequestImplFromJson(json);

  @override
  final String name;
  @override
  final int teacherId;
  @override
  final double monthlyFee;

  @override
  String toString() {
    return 'GroupRequest(name: $name, teacherId: $teacherId, monthlyFee: $monthlyFee)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.monthlyFee, monthlyFee) ||
                other.monthlyFee == monthlyFee));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, teacherId, monthlyFee);

  /// Create a copy of GroupRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupRequestImplCopyWith<_$GroupRequestImpl> get copyWith =>
      __$$GroupRequestImplCopyWithImpl<_$GroupRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupRequestImplToJson(this);
  }
}

abstract class _GroupRequest implements GroupRequest {
  const factory _GroupRequest({
    required final String name,
    required final int teacherId,
    required final double monthlyFee,
  }) = _$GroupRequestImpl;

  factory _GroupRequest.fromJson(Map<String, dynamic> json) =
      _$GroupRequestImpl.fromJson;

  @override
  String get name;
  @override
  int get teacherId;
  @override
  double get monthlyFee;

  /// Create a copy of GroupRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupRequestImplCopyWith<_$GroupRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
