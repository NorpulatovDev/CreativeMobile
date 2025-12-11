// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GroupEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadAll,
    required TResult Function(String name, int teacherId, double monthlyFee)
    create,
    required TResult Function(
      int id,
      String name,
      int teacherId,
      double monthlyFee,
    )
    update,
    required TResult Function(int id) delete,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadAll,
    TResult? Function(String name, int teacherId, double monthlyFee)? create,
    TResult? Function(int id, String name, int teacherId, double monthlyFee)?
    update,
    TResult? Function(int id)? delete,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadAll,
    TResult Function(String name, int teacherId, double monthlyFee)? create,
    TResult Function(int id, String name, int teacherId, double monthlyFee)?
    update,
    TResult Function(int id)? delete,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GroupLoadAll value) loadAll,
    required TResult Function(GroupCreate value) create,
    required TResult Function(GroupUpdate value) update,
    required TResult Function(GroupDelete value) delete,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupLoadAll value)? loadAll,
    TResult? Function(GroupCreate value)? create,
    TResult? Function(GroupUpdate value)? update,
    TResult? Function(GroupDelete value)? delete,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupLoadAll value)? loadAll,
    TResult Function(GroupCreate value)? create,
    TResult Function(GroupUpdate value)? update,
    TResult Function(GroupDelete value)? delete,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupEventCopyWith<$Res> {
  factory $GroupEventCopyWith(
    GroupEvent value,
    $Res Function(GroupEvent) then,
  ) = _$GroupEventCopyWithImpl<$Res, GroupEvent>;
}

/// @nodoc
class _$GroupEventCopyWithImpl<$Res, $Val extends GroupEvent>
    implements $GroupEventCopyWith<$Res> {
  _$GroupEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$GroupLoadAllImplCopyWith<$Res> {
  factory _$$GroupLoadAllImplCopyWith(
    _$GroupLoadAllImpl value,
    $Res Function(_$GroupLoadAllImpl) then,
  ) = __$$GroupLoadAllImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GroupLoadAllImplCopyWithImpl<$Res>
    extends _$GroupEventCopyWithImpl<$Res, _$GroupLoadAllImpl>
    implements _$$GroupLoadAllImplCopyWith<$Res> {
  __$$GroupLoadAllImplCopyWithImpl(
    _$GroupLoadAllImpl _value,
    $Res Function(_$GroupLoadAllImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GroupLoadAllImpl implements GroupLoadAll {
  const _$GroupLoadAllImpl();

  @override
  String toString() {
    return 'GroupEvent.loadAll()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GroupLoadAllImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadAll,
    required TResult Function(String name, int teacherId, double monthlyFee)
    create,
    required TResult Function(
      int id,
      String name,
      int teacherId,
      double monthlyFee,
    )
    update,
    required TResult Function(int id) delete,
  }) {
    return loadAll();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadAll,
    TResult? Function(String name, int teacherId, double monthlyFee)? create,
    TResult? Function(int id, String name, int teacherId, double monthlyFee)?
    update,
    TResult? Function(int id)? delete,
  }) {
    return loadAll?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadAll,
    TResult Function(String name, int teacherId, double monthlyFee)? create,
    TResult Function(int id, String name, int teacherId, double monthlyFee)?
    update,
    TResult Function(int id)? delete,
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
    required TResult Function(GroupLoadAll value) loadAll,
    required TResult Function(GroupCreate value) create,
    required TResult Function(GroupUpdate value) update,
    required TResult Function(GroupDelete value) delete,
  }) {
    return loadAll(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupLoadAll value)? loadAll,
    TResult? Function(GroupCreate value)? create,
    TResult? Function(GroupUpdate value)? update,
    TResult? Function(GroupDelete value)? delete,
  }) {
    return loadAll?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupLoadAll value)? loadAll,
    TResult Function(GroupCreate value)? create,
    TResult Function(GroupUpdate value)? update,
    TResult Function(GroupDelete value)? delete,
    required TResult orElse(),
  }) {
    if (loadAll != null) {
      return loadAll(this);
    }
    return orElse();
  }
}

