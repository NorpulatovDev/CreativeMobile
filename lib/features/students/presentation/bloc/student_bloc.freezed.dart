// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$StudentEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadAll,
    required TResult Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )
    create,
    required TResult Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )
    update,
    required TResult Function(int studentId, int groupId) assignToGroup,
    required TResult Function(int studentId) removeFromGroup,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadAll,
    TResult? Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    create,
    TResult? Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    update,
    TResult? Function(int studentId, int groupId)? assignToGroup,
    TResult? Function(int studentId)? removeFromGroup,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadAll,
    TResult Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    create,
    TResult Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    update,
    TResult Function(int studentId, int groupId)? assignToGroup,
    TResult Function(int studentId)? removeFromGroup,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StudentLoadAll value) loadAll,
    required TResult Function(StudentCreate value) create,
    required TResult Function(StudentUpdate value) update,
    required TResult Function(StudentAssignToGroup value) assignToGroup,
    required TResult Function(StudentRemoveFromGroup value) removeFromGroup,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StudentLoadAll value)? loadAll,
    TResult? Function(StudentCreate value)? create,
    TResult? Function(StudentUpdate value)? update,
    TResult? Function(StudentAssignToGroup value)? assignToGroup,
    TResult? Function(StudentRemoveFromGroup value)? removeFromGroup,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StudentLoadAll value)? loadAll,
    TResult Function(StudentCreate value)? create,
    TResult Function(StudentUpdate value)? update,
    TResult Function(StudentAssignToGroup value)? assignToGroup,
    TResult Function(StudentRemoveFromGroup value)? removeFromGroup,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentEventCopyWith<$Res> {
  factory $StudentEventCopyWith(
    StudentEvent value,
    $Res Function(StudentEvent) then,
  ) = _$StudentEventCopyWithImpl<$Res, StudentEvent>;
}

/// @nodoc
class _$StudentEventCopyWithImpl<$Res, $Val extends StudentEvent>
    implements $StudentEventCopyWith<$Res> {
  _$StudentEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$StudentLoadAllImplCopyWith<$Res> {
  factory _$$StudentLoadAllImplCopyWith(
    _$StudentLoadAllImpl value,
    $Res Function(_$StudentLoadAllImpl) then,
  ) = __$$StudentLoadAllImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$StudentLoadAllImplCopyWithImpl<$Res>
    extends _$StudentEventCopyWithImpl<$Res, _$StudentLoadAllImpl>
    implements _$$StudentLoadAllImplCopyWith<$Res> {
  __$$StudentLoadAllImplCopyWithImpl(
    _$StudentLoadAllImpl _value,
    $Res Function(_$StudentLoadAllImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$StudentLoadAllImpl implements StudentLoadAll {
  const _$StudentLoadAllImpl();

  @override
  String toString() {
    return 'StudentEvent.loadAll()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$StudentLoadAllImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadAll,
    required TResult Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )
    create,
    required TResult Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )
    update,
    required TResult Function(int studentId, int groupId) assignToGroup,
    required TResult Function(int studentId) removeFromGroup,
  }) {
    return loadAll();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadAll,
    TResult? Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    create,
    TResult? Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    update,
    TResult? Function(int studentId, int groupId)? assignToGroup,
    TResult? Function(int studentId)? removeFromGroup,
  }) {
    return loadAll?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadAll,
    TResult Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    create,
    TResult Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    update,
    TResult Function(int studentId, int groupId)? assignToGroup,
    TResult Function(int studentId)? removeFromGroup,
    required TResult orElse(),
  }) {
    if (loadAll != null) {
      return loadAll();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StudentLoadAll value) loadAll,
    required TResult Function(StudentCreate value) create,
    required TResult Function(StudentUpdate value) update,
    required TResult Function(StudentAssignToGroup value) assignToGroup,
    required TResult Function(StudentRemoveFromGroup value) removeFromGroup,
  }) {
    return loadAll(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StudentLoadAll value)? loadAll,
    TResult? Function(StudentCreate value)? create,
    TResult? Function(StudentUpdate value)? update,
    TResult? Function(StudentAssignToGroup value)? assignToGroup,
    TResult? Function(StudentRemoveFromGroup value)? removeFromGroup,
  }) {
    return loadAll?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StudentLoadAll value)? loadAll,
    TResult Function(StudentCreate value)? create,
    TResult Function(StudentUpdate value)? update,
    TResult Function(StudentAssignToGroup value)? assignToGroup,
    TResult Function(StudentRemoveFromGroup value)? removeFromGroup,
    required TResult orElse(),
  }) {
    if (loadAll != null) {
      return loadAll(this);
    }
    return orElse();
  }
}

