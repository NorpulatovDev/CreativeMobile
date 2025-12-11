// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AttendanceRequest _$AttendanceRequestFromJson(Map<String, dynamic> json) {
  return _AttendanceRequest.fromJson(json);
}

/// @nodoc
mixin _$AttendanceRequest {
  int get groupId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  List<int>? get absentStudentIds => throw _privateConstructorUsedError;

  /// Serializes this AttendanceRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceRequestCopyWith<AttendanceRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceRequestCopyWith<$Res> {
  factory $AttendanceRequestCopyWith(
    AttendanceRequest value,
    $Res Function(AttendanceRequest) then,
  ) = _$AttendanceRequestCopyWithImpl<$Res, AttendanceRequest>;
  @useResult
  $Res call({int groupId, DateTime date, List<int>? absentStudentIds});
}

/// @nodoc
class _$AttendanceRequestCopyWithImpl<$Res, $Val extends AttendanceRequest>
    implements $AttendanceRequestCopyWith<$Res> {
  _$AttendanceRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? date = null,
    Object? absentStudentIds = freezed,
  }) {
    return _then(
      _value.copyWith(
            groupId: null == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                      as int,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            absentStudentIds: freezed == absentStudentIds
                ? _value.absentStudentIds
                : absentStudentIds // ignore: cast_nullable_to_non_nullable
                      as List<int>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AttendanceRequestImplCopyWith<$Res>
    implements $AttendanceRequestCopyWith<$Res> {
  factory _$$AttendanceRequestImplCopyWith(
    _$AttendanceRequestImpl value,
    $Res Function(_$AttendanceRequestImpl) then,
  ) = __$$AttendanceRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int groupId, DateTime date, List<int>? absentStudentIds});
}

/// @nodoc
class __$$AttendanceRequestImplCopyWithImpl<$Res>
    extends _$AttendanceRequestCopyWithImpl<$Res, _$AttendanceRequestImpl>
    implements _$$AttendanceRequestImplCopyWith<$Res> {
  __$$AttendanceRequestImplCopyWithImpl(
    _$AttendanceRequestImpl _value,
    $Res Function(_$AttendanceRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttendanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? date = null,
    Object? absentStudentIds = freezed,
  }) {
    return _then(
      _$AttendanceRequestImpl(
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as int,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        absentStudentIds: freezed == absentStudentIds
            ? _value._absentStudentIds
            : absentStudentIds // ignore: cast_nullable_to_non_nullable
                  as List<int>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceRequestImpl implements _AttendanceRequest {
  const _$AttendanceRequestImpl({
    required this.groupId,
    required this.date,
    final List<int>? absentStudentIds,
  }) : _absentStudentIds = absentStudentIds;

  factory _$AttendanceRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceRequestImplFromJson(json);

  @override
  final int groupId;
  @override
  final DateTime date;
  final List<int>? _absentStudentIds;
  @override
  List<int>? get absentStudentIds {
    final value = _absentStudentIds;
    if (value == null) return null;
    if (_absentStudentIds is EqualUnmodifiableListView)
      return _absentStudentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'AttendanceRequest(groupId: $groupId, date: $date, absentStudentIds: $absentStudentIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceRequestImpl &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(
              other._absentStudentIds,
              _absentStudentIds,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    groupId,
    date,
    const DeepCollectionEquality().hash(_absentStudentIds),
  );

  /// Create a copy of AttendanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceRequestImplCopyWith<_$AttendanceRequestImpl> get copyWith =>
      __$$AttendanceRequestImplCopyWithImpl<_$AttendanceRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceRequestImplToJson(this);
  }
}

abstract class _AttendanceRequest implements AttendanceRequest {
  const factory _AttendanceRequest({
    required final int groupId,
    required final DateTime date,
    final List<int>? absentStudentIds,
  }) = _$AttendanceRequestImpl;

  factory _AttendanceRequest.fromJson(Map<String, dynamic> json) =
      _$AttendanceRequestImpl.fromJson;

  @override
  int get groupId;
  @override
  DateTime get date;
  @override
  List<int>? get absentStudentIds;

  /// Create a copy of AttendanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceRequestImplCopyWith<_$AttendanceRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AttendanceUpdateRequest _$AttendanceUpdateRequestFromJson(
  Map<String, dynamic> json,
) {
  return _AttendanceUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$AttendanceUpdateRequest {
  String get status => throw _privateConstructorUsedError;

  /// Serializes this AttendanceUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceUpdateRequestCopyWith<AttendanceUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceUpdateRequestCopyWith<$Res> {
  factory $AttendanceUpdateRequestCopyWith(
    AttendanceUpdateRequest value,
    $Res Function(AttendanceUpdateRequest) then,
  ) = _$AttendanceUpdateRequestCopyWithImpl<$Res, AttendanceUpdateRequest>;
  @useResult
  $Res call({String status});
}

/// @nodoc
class _$AttendanceUpdateRequestCopyWithImpl<
  $Res,
  $Val extends AttendanceUpdateRequest
>
    implements $AttendanceUpdateRequestCopyWith<$Res> {
  _$AttendanceUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? status = null}) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AttendanceUpdateRequestImplCopyWith<$Res>
    implements $AttendanceUpdateRequestCopyWith<$Res> {
  factory _$$AttendanceUpdateRequestImplCopyWith(
    _$AttendanceUpdateRequestImpl value,
    $Res Function(_$AttendanceUpdateRequestImpl) then,
  ) = __$$AttendanceUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String status});
}

/// @nodoc
class __$$AttendanceUpdateRequestImplCopyWithImpl<$Res>
    extends
        _$AttendanceUpdateRequestCopyWithImpl<
          $Res,
          _$AttendanceUpdateRequestImpl
        >
    implements _$$AttendanceUpdateRequestImplCopyWith<$Res> {
  __$$AttendanceUpdateRequestImplCopyWithImpl(
    _$AttendanceUpdateRequestImpl _value,
    $Res Function(_$AttendanceUpdateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttendanceUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? status = null}) {
    return _then(
      _$AttendanceUpdateRequestImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceUpdateRequestImpl implements _AttendanceUpdateRequest {
  const _$AttendanceUpdateRequestImpl({required this.status});

  factory _$AttendanceUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceUpdateRequestImplFromJson(json);

  @override
  final String status;

  @override
  String toString() {
    return 'AttendanceUpdateRequest(status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceUpdateRequestImpl &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status);

  /// Create a copy of AttendanceUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceUpdateRequestImplCopyWith<_$AttendanceUpdateRequestImpl>
  get copyWith =>
      __$$AttendanceUpdateRequestImplCopyWithImpl<
        _$AttendanceUpdateRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceUpdateRequestImplToJson(this);
  }
}

abstract class _AttendanceUpdateRequest implements AttendanceUpdateRequest {
  const factory _AttendanceUpdateRequest({required final String status}) =
      _$AttendanceUpdateRequestImpl;

  factory _AttendanceUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$AttendanceUpdateRequestImpl.fromJson;

  @override
  String get status;

  /// Create a copy of AttendanceUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceUpdateRequestImplCopyWith<_$AttendanceUpdateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