abstract class GroupLoadAll implements GroupEvent {
  const factory GroupLoadAll() = _$GroupLoadAllImpl;
}

/// @nodoc
abstract class _$$GroupCreateImplCopyWith<$Res> {
  factory _$$GroupCreateImplCopyWith(
    _$GroupCreateImpl value,
    $Res Function(_$GroupCreateImpl) then,
  ) = __$$GroupCreateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String name, int teacherId, double monthlyFee});
}

/// @nodoc
class __$$GroupCreateImplCopyWithImpl<$Res>
    extends _$GroupEventCopyWithImpl<$Res, _$GroupCreateImpl>
    implements _$$GroupCreateImplCopyWith<$Res> {
  __$$GroupCreateImplCopyWithImpl(
    _$GroupCreateImpl _value,
    $Res Function(_$GroupCreateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? teacherId = null,
    Object? monthlyFee = null,
  }) {
    return _then(
      _$GroupCreateImpl(
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

class _$GroupCreateImpl implements GroupCreate {
  const _$GroupCreateImpl({
    required this.name,
    required this.teacherId,
    required this.monthlyFee,
  });

  @override
  final String name;
  @override
  final int teacherId;
  @override
  final double monthlyFee;

  @override
  String toString() {
    return 'GroupEvent.create(name: $name, teacherId: $teacherId, monthlyFee: $monthlyFee)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupCreateImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.monthlyFee, monthlyFee) ||
                other.monthlyFee == monthlyFee));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, teacherId, monthlyFee);

  /// Create a copy of GroupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupCreateImplCopyWith<_$GroupCreateImpl> get copyWith =>
      __$$GroupCreateImplCopyWithImpl<_$GroupCreateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadAll,
    required TResult Function(String name, int teacherId, double monthlyFee)
    create,
    required TResult Function(
      int id,
      String name,
      int teacherId,
      double monthlyFee,
    )
    update,
    required TResult Function(int id) delete,
  }) {
    return create(name, teacherId, monthlyFee);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadAll,
    TResult? Function(String name, int teacherId, double monthlyFee)? create,
    TResult? Function(int id, String name, int teacherId, double monthlyFee)?
    update,
    TResult? Function(int id)? delete,
  }) {
    return create?.call(name, teacherId, monthlyFee);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadAll,
    TResult Function(String name, int teacherId, double monthlyFee)? create,
    TResult Function(int id, String name, int teacherId, double monthlyFee)?
    update,
    TResult Function(int id)? delete,
    required TResult orElse(),
  }) {
    if (create != null) {
      return create(name, teacherId, monthlyFee);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GroupLoadAll value) loadAll,
    required TResult Function(GroupCreate value) create,
    required TResult Function(GroupUpdate value) update,
    required TResult Function(GroupDelete value) delete,
  }) {
    return create(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupLoadAll value)? loadAll,
    TResult? Function(GroupCreate value)? create,
    TResult? Function(GroupUpdate value)? update,
    TResult? Function(GroupDelete value)? delete,
  }) {
    return create?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupLoadAll value)? loadAll,
    TResult Function(GroupCreate value)? create,
    TResult Function(GroupUpdate value)? update,
    TResult Function(GroupDelete value)? delete,
    required TResult orElse(),
  }) {
    if (create != null) {
      return create(this);
    }
    return orElse();
  }
}

abstract class GroupCreate implements GroupEvent {
  const factory GroupCreate({
    required final String name,
    required final int teacherId,
    required final double monthlyFee,
  }) = _$GroupCreateImpl;

  String get name;
  int get teacherId;
  double get monthlyFee;