abstract class StudentLoadAll implements StudentEvent {
  const factory StudentLoadAll() = _$StudentLoadAllImpl;
}

/// @nodoc
abstract class _$$StudentCreateImplCopyWith<$Res> {
  factory _$$StudentCreateImplCopyWith(
    _$StudentCreateImpl value,
    $Res Function(_$StudentCreateImpl) then,
  ) = __$$StudentCreateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String fullName,
    String parentName,
    String parentPhoneNumber,
    int? activeGroupId,
  });
}

/// @nodoc
class __$$StudentCreateImplCopyWithImpl<$Res>
    extends _$StudentEventCopyWithImpl<$Res, _$StudentCreateImpl>
    implements _$$StudentCreateImplCopyWith<$Res> {
  __$$StudentCreateImplCopyWithImpl(
    _$StudentCreateImpl _value,
    $Res Function(_$StudentCreateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentEvent
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
      _$StudentCreateImpl(
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

class _$StudentCreateImpl implements StudentCreate {
  const _$StudentCreateImpl({
    required this.fullName,
    required this.parentName,
    required this.parentPhoneNumber,
    this.activeGroupId,
  });

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
    return 'StudentEvent.create(fullName: $fullName, parentName: $parentName, parentPhoneNumber: $parentPhoneNumber, activeGroupId: $activeGroupId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentCreateImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.parentName, parentName) ||
                other.parentName == parentName) &&
            (identical(other.parentPhoneNumber, parentPhoneNumber) ||
                other.parentPhoneNumber == parentPhoneNumber) &&
            (identical(other.activeGroupId, activeGroupId) ||
                other.activeGroupId == activeGroupId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    fullName,
    parentName,
    parentPhoneNumber,
    activeGroupId,
  );

  /// Create a copy of StudentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentCreateImplCopyWith<_$StudentCreateImpl> get copyWith =>
      __$$StudentCreateImplCopyWithImpl<_$StudentCreateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadAll,
    required TResult Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )
    create,
    required TResult Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )
    update,
    required TResult Function(int studentId, int groupId) assignToGroup,
    required TResult Function(int studentId) removeFromGroup,
  }) {
    return create(fullName, parentName, parentPhoneNumber, activeGroupId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadAll,
    TResult? Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    create,
    TResult? Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    update,
    TResult? Function(int studentId, int groupId)? assignToGroup,
    TResult? Function(int studentId)? removeFromGroup,
  }) {
    return create?.call(fullName, parentName, parentPhoneNumber, activeGroupId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadAll,
    TResult Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    create,
    TResult Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    update,
    TResult Function(int studentId, int groupId)? assignToGroup,
    TResult Function(int studentId)? removeFromGroup,
    required TResult orElse(),
  }) {
    if (create != null) {
      return create(fullName, parentName, parentPhoneNumber, activeGroupId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StudentLoadAll value) loadAll,
    required TResult Function(StudentCreate value) create,
    required TResult Function(StudentUpdate value) update,
    required TResult Function(StudentAssignToGroup value) assignToGroup,
    required TResult Function(StudentRemoveFromGroup value) removeFromGroup,
  }) {
    return create(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StudentLoadAll value)? loadAll,
    TResult? Function(StudentCreate value)? create,
    TResult? Function(StudentUpdate value)? update,
    TResult? Function(StudentAssignToGroup value)? assignToGroup,
    TResult? Function(StudentRemoveFromGroup value)? removeFromGroup,
  }) {
    return create?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StudentLoadAll value)? loadAll,
    TResult Function(StudentCreate value)? create,
    TResult Function(StudentUpdate value)? update,
    TResult Function(StudentAssignToGroup value)? assignToGroup,
    TResult Function(StudentRemoveFromGroup value)? removeFromGroup,
    required TResult orElse(),
  }) {
    if (create != null) {
      return create(this);
    }
    return orElse();
  }
}

abstract class StudentCreate implements StudentEvent {
  const factory StudentCreate({
    required final String fullName,
    required final String parentName,
    required final String parentPhoneNumber,
    final int? activeGroupId,
  }) = _$StudentCreateImpl;

  String get fullName;
  String get parentName;
  String get parentPhoneNumber;
  int? get activeGroupId;

  /// Create a copy of StudentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentCreateImplCopyWith<_$StudentCreateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StudentUpdateImplCopyWith<$Res> {
  factory _$$StudentUpdateImplCopyWith(
    _$StudentUpdateImpl value,
    $Res Function(_$StudentUpdateImpl) then,
  ) = __$$StudentUpdateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    int id,
    String fullName,
    String parentName,
    String parentPhoneNumber,
    int? activeGroupId,
  });
}

/// @nodoc
class __$$StudentUpdateImplCopyWithImpl<$Res>
    extends _$StudentEventCopyWithImpl<$Res, _$StudentUpdateImpl>
    implements _$$StudentUpdateImplCopyWith<$Res> {
  __$$StudentUpdateImplCopyWithImpl(
    _$StudentUpdateImpl _value,
    $Res Function(_$StudentUpdateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? parentName = null,
    Object? parentPhoneNumber = null,
    Object? activeGroupId = freezed,
  }) {
    return _then(
      _$StudentUpdateImpl(
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
        activeGroupId: freezed == activeGroupId
            ? _value.activeGroupId
            : activeGroupId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$StudentUpdateImpl implements StudentUpdate {
  const _$StudentUpdateImpl({
    required this.id,
    required this.fullName,
    required this.parentName,
    required this.parentPhoneNumber,
    this.activeGroupId,
  });

  @override
  final int id;
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
    return 'StudentEvent.update(id: $id, fullName: $fullName, parentName: $parentName, parentPhoneNumber: $parentPhoneNumber, activeGroupId: $activeGroupId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentUpdateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.parentName, parentName) ||
                other.parentName == parentName) &&
            (identical(other.parentPhoneNumber, parentPhoneNumber) ||
                other.parentPhoneNumber == parentPhoneNumber) &&
            (identical(other.activeGroupId, activeGroupId) ||
                other.activeGroupId == activeGroupId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    fullName,
    parentName,
    parentPhoneNumber,
    activeGroupId,
  );

  /// Create a copy of StudentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentUpdateImplCopyWith<_$StudentUpdateImpl> get copyWith =>
      __$$StudentUpdateImplCopyWithImpl<_$StudentUpdateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadAll,
    required TResult Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )
    create,
    required TResult Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )
    update,
    required TResult Function(int studentId, int groupId) assignToGroup,
    required TResult Function(int studentId) removeFromGroup,
  }) {
    return update(id, fullName, parentName, parentPhoneNumber, activeGroupId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadAll,
    TResult? Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    create,
    TResult? Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    update,
    TResult? Function(int studentId, int groupId)? assignToGroup,
    TResult? Function(int studentId)? removeFromGroup,
  }) {
    return update?.call(
      id,
      fullName,
      parentName,
      parentPhoneNumber,
      activeGroupId,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadAll,
    TResult Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    create,
    TResult Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    update,
    TResult Function(int studentId, int groupId)? assignToGroup,
    TResult Function(int studentId)? removeFromGroup,
    required TResult orElse(),
  }) {
    if (update != null) {
      return update(id, fullName, parentName, parentPhoneNumber, activeGroupId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StudentLoadAll value) loadAll,
    required TResult Function(StudentCreate value) create,
    required TResult Function(StudentUpdate value) update,
    required TResult Function(StudentAssignToGroup value) assignToGroup,
    required TResult Function(StudentRemoveFromGroup value) removeFromGroup,
  }) {
    return update(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StudentLoadAll value)? loadAll,
    TResult? Function(StudentCreate value)? create,
    TResult? Function(StudentUpdate value)? update,
    TResult? Function(StudentAssignToGroup value)? assignToGroup,
    TResult? Function(StudentRemoveFromGroup value)? removeFromGroup,
  }) {
    return update?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StudentLoadAll value)? loadAll,
    TResult Function(StudentCreate value)? create,
    TResult Function(StudentUpdate value)? update,
    TResult Function(StudentAssignToGroup value)? assignToGroup,
    TResult Function(StudentRemoveFromGroup value)? removeFromGroup,
    required TResult orElse(),
  }) {
    if (update != null) {
      return update(this);
    }
    return orElse();
  }
}