  /// Create a copy of GroupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupCreateImplCopyWith<_$GroupCreateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GroupUpdateImplCopyWith<$Res> {
  factory _$$GroupUpdateImplCopyWith(
    _$GroupUpdateImpl value,
    $Res Function(_$GroupUpdateImpl) then,
  ) = __$$GroupUpdateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int id, String name, int teacherId, double monthlyFee});
}

/// @nodoc
class __$$GroupUpdateImplCopyWithImpl<$Res>
    extends _$GroupEventCopyWithImpl<$Res, _$GroupUpdateImpl>
    implements _$$GroupUpdateImplCopyWith<$Res> {
  __$$GroupUpdateImplCopyWithImpl(
    _$GroupUpdateImpl _value,
    $Res Function(_$GroupUpdateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? teacherId = null,
    Object? monthlyFee = null,
  }) {
    return _then(
      _$GroupUpdateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
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

class _$GroupUpdateImpl implements GroupUpdate {
  const _$GroupUpdateImpl({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.monthlyFee,
  });

  @override
  final int id;
  @override
  final String name;
  @override
  final int teacherId;
  @override
  final double monthlyFee;

  @override
  String toString() {
    return 'GroupEvent.update(id: $id, name: $name, teacherId: $teacherId, monthlyFee: $monthlyFee)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupUpdateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.monthlyFee, monthlyFee) ||
                other.monthlyFee == monthlyFee));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, teacherId, monthlyFee);

  /// Create a copy of GroupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupUpdateImplCopyWith<_$GroupUpdateImpl> get copyWith =>
      __$$GroupUpdateImplCopyWithImpl<_$GroupUpdateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadAll,
    required TResult Function(String name, int teacherId, double monthlyFee)
    create,
    required TResult Function(
      int id,
      String name,
      int teacherId,
      double monthlyFee,
    )
    update,
    required TResult Function(int id) delete,
  }) {
    return update(id, name, teacherId, monthlyFee);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadAll,
    TResult? Function(String name, int teacherId, double monthlyFee)? create,
    TResult? Function(int id, String name, int teacherId, double monthlyFee)?
    update,
    TResult? Function(int id)? delete,
  }) {
    return update?.call(id, name, teacherId, monthlyFee);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadAll,
    TResult Function(String name, int teacherId, double monthlyFee)? create,
    TResult Function(int id, String name, int teacherId, double monthlyFee)?
    update,
    TResult Function(int id)? delete,
    required TResult orElse(),
  }) {
    if (update != null) {
      return update(id, name, teacherId, monthlyFee);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GroupLoadAll value) loadAll,
    required TResult Function(GroupCreate value) create,
    required TResult Function(GroupUpdate value) update,
    required TResult Function(GroupDelete value) delete,
  }) {
    return update(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupLoadAll value)? loadAll,
    TResult? Function(GroupCreate value)? create,
    TResult? Function(GroupUpdate value)? update,
    TResult? Function(GroupDelete value)? delete,
  }) {
    return update?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupLoadAll value)? loadAll,
    TResult Function(GroupCreate value)? create,
    TResult Function(GroupUpdate value)? update,
    TResult Function(GroupDelete value)? delete,
    required TResult orElse(),
  }) {
    if (update != null) {
      return update(this);
    }
    return orElse();
  }
}

abstract class GroupUpdate implements GroupEvent {
  const factory GroupUpdate({
    required final int id,
    required final String name,
    required final int teacherId,
    required final double monthlyFee,
  }) = _$GroupUpdateImpl;

  int get id;
  String get name;
  int get teacherId;
  double get monthlyFee;

  /// Create a copy of GroupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupUpdateImplCopyWith<_$GroupUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GroupDeleteImplCopyWith<$Res> {
  factory _$$GroupDeleteImplCopyWith(
    _$GroupDeleteImpl value,
    $Res Function(_$GroupDeleteImpl) then,
  ) = __$$GroupDeleteImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int id});
}