abstract class StudentUpdate implements StudentEvent {
  const factory StudentUpdate({
    required final int id,
    required final String fullName,
    required final String parentName,
    required final String parentPhoneNumber,
    final int? activeGroupId,
  }) = _$StudentUpdateImpl;

  int get id;
  String get fullName;
  String get parentName;
  String get parentPhoneNumber;
  int? get activeGroupId;

  /// Create a copy of StudentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentUpdateImplCopyWith<_$StudentUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StudentAssignToGroupImplCopyWith<$Res> {
  factory _$$StudentAssignToGroupImplCopyWith(
    _$StudentAssignToGroupImpl value,
    $Res Function(_$StudentAssignToGroupImpl) then,
  ) = __$$StudentAssignToGroupImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int studentId, int groupId});
}

/// @nodoc
class __$$StudentAssignToGroupImplCopyWithImpl<$Res>
    extends _$StudentEventCopyWithImpl<$Res, _$StudentAssignToGroupImpl>
    implements _$$StudentAssignToGroupImplCopyWith<$Res> {
  __$$StudentAssignToGroupImplCopyWithImpl(
    _$StudentAssignToGroupImpl _value,
    $Res Function(_$StudentAssignToGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? studentId = null, Object? groupId = null}) {
    return _then(
      _$StudentAssignToGroupImpl(
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as int,
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$StudentAssignToGroupImpl implements StudentAssignToGroup {
  const _$StudentAssignToGroupImpl({
    required this.studentId,
    required this.groupId,
  });

  @override
  final int studentId;
  @override
  final int groupId;

  @override
  String toString() {
    return 'StudentEvent.assignToGroup(studentId: $studentId, groupId: $groupId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentAssignToGroupImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, studentId, groupId);

  /// Create a copy of StudentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentAssignToGroupImplCopyWith<_$StudentAssignToGroupImpl>
  get copyWith =>
      __$$StudentAssignToGroupImplCopyWithImpl<_$StudentAssignToGroupImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadAll,
    required TResult Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )
    create,
    required TResult Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )
    update,
    required TResult Function(int studentId, int groupId) assignToGroup,
    required TResult Function(int studentId) removeFromGroup,
  }) {
    return assignToGroup(studentId, groupId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadAll,
    TResult? Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    create,
    TResult? Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    update,
    TResult? Function(int studentId, int groupId)? assignToGroup,
    TResult? Function(int studentId)? removeFromGroup,
  }) {
    return assignToGroup?.call(studentId, groupId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadAll,
    TResult Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    create,
    TResult Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    update,
    TResult Function(int studentId, int groupId)? assignToGroup,
    TResult Function(int studentId)? removeFromGroup,
    required TResult orElse(),
  }) {
    if (assignToGroup != null) {
      return assignToGroup(studentId, groupId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StudentLoadAll value) loadAll,
    required TResult Function(StudentCreate value) create,
    required TResult Function(StudentUpdate value) update,
    required TResult Function(StudentAssignToGroup value) assignToGroup,
    required TResult Function(StudentRemoveFromGroup value) removeFromGroup,
  }) {
    return assignToGroup(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StudentLoadAll value)? loadAll,
    TResult? Function(StudentCreate value)? create,
    TResult? Function(StudentUpdate value)? update,
    TResult? Function(StudentAssignToGroup value)? assignToGroup,
    TResult? Function(StudentRemoveFromGroup value)? removeFromGroup,
  }) {
    return assignToGroup?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StudentLoadAll value)? loadAll,
    TResult Function(StudentCreate value)? create,
    TResult Function(StudentUpdate value)? update,
    TResult Function(StudentAssignToGroup value)? assignToGroup,
    TResult Function(StudentRemoveFromGroup value)? removeFromGroup,
    required TResult orElse(),
  }) {
    if (assignToGroup != null) {
      return assignToGroup(this);
    }
    return orElse();
  }
}

abstract class StudentAssignToGroup implements StudentEvent {
  const factory StudentAssignToGroup({
    required final int studentId,
    required final int groupId,
  }) = _$StudentAssignToGroupImpl;

  int get studentId;
  int get groupId;

  /// Create a copy of StudentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentAssignToGroupImplCopyWith<_$StudentAssignToGroupImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StudentRemoveFromGroupImplCopyWith<$Res> {
  factory _$$StudentRemoveFromGroupImplCopyWith(
    _$StudentRemoveFromGroupImpl value,
    $Res Function(_$StudentRemoveFromGroupImpl) then,
  ) = __$$StudentRemoveFromGroupImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int studentId});
}

/// @nodoc
class __$$StudentRemoveFromGroupImplCopyWithImpl<$Res>
    extends _$StudentEventCopyWithImpl<$Res, _$StudentRemoveFromGroupImpl>
    implements _$$StudentRemoveFromGroupImplCopyWith<$Res> {
  __$$StudentRemoveFromGroupImplCopyWithImpl(
    _$StudentRemoveFromGroupImpl _value,
    $Res Function(_$StudentRemoveFromGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? studentId = null}) {
    return _then(
      _$StudentRemoveFromGroupImpl(
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$StudentRemoveFromGroupImpl implements StudentRemoveFromGroup {
  const _$StudentRemoveFromGroupImpl({required this.studentId});

  @override
  final int studentId;

  @override
  String toString() {
    return 'StudentEvent.removeFromGroup(studentId: $studentId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentRemoveFromGroupImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, studentId);

  /// Create a copy of StudentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentRemoveFromGroupImplCopyWith<_$StudentRemoveFromGroupImpl>
  get copyWith =>
      __$$StudentRemoveFromGroupImplCopyWithImpl<_$StudentRemoveFromGroupImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadAll,
    required TResult Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )
    create,
    required TResult Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )
    update,
    required TResult Function(int studentId, int groupId) assignToGroup,
    required TResult Function(int studentId) removeFromGroup,
  }) {
    return removeFromGroup(studentId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadAll,
    TResult? Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    create,
    TResult? Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    update,
    TResult? Function(int studentId, int groupId)? assignToGroup,
    TResult? Function(int studentId)? removeFromGroup,
  }) {
    return removeFromGroup?.call(studentId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadAll,
    TResult Function(
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    create,
    TResult Function(
      int id,
      String fullName,
      String parentName,
      String parentPhoneNumber,
      int? activeGroupId,
    )?
    update,
    TResult Function(int studentId, int groupId)? assignToGroup,
    TResult Function(int studentId)? removeFromGroup,
    required TResult orElse(),
  }) {
    if (removeFromGroup != null) {
      return removeFromGroup(studentId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StudentLoadAll value) loadAll,
    required TResult Function(StudentCreate value) create,
    required TResult Function(StudentUpdate value) update,
    required TResult Function(StudentAssignToGroup value) assignToGroup,
    required TResult Function(StudentRemoveFromGroup value) removeFromGroup,
  }) {
    return removeFromGroup(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StudentLoadAll value)? loadAll,
    TResult? Function(StudentCreate value)? create,
    TResult? Function(StudentUpdate value)? update,
    TResult? Function(StudentAssignToGroup value)? assignToGroup,
    TResult? Function(StudentRemoveFromGroup value)? removeFromGroup,
  }) {
    return removeFromGroup?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StudentLoadAll value)? loadAll,
    TResult Function(StudentCreate value)? create,
    TResult Function(StudentUpdate value)? update,
    TResult Function(StudentAssignToGroup value)? assignToGroup,
    TResult Function(StudentRemoveFromGroup value)? removeFromGroup,
    required TResult orElse(),
  }) {
    if (removeFromGroup != null) {
      return removeFromGroup(this);
    }
    return orElse();
  }
}

abstract class StudentRemoveFromGroup implements StudentEvent {
  const factory StudentRemoveFromGroup({required final int studentId}) =
      _$StudentRemoveFromGroupImpl;

  int get studentId;