/// @nodoc
class __$$GroupDeleteImplCopyWithImpl<$Res>
    extends _$GroupEventCopyWithImpl<$Res, _$GroupDeleteImpl>
    implements _$$GroupDeleteImplCopyWith<$Res> {
  __$$GroupDeleteImplCopyWithImpl(
    _$GroupDeleteImpl _value,
    $Res Function(_$GroupDeleteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null}) {
    return _then(
      _$GroupDeleteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$GroupDeleteImpl implements GroupDelete {
  const _$GroupDeleteImpl({required this.id});

  @override
  final int id;

  @override
  String toString() {
    return 'GroupEvent.delete(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupDeleteImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of GroupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupDeleteImplCopyWith<_$GroupDeleteImpl> get copyWith =>
      __$$GroupDeleteImplCopyWithImpl<_$GroupDeleteImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadAll,
    required TResult Function(String name, int teacherId, double monthlyFee)
    create,
    required TResult Function(
      int id,
      String name,
      int teacherId,
      double monthlyFee,
    )
    update,
    required TResult Function(int id) delete,
  }) {
    return delete(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadAll,
    TResult? Function(String name, int teacherId, double monthlyFee)? create,
    TResult? Function(int id, String name, int teacherId, double monthlyFee)?
    update,
    TResult? Function(int id)? delete,
  }) {
    return delete?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadAll,
    TResult Function(String name, int teacherId, double monthlyFee)? create,
    TResult Function(int id, String name, int teacherId, double monthlyFee)?
    update,
    TResult Function(int id)? delete,
    required TResult orElse(),
  }) {
    if (delete != null) {
      return delete(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GroupLoadAll value) loadAll,
    required TResult Function(GroupCreate value) create,
    required TResult Function(GroupUpdate value) update,
    required TResult Function(GroupDelete value) delete,
  }) {
    return delete(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupLoadAll value)? loadAll,
    TResult? Function(GroupCreate value)? create,
    TResult? Function(GroupUpdate value)? update,
    TResult? Function(GroupDelete value)? delete,
  }) {
    return delete?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupLoadAll value)? loadAll,
    TResult Function(GroupCreate value)? create,
    TResult Function(GroupUpdate value)? update,
    TResult Function(GroupDelete value)? delete,
    required TResult orElse(),
  }) {
    if (delete != null) {
      return delete(this);
    }
    return orElse();
  }
}

abstract class GroupDelete implements GroupEvent {
  const factory GroupDelete({required final int id}) = _$GroupDeleteImpl;

  int get id;