  /// Create a copy of StudentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentRemoveFromGroupImplCopyWith<_$StudentRemoveFromGroupImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$StudentState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Student> students, List<Group> groups)
    loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Student> students, List<Group> groups)? loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Student> students, List<Group> groups)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StudentInitial value) initial,
    required TResult Function(StudentLoading value) loading,
    required TResult Function(StudentLoaded value) loaded,
    required TResult Function(StudentError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StudentInitial value)? initial,
    TResult? Function(StudentLoading value)? loading,
    TResult? Function(StudentLoaded value)? loaded,
    TResult? Function(StudentError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StudentInitial value)? initial,
    TResult Function(StudentLoading value)? loading,
    TResult Function(StudentLoaded value)? loaded,
    TResult Function(StudentError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentStateCopyWith<$Res> {
  factory $StudentStateCopyWith(
    StudentState value,
    $Res Function(StudentState) then,
  ) = _$StudentStateCopyWithImpl<$Res, StudentState>;
}

/// @nodoc
class _$StudentStateCopyWithImpl<$Res, $Val extends StudentState>
    implements $StudentStateCopyWith<$Res> {
  _$StudentStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$StudentInitialImplCopyWith<$Res> {
  factory _$$StudentInitialImplCopyWith(
    _$StudentInitialImpl value,
    $Res Function(_$StudentInitialImpl) then,
  ) = __$$StudentInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$StudentInitialImplCopyWithImpl<$Res>
    extends _$StudentStateCopyWithImpl<$Res, _$StudentInitialImpl>
    implements _$$StudentInitialImplCopyWith<$Res> {
  __$$StudentInitialImplCopyWithImpl(
    _$StudentInitialImpl _value,
    $Res Function(_$StudentInitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$StudentInitialImpl implements StudentInitial {
  const _$StudentInitialImpl();

  @override
  String toString() {
    return 'StudentState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$StudentInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Student> students, List<Group> groups)
    loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Student> students, List<Group> groups)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Student> students, List<Group> groups)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StudentInitial value) initial,
    required TResult Function(StudentLoading value) loading,
    required TResult Function(StudentLoaded value) loaded,
    required TResult Function(StudentError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StudentInitial value)? initial,
    TResult? Function(StudentLoading value)? loading,
    TResult? Function(StudentLoaded value)? loaded,
    TResult? Function(StudentError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StudentInitial value)? initial,
    TResult Function(StudentLoading value)? loading,
    TResult Function(StudentLoaded value)? loaded,
    TResult Function(StudentError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class StudentInitial implements StudentState {
  const factory StudentInitial() = _$StudentInitialImpl;
}

/// @nodoc
abstract class _$$StudentLoadingImplCopyWith<$Res> {
  factory _$$StudentLoadingImplCopyWith(
    _$StudentLoadingImpl value,
    $Res Function(_$StudentLoadingImpl) then,
  ) = __$$StudentLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$StudentLoadingImplCopyWithImpl<$Res>
    extends _$StudentStateCopyWithImpl<$Res, _$StudentLoadingImpl>
    implements _$$StudentLoadingImplCopyWith<$Res> {
  __$$StudentLoadingImplCopyWithImpl(
    _$StudentLoadingImpl _value,
    $Res Function(_$StudentLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$StudentLoadingImpl implements StudentLoading {
  const _$StudentLoadingImpl();

  @override
  String toString() {
    return 'StudentState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$StudentLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Student> students, List<Group> groups)
    loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Student> students, List<Group> groups)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Student> students, List<Group> groups)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StudentInitial value) initial,
    required TResult Function(StudentLoading value) loading,
    required TResult Function(StudentLoaded value) loaded,
    required TResult Function(StudentError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StudentInitial value)? initial,
    TResult? Function(StudentLoading value)? loading,
    TResult? Function(StudentLoaded value)? loaded,
    TResult? Function(StudentError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StudentInitial value)? initial,
    TResult Function(StudentLoading value)? loading,
    TResult Function(StudentLoaded value)? loaded,
    TResult Function(StudentError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class StudentLoading implements StudentState {
  const factory StudentLoading() = _$StudentLoadingImpl;
}

/// @nodoc
abstract class _$$StudentLoadedImplCopyWith<$Res> {
  factory _$$StudentLoadedImplCopyWith(
    _$StudentLoadedImpl value,
    $Res Function(_$StudentLoadedImpl) then,
  ) = __$$StudentLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Student> students, List<Group> groups});
}

/// @nodoc
class __$$StudentLoadedImplCopyWithImpl<$Res>
    extends _$StudentStateCopyWithImpl<$Res, _$StudentLoadedImpl>
    implements _$$StudentLoadedImplCopyWith<$Res> {
  __$$StudentLoadedImplCopyWithImpl(
    _$StudentLoadedImpl _value,
    $Res Function(_$StudentLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? students = null, Object? groups = null}) {
    return _then(
      _$StudentLoadedImpl(
        students: null == students
            ? _value._students
            : students // ignore: cast_nullable_to_non_nullable
                  as List<Student>,
        groups: null == groups
            ? _value._groups
            : groups // ignore: cast_nullable_to_non_nullable
                  as List<Group>,
      ),
    );
  }
}

/// @nodoc

class _$StudentLoadedImpl implements StudentLoaded {
  const _$StudentLoadedImpl({
    required final List<Student> students,
    required final List<Group> groups,
  }) : _students = students,
       _groups = groups;

  final List<Student> _students;
  @override
  List<Student> get students {
    if (_students is EqualUnmodifiableListView) return _students;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_students);
  }

  final List<Group> _groups;
  @override
  List<Group> get groups {
    if (_groups is EqualUnmodifiableListView) return _groups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groups);
  }

  @override
  String toString() {
    return 'StudentState.loaded(students: $students, groups: $groups)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentLoadedImpl &&
            const DeepCollectionEquality().equals(other._students, _students) &&
            const DeepCollectionEquality().equals(other._groups, _groups));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_students),
    const DeepCollectionEquality().hash(_groups),
  );

  /// Create a copy of StudentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentLoadedImplCopyWith<_$StudentLoadedImpl> get copyWith =>
      __$$StudentLoadedImplCopyWithImpl<_$StudentLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Student> students, List<Group> groups)
    loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(students, groups);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Student> students, List<Group> groups)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(students, groups);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Student> students, List<Group> groups)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(students, groups);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StudentInitial value) initial,
    required TResult Function(StudentLoading value) loading,
    required TResult Function(StudentLoaded value) loaded,
    required TResult Function(StudentError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StudentInitial value)? initial,
    TResult? Function(StudentLoading value)? loading,
    TResult? Function(StudentLoaded value)? loaded,
    TResult? Function(StudentError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StudentInitial value)? initial,
    TResult Function(StudentLoading value)? loading,
    TResult Function(StudentLoaded value)? loaded,
    TResult Function(StudentError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class StudentLoaded implements StudentState {
  const factory StudentLoaded({
    required final List<Student> students,
    required final List<Group> groups,
  }) = _$StudentLoadedImpl;

  List<Student> get students;
  List<Group> get groups;

  /// Create a copy of StudentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentLoadedImplCopyWith<_$StudentLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StudentErrorImplCopyWith<$Res> {
  factory _$$StudentErrorImplCopyWith(
    _$StudentErrorImpl value,
    $Res Function(_$StudentErrorImpl) then,
  ) = __$$StudentErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$StudentErrorImplCopyWithImpl<$Res>
    extends _$StudentStateCopyWithImpl<$Res, _$StudentErrorImpl>
    implements _$$StudentErrorImplCopyWith<$Res> {
  __$$StudentErrorImplCopyWithImpl(
    _$StudentErrorImpl _value,
    $Res Function(_$StudentErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$StudentErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$StudentErrorImpl implements StudentError {
  const _$StudentErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'StudentState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of StudentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentErrorImplCopyWith<_$StudentErrorImpl> get copyWith =>
      __$$StudentErrorImplCopyWithImpl<_$StudentErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Student> students, List<Group> groups)
    loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Student> students, List<Group> groups)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Student> students, List<Group> groups)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StudentInitial value) initial,
    required TResult Function(StudentLoading value) loading,
    required TResult Function(StudentLoaded value) loaded,
    required TResult Function(StudentError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StudentInitial value)? initial,
    TResult? Function(StudentLoading value)? loading,
    TResult? Function(StudentLoaded value)? loaded,
    TResult? Function(StudentError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StudentInitial value)? initial,
    TResult Function(StudentLoading value)? loading,
    TResult Function(StudentLoaded value)? loaded,
    TResult Function(StudentError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class StudentError implements StudentState {
  const factory StudentError({required final String message}) =
      _$StudentErrorImpl;

  String get message;

  /// Create a copy of StudentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentErrorImplCopyWith<_$StudentErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