  /// Create a copy of GroupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupDeleteImplCopyWith<_$GroupDeleteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GroupState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Group> groups, List<Teacher> teachers)
    loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Group> groups, List<Teacher> teachers)? loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Group> groups, List<Teacher> teachers)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GroupInitial value) initial,
    required TResult Function(GroupLoading value) loading,
    required TResult Function(GroupLoaded value) loaded,
    required TResult Function(GroupError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupInitial value)? initial,
    TResult? Function(GroupLoading value)? loading,
    TResult? Function(GroupLoaded value)? loaded,
    TResult? Function(GroupError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupInitial value)? initial,
    TResult Function(GroupLoading value)? loading,
    TResult Function(GroupLoaded value)? loaded,
    TResult Function(GroupError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupStateCopyWith<$Res> {
  factory $GroupStateCopyWith(
    GroupState value,
    $Res Function(GroupState) then,
  ) = _$GroupStateCopyWithImpl<$Res, GroupState>;
}

/// @nodoc
class _$GroupStateCopyWithImpl<$Res, $Val extends GroupState>
    implements $GroupStateCopyWith<$Res> {
  _$GroupStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$GroupInitialImplCopyWith<$Res> {
  factory _$$GroupInitialImplCopyWith(
    _$GroupInitialImpl value,
    $Res Function(_$GroupInitialImpl) then,
  ) = __$$GroupInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GroupInitialImplCopyWithImpl<$Res>
    extends _$GroupStateCopyWithImpl<$Res, _$GroupInitialImpl>
    implements _$$GroupInitialImplCopyWith<$Res> {
  __$$GroupInitialImplCopyWithImpl(
    _$GroupInitialImpl _value,
    $Res Function(_$GroupInitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GroupInitialImpl implements GroupInitial {
  const _$GroupInitialImpl();

  @override
  String toString() {
    return 'GroupState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GroupInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Group> groups, List<Teacher> teachers)
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
    TResult? Function(List<Group> groups, List<Teacher> teachers)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Group> groups, List<Teacher> teachers)? loaded,
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
    required TResult Function(GroupInitial value) initial,
    required TResult Function(GroupLoading value) loading,
    required TResult Function(GroupLoaded value) loaded,
    required TResult Function(GroupError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupInitial value)? initial,
    TResult? Function(GroupLoading value)? loading,
    TResult? Function(GroupLoaded value)? loaded,
    TResult? Function(GroupError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupInitial value)? initial,
    TResult Function(GroupLoading value)? loading,
    TResult Function(GroupLoaded value)? loaded,
    TResult Function(GroupError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class GroupInitial implements GroupState {
  const factory GroupInitial() = _$GroupInitialImpl;
}

/// @nodoc
abstract class _$$GroupLoadingImplCopyWith<$Res> {
  factory _$$GroupLoadingImplCopyWith(
    _$GroupLoadingImpl value,
    $Res Function(_$GroupLoadingImpl) then,
  ) = __$$GroupLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GroupLoadingImplCopyWithImpl<$Res>
    extends _$GroupStateCopyWithImpl<$Res, _$GroupLoadingImpl>
    implements _$$GroupLoadingImplCopyWith<$Res> {
  __$$GroupLoadingImplCopyWithImpl(
    _$GroupLoadingImpl _value,
    $Res Function(_$GroupLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GroupLoadingImpl implements GroupLoading {
  const _$GroupLoadingImpl();

  @override
  String toString() {
    return 'GroupState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GroupLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Group> groups, List<Teacher> teachers)
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
    TResult? Function(List<Group> groups, List<Teacher> teachers)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Group> groups, List<Teacher> teachers)? loaded,
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
    required TResult Function(GroupInitial value) initial,
    required TResult Function(GroupLoading value) loading,
    required TResult Function(GroupLoaded value) loaded,
    required TResult Function(GroupError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupInitial value)? initial,
    TResult? Function(GroupLoading value)? loading,
    TResult? Function(GroupLoaded value)? loaded,
    TResult? Function(GroupError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupInitial value)? initial,
    TResult Function(GroupLoading value)? loading,
    TResult Function(GroupLoaded value)? loaded,
    TResult Function(GroupError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class GroupLoading implements GroupState {
  const factory GroupLoading() = _$GroupLoadingImpl;
}

/// @nodoc
abstract class _$$GroupLoadedImplCopyWith<$Res> {
  factory _$$GroupLoadedImplCopyWith(
    _$GroupLoadedImpl value,
    $Res Function(_$GroupLoadedImpl) then,
  ) = __$$GroupLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Group> groups, List<Teacher> teachers});
}

/// @nodoc
class __$$GroupLoadedImplCopyWithImpl<$Res>
    extends _$GroupStateCopyWithImpl<$Res, _$GroupLoadedImpl>
    implements _$$GroupLoadedImplCopyWith<$Res> {
  __$$GroupLoadedImplCopyWithImpl(
    _$GroupLoadedImpl _value,
    $Res Function(_$GroupLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? groups = null, Object? teachers = null}) {
    return _then(
      _$GroupLoadedImpl(
        groups: null == groups
            ? _value._groups
            : groups // ignore: cast_nullable_to_non_nullable
                  as List<Group>,
        teachers: null == teachers
            ? _value._teachers
            : teachers // ignore: cast_nullable_to_non_nullable
                  as List<Teacher>,
      ),
    );
  }
}

/// @nodoc

class _$GroupLoadedImpl implements GroupLoaded {
  const _$GroupLoadedImpl({
    required final List<Group> groups,
    required final List<Teacher> teachers,
  }) : _groups = groups,
       _teachers = teachers;

  final List<Group> _groups;
  @override
  List<Group> get groups {
    if (_groups is EqualUnmodifiableListView) return _groups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groups);
  }

  final List<Teacher> _teachers;
  @override
  List<Teacher> get teachers {
    if (_teachers is EqualUnmodifiableListView) return _teachers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_teachers);
  }

  @override
  String toString() {
    return 'GroupState.loaded(groups: $groups, teachers: $teachers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupLoadedImpl &&
            const DeepCollectionEquality().equals(other._groups, _groups) &&
            const DeepCollectionEquality().equals(other._teachers, _teachers));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_groups),
    const DeepCollectionEquality().hash(_teachers),
  );

  /// Create a copy of GroupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupLoadedImplCopyWith<_$GroupLoadedImpl> get copyWith =>
      __$$GroupLoadedImplCopyWithImpl<_$GroupLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Group> groups, List<Teacher> teachers)
    loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(groups, teachers);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Group> groups, List<Teacher> teachers)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(groups, teachers);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Group> groups, List<Teacher> teachers)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(groups, teachers);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GroupInitial value) initial,
    required TResult Function(GroupLoading value) loading,
    required TResult Function(GroupLoaded value) loaded,
    required TResult Function(GroupError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupInitial value)? initial,
    TResult? Function(GroupLoading value)? loading,
    TResult? Function(GroupLoaded value)? loaded,
    TResult? Function(GroupError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupInitial value)? initial,
    TResult Function(GroupLoading value)? loading,
    TResult Function(GroupLoaded value)? loaded,
    TResult Function(GroupError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class GroupLoaded implements GroupState {
  const factory GroupLoaded({
    required final List<Group> groups,
    required final List<Teacher> teachers,
  }) = _$GroupLoadedImpl;

  List<Group> get groups;
  List<Teacher> get teachers;

  /// Create a copy of GroupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupLoadedImplCopyWith<_$GroupLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GroupErrorImplCopyWith<$Res> {
  factory _$$GroupErrorImplCopyWith(
    _$GroupErrorImpl value,
    $Res Function(_$GroupErrorImpl) then,
  ) = __$$GroupErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$GroupErrorImplCopyWithImpl<$Res>
    extends _$GroupStateCopyWithImpl<$Res, _$GroupErrorImpl>
    implements _$$GroupErrorImplCopyWith<$Res> {
  __$$GroupErrorImplCopyWithImpl(
    _$GroupErrorImpl _value,
    $Res Function(_$GroupErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$GroupErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$GroupErrorImpl implements GroupError {
  const _$GroupErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'GroupState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of GroupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupErrorImplCopyWith<_$GroupErrorImpl> get copyWith =>
      __$$GroupErrorImplCopyWithImpl<_$GroupErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Group> groups, List<Teacher> teachers)
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
    TResult? Function(List<Group> groups, List<Teacher> teachers)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Group> groups, List<Teacher> teachers)? loaded,
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
    required TResult Function(GroupInitial value) initial,
    required TResult Function(GroupLoading value) loading,
    required TResult Function(GroupLoaded value) loaded,
    required TResult Function(GroupError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupInitial value)? initial,
    TResult? Function(GroupLoading value)? loading,
    TResult? Function(GroupLoaded value)? loaded,
    TResult? Function(GroupError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupInitial value)? initial,
    TResult Function(GroupLoading value)? loading,
    TResult Function(GroupLoaded value)? loaded,
    TResult Function(GroupError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class GroupError implements GroupState {
  const factory GroupError({required final String message}) = _$GroupErrorImpl;

  String get message;

  /// Create a copy of GroupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupErrorImplCopyWith<_$GroupErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
