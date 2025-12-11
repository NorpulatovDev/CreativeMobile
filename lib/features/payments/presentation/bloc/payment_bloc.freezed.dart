// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PaymentEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadAll,
    required TResult Function(int? studentId) filterByStudent,
    required TResult Function(int? groupId) filterByGroup,
    required TResult Function(
      int studentId,
      int groupId,
      double amount,
      String paidForMonth,
    )
    create,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadAll,
    TResult? Function(int? studentId)? filterByStudent,
    TResult? Function(int? groupId)? filterByGroup,
    TResult? Function(
      int studentId,
      int groupId,
      double amount,
      String paidForMonth,
    )?
    create,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadAll,
    TResult Function(int? studentId)? filterByStudent,
    TResult Function(int? groupId)? filterByGroup,
    TResult Function(
      int studentId,
      int groupId,
      double amount,
      String paidForMonth,
    )?
    create,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentLoadAll value) loadAll,
    required TResult Function(PaymentFilterByStudent value) filterByStudent,
    required TResult Function(PaymentFilterByGroup value) filterByGroup,
    required TResult Function(PaymentCreate value) create,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentLoadAll value)? loadAll,
    TResult? Function(PaymentFilterByStudent value)? filterByStudent,
    TResult? Function(PaymentFilterByGroup value)? filterByGroup,
    TResult? Function(PaymentCreate value)? create,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentLoadAll value)? loadAll,
    TResult Function(PaymentFilterByStudent value)? filterByStudent,
    TResult Function(PaymentFilterByGroup value)? filterByGroup,
    TResult Function(PaymentCreate value)? create,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentEventCopyWith<$Res> {
  factory $PaymentEventCopyWith(
    PaymentEvent value,
    $Res Function(PaymentEvent) then,
  ) = _$PaymentEventCopyWithImpl<$Res, PaymentEvent>;
}

/// @nodoc
class _$PaymentEventCopyWithImpl<$Res, $Val extends PaymentEvent>
    implements $PaymentEventCopyWith<$Res> {
  _$PaymentEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$PaymentLoadAllImplCopyWith<$Res> {
  factory _$$PaymentLoadAllImplCopyWith(
    _$PaymentLoadAllImpl value,
    $Res Function(_$PaymentLoadAllImpl) then,
  ) = __$$PaymentLoadAllImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PaymentLoadAllImplCopyWithImpl<$Res>
    extends _$PaymentEventCopyWithImpl<$Res, _$PaymentLoadAllImpl>
    implements _$$PaymentLoadAllImplCopyWith<$Res> {
  __$$PaymentLoadAllImplCopyWithImpl(
    _$PaymentLoadAllImpl _value,
    $Res Function(_$PaymentLoadAllImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PaymentLoadAllImpl implements PaymentLoadAll {
  const _$PaymentLoadAllImpl();

  @override
  String toString() {
    return 'PaymentEvent.loadAll()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PaymentLoadAllImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadAll,
    required TResult Function(int? studentId) filterByStudent,
    required TResult Function(int? groupId) filterByGroup,
    required TResult Function(
      int studentId,
      int groupId,
      double amount,
      String paidForMonth,
    )
    create,
  }) {
    return loadAll();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadAll,
    TResult? Function(int? studentId)? filterByStudent,
    TResult? Function(int? groupId)? filterByGroup,
    TResult? Function(
      int studentId,
      int groupId,
      double amount,
      String paidForMonth,
    )?
    create,
  }) {
    return loadAll?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadAll,
    TResult Function(int? studentId)? filterByStudent,
    TResult Function(int? groupId)? filterByGroup,
    TResult Function(
      int studentId,
      int groupId,
      double amount,
      String paidForMonth,
    )?
    create,
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
    required TResult Function(PaymentLoadAll value) loadAll,
    required TResult Function(PaymentFilterByStudent value) filterByStudent,
    required TResult Function(PaymentFilterByGroup value) filterByGroup,
    required TResult Function(PaymentCreate value) create,
  }) {
    return loadAll(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentLoadAll value)? loadAll,
    TResult? Function(PaymentFilterByStudent value)? filterByStudent,
    TResult? Function(PaymentFilterByGroup value)? filterByGroup,
    TResult? Function(PaymentCreate value)? create,
  }) {
    return loadAll?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentLoadAll value)? loadAll,
    TResult Function(PaymentFilterByStudent value)? filterByStudent,
    TResult Function(PaymentFilterByGroup value)? filterByGroup,
    TResult Function(PaymentCreate value)? create,
    required TResult orElse(),
  }) {
    if (loadAll != null) {
      return loadAll(this);
    }
    return orElse();
  }
}

abstract class PaymentLoadAll implements PaymentEvent {
  const factory PaymentLoadAll() = _$PaymentLoadAllImpl;
}

/// @nodoc
abstract class _$$PaymentFilterByStudentImplCopyWith<$Res> {
  factory _$$PaymentFilterByStudentImplCopyWith(
    _$PaymentFilterByStudentImpl value,
    $Res Function(_$PaymentFilterByStudentImpl) then,
  ) = __$$PaymentFilterByStudentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int? studentId});
}

/// @nodoc
class __$$PaymentFilterByStudentImplCopyWithImpl<$Res>
    extends _$PaymentEventCopyWithImpl<$Res, _$PaymentFilterByStudentImpl>
    implements _$$PaymentFilterByStudentImplCopyWith<$Res> {
  __$$PaymentFilterByStudentImplCopyWithImpl(
    _$PaymentFilterByStudentImpl _value,
    $Res Function(_$PaymentFilterByStudentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? studentId = freezed}) {
    return _then(
      _$PaymentFilterByStudentImpl(
        studentId: freezed == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$PaymentFilterByStudentImpl implements PaymentFilterByStudent {
  const _$PaymentFilterByStudentImpl({required this.studentId});

  @override
  final int? studentId;

  @override
  String toString() {
    return 'PaymentEvent.filterByStudent(studentId: $studentId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentFilterByStudentImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, studentId);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentFilterByStudentImplCopyWith<_$PaymentFilterByStudentImpl>
  get copyWith =>
      __$$PaymentFilterByStudentImplCopyWithImpl<_$PaymentFilterByStudentImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadAll,
    required TResult Function(int? studentId) filterByStudent,
    required TResult Function(int? groupId) filterByGroup,
    required TResult Function(
      int studentId,
      int groupId,
      double amount,
      String paidForMonth,
    )
    create,
  }) {
    return filterByStudent(studentId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadAll,
    TResult? Function(int? studentId)? filterByStudent,
    TResult? Function(int? groupId)? filterByGroup,
    TResult? Function(
      int studentId,
      int groupId,
      double amount,
      String paidForMonth,
    )?
    create,
  }) {
    return filterByStudent?.call(studentId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadAll,
    TResult Function(int? studentId)? filterByStudent,
    TResult Function(int? groupId)? filterByGroup,
    TResult Function(
      int studentId,
      int groupId,
      double amount,
      String paidForMonth,
    )?
    create,
    required TResult orElse(),
  }) {
    if (filterByStudent != null) {
      return filterByStudent(studentId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentLoadAll value) loadAll,
    required TResult Function(PaymentFilterByStudent value) filterByStudent,
    required TResult Function(PaymentFilterByGroup value) filterByGroup,
    required TResult Function(PaymentCreate value) create,
  }) {
    return filterByStudent(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentLoadAll value)? loadAll,
    TResult? Function(PaymentFilterByStudent value)? filterByStudent,
    TResult? Function(PaymentFilterByGroup value)? filterByGroup,
    TResult? Function(PaymentCreate value)? create,
  }) {
    return filterByStudent?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentLoadAll value)? loadAll,
    TResult Function(PaymentFilterByStudent value)? filterByStudent,
    TResult Function(PaymentFilterByGroup value)? filterByGroup,
    TResult Function(PaymentCreate value)? create,
    required TResult orElse(),
  }) {
    if (filterByStudent != null) {
      return filterByStudent(this);
    }
    return orElse();
  }
}

abstract class PaymentFilterByStudent implements PaymentEvent {
  const factory PaymentFilterByStudent({required final int? studentId}) =
      _$PaymentFilterByStudentImpl;

  int? get studentId;

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentFilterByStudentImplCopyWith<_$PaymentFilterByStudentImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PaymentFilterByGroupImplCopyWith<$Res> {
  factory _$$PaymentFilterByGroupImplCopyWith(
    _$PaymentFilterByGroupImpl value,
    $Res Function(_$PaymentFilterByGroupImpl) then,
  ) = __$$PaymentFilterByGroupImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int? groupId});
}

/// @nodoc
class __$$PaymentFilterByGroupImplCopyWithImpl<$Res>
    extends _$PaymentEventCopyWithImpl<$Res, _$PaymentFilterByGroupImpl>
    implements _$$PaymentFilterByGroupImplCopyWith<$Res> {
  __$$PaymentFilterByGroupImplCopyWithImpl(
    _$PaymentFilterByGroupImpl _value,
    $Res Function(_$PaymentFilterByGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? groupId = freezed}) {
    return _then(
      _$PaymentFilterByGroupImpl(
        groupId: freezed == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$PaymentFilterByGroupImpl implements PaymentFilterByGroup {
  const _$PaymentFilterByGroupImpl({required this.groupId});

  @override
  final int? groupId;

  @override
  String toString() {
    return 'PaymentEvent.filterByGroup(groupId: $groupId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentFilterByGroupImpl &&
            (identical(other.groupId, groupId) || other.groupId == groupId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, groupId);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentFilterByGroupImplCopyWith<_$PaymentFilterByGroupImpl>
  get copyWith =>
      __$$PaymentFilterByGroupImplCopyWithImpl<_$PaymentFilterByGroupImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadAll,
    required TResult Function(int? studentId) filterByStudent,
    required TResult Function(int? groupId) filterByGroup,
    required TResult Function(
      int studentId,
      int groupId,
      double amount,
      String paidForMonth,
    )
    create,
  }) {
    return filterByGroup(groupId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadAll,
    TResult? Function(int? studentId)? filterByStudent,
    TResult? Function(int? groupId)? filterByGroup,
    TResult? Function(
      int studentId,
      int groupId,
      double amount,
      String paidForMonth,
    )?
    create,
  }) {
    return filterByGroup?.call(groupId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadAll,
    TResult Function(int? studentId)? filterByStudent,
    TResult Function(int? groupId)? filterByGroup,
    TResult Function(
      int studentId,
      int groupId,
      double amount,
      String paidForMonth,
    )?
    create,
    required TResult orElse(),
  }) {
    if (filterByGroup != null) {
      return filterByGroup(groupId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentLoadAll value) loadAll,
    required TResult Function(PaymentFilterByStudent value) filterByStudent,
    required TResult Function(PaymentFilterByGroup value) filterByGroup,
    required TResult Function(PaymentCreate value) create,
  }) {
    return filterByGroup(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentLoadAll value)? loadAll,
    TResult? Function(PaymentFilterByStudent value)? filterByStudent,
    TResult? Function(PaymentFilterByGroup value)? filterByGroup,
    TResult? Function(PaymentCreate value)? create,
  }) {
    return filterByGroup?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentLoadAll value)? loadAll,
    TResult Function(PaymentFilterByStudent value)? filterByStudent,
    TResult Function(PaymentFilterByGroup value)? filterByGroup,
    TResult Function(PaymentCreate value)? create,
    required TResult orElse(),
  }) {
    if (filterByGroup != null) {
      return filterByGroup(this);
    }
    return orElse();
  }
}

abstract class PaymentFilterByGroup implements PaymentEvent {
  const factory PaymentFilterByGroup({required final int? groupId}) =
      _$PaymentFilterByGroupImpl;

  int? get groupId;

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentFilterByGroupImplCopyWith<_$PaymentFilterByGroupImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PaymentCreateImplCopyWith<$Res> {
  factory _$$PaymentCreateImplCopyWith(
    _$PaymentCreateImpl value,
    $Res Function(_$PaymentCreateImpl) then,
  ) = __$$PaymentCreateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int studentId, int groupId, double amount, String paidForMonth});
}

/// @nodoc
class __$$PaymentCreateImplCopyWithImpl<$Res>
    extends _$PaymentEventCopyWithImpl<$Res, _$PaymentCreateImpl>
    implements _$$PaymentCreateImplCopyWith<$Res> {
  __$$PaymentCreateImplCopyWithImpl(
    _$PaymentCreateImpl _value,
    $Res Function(_$PaymentCreateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? groupId = null,
    Object? amount = null,
    Object? paidForMonth = null,
  }) {
    return _then(
      _$PaymentCreateImpl(
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as int,
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as int,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        paidForMonth: null == paidForMonth
            ? _value.paidForMonth
            : paidForMonth // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PaymentCreateImpl implements PaymentCreate {
  const _$PaymentCreateImpl({
    required this.studentId,
    required this.groupId,
    required this.amount,
    required this.paidForMonth,
  });

  @override
  final int studentId;
  @override
  final int groupId;
  @override
  final double amount;
  @override
  final String paidForMonth;

  @override
  String toString() {
    return 'PaymentEvent.create(studentId: $studentId, groupId: $groupId, amount: $amount, paidForMonth: $paidForMonth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentCreateImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.paidForMonth, paidForMonth) ||
                other.paidForMonth == paidForMonth));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, studentId, groupId, amount, paidForMonth);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentCreateImplCopyWith<_$PaymentCreateImpl> get copyWith =>
      __$$PaymentCreateImplCopyWithImpl<_$PaymentCreateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadAll,
    required TResult Function(int? studentId) filterByStudent,
    required TResult Function(int? groupId) filterByGroup,
    required TResult Function(
      int studentId,
      int groupId,
      double amount,
      String paidForMonth,
    )
    create,
  }) {
    return create(studentId, groupId, amount, paidForMonth);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadAll,
    TResult? Function(int? studentId)? filterByStudent,
    TResult? Function(int? groupId)? filterByGroup,
    TResult? Function(
      int studentId,
      int groupId,
      double amount,
      String paidForMonth,
    )?
    create,
  }) {
    return create?.call(studentId, groupId, amount, paidForMonth);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadAll,
    TResult Function(int? studentId)? filterByStudent,
    TResult Function(int? groupId)? filterByGroup,
    TResult Function(
      int studentId,
      int groupId,
      double amount,
      String paidForMonth,
    )?
    create,
    required TResult orElse(),
  }) {
    if (create != null) {
      return create(studentId, groupId, amount, paidForMonth);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentLoadAll value) loadAll,
    required TResult Function(PaymentFilterByStudent value) filterByStudent,
    required TResult Function(PaymentFilterByGroup value) filterByGroup,
    required TResult Function(PaymentCreate value) create,
  }) {
    return create(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentLoadAll value)? loadAll,
    TResult? Function(PaymentFilterByStudent value)? filterByStudent,
    TResult? Function(PaymentFilterByGroup value)? filterByGroup,
    TResult? Function(PaymentCreate value)? create,
  }) {
    return create?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentLoadAll value)? loadAll,
    TResult Function(PaymentFilterByStudent value)? filterByStudent,
    TResult Function(PaymentFilterByGroup value)? filterByGroup,
    TResult Function(PaymentCreate value)? create,
    required TResult orElse(),
  }) {
    if (create != null) {
      return create(this);
    }
    return orElse();
  }
}

abstract class PaymentCreate implements PaymentEvent {
  const factory PaymentCreate({
    required final int studentId,
    required final int groupId,
    required final double amount,
    required final String paidForMonth,
  }) = _$PaymentCreateImpl;

  int get studentId;
  int get groupId;
  double get amount;
  String get paidForMonth;

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentCreateImplCopyWith<_$PaymentCreateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PaymentState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )
    loaded,
    required TResult Function() saving,
    required TResult Function() saved,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )?
    loaded,
    TResult? Function()? saving,
    TResult? Function()? saved,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )?
    loaded,
    TResult Function()? saving,
    TResult Function()? saved,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitial value) initial,
    required TResult Function(PaymentLoading value) loading,
    required TResult Function(PaymentLoaded value) loaded,
    required TResult Function(PaymentSaving value) saving,
    required TResult Function(PaymentSaved value) saved,
    required TResult Function(PaymentError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitial value)? initial,
    TResult? Function(PaymentLoading value)? loading,
    TResult? Function(PaymentLoaded value)? loaded,
    TResult? Function(PaymentSaving value)? saving,
    TResult? Function(PaymentSaved value)? saved,
    TResult? Function(PaymentError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitial value)? initial,
    TResult Function(PaymentLoading value)? loading,
    TResult Function(PaymentLoaded value)? loaded,
    TResult Function(PaymentSaving value)? saving,
    TResult Function(PaymentSaved value)? saved,
    TResult Function(PaymentError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentStateCopyWith<$Res> {
  factory $PaymentStateCopyWith(
    PaymentState value,
    $Res Function(PaymentState) then,
  ) = _$PaymentStateCopyWithImpl<$Res, PaymentState>;
}

/// @nodoc
class _$PaymentStateCopyWithImpl<$Res, $Val extends PaymentState>
    implements $PaymentStateCopyWith<$Res> {
  _$PaymentStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$PaymentInitialImplCopyWith<$Res> {
  factory _$$PaymentInitialImplCopyWith(
    _$PaymentInitialImpl value,
    $Res Function(_$PaymentInitialImpl) then,
  ) = __$$PaymentInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PaymentInitialImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$PaymentInitialImpl>
    implements _$$PaymentInitialImplCopyWith<$Res> {
  __$$PaymentInitialImplCopyWithImpl(
    _$PaymentInitialImpl _value,
    $Res Function(_$PaymentInitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PaymentInitialImpl implements PaymentInitial {
  const _$PaymentInitialImpl();

  @override
  String toString() {
    return 'PaymentState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PaymentInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )
    loaded,
    required TResult Function() saving,
    required TResult Function() saved,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )?
    loaded,
    TResult? Function()? saving,
    TResult? Function()? saved,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )?
    loaded,
    TResult Function()? saving,
    TResult Function()? saved,
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
    required TResult Function(PaymentInitial value) initial,
    required TResult Function(PaymentLoading value) loading,
    required TResult Function(PaymentLoaded value) loaded,
    required TResult Function(PaymentSaving value) saving,
    required TResult Function(PaymentSaved value) saved,
    required TResult Function(PaymentError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitial value)? initial,
    TResult? Function(PaymentLoading value)? loading,
    TResult? Function(PaymentLoaded value)? loaded,
    TResult? Function(PaymentSaving value)? saving,
    TResult? Function(PaymentSaved value)? saved,
    TResult? Function(PaymentError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitial value)? initial,
    TResult Function(PaymentLoading value)? loading,
    TResult Function(PaymentLoaded value)? loaded,
    TResult Function(PaymentSaving value)? saving,
    TResult Function(PaymentSaved value)? saved,
    TResult Function(PaymentError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class PaymentInitial implements PaymentState {
  const factory PaymentInitial() = _$PaymentInitialImpl;
}

/// @nodoc
abstract class _$$PaymentLoadingImplCopyWith<$Res> {
  factory _$$PaymentLoadingImplCopyWith(
    _$PaymentLoadingImpl value,
    $Res Function(_$PaymentLoadingImpl) then,
  ) = __$$PaymentLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PaymentLoadingImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$PaymentLoadingImpl>
    implements _$$PaymentLoadingImplCopyWith<$Res> {
  __$$PaymentLoadingImplCopyWithImpl(
    _$PaymentLoadingImpl _value,
    $Res Function(_$PaymentLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PaymentLoadingImpl implements PaymentLoading {
  const _$PaymentLoadingImpl();

  @override
  String toString() {
    return 'PaymentState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PaymentLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )
    loaded,
    required TResult Function() saving,
    required TResult Function() saved,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )?
    loaded,
    TResult? Function()? saving,
    TResult? Function()? saved,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )?
    loaded,
    TResult Function()? saving,
    TResult Function()? saved,
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
    required TResult Function(PaymentInitial value) initial,
    required TResult Function(PaymentLoading value) loading,
    required TResult Function(PaymentLoaded value) loaded,
    required TResult Function(PaymentSaving value) saving,
    required TResult Function(PaymentSaved value) saved,
    required TResult Function(PaymentError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitial value)? initial,
    TResult? Function(PaymentLoading value)? loading,
    TResult? Function(PaymentLoaded value)? loaded,
    TResult? Function(PaymentSaving value)? saving,
    TResult? Function(PaymentSaved value)? saved,
    TResult? Function(PaymentError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitial value)? initial,
    TResult Function(PaymentLoading value)? loading,
    TResult Function(PaymentLoaded value)? loaded,
    TResult Function(PaymentSaving value)? saving,
    TResult Function(PaymentSaved value)? saved,
    TResult Function(PaymentError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class PaymentLoading implements PaymentState {
  const factory PaymentLoading() = _$PaymentLoadingImpl;
}

/// @nodoc
abstract class _$$PaymentLoadedImplCopyWith<$Res> {
  factory _$$PaymentLoadedImplCopyWith(
    _$PaymentLoadedImpl value,
    $Res Function(_$PaymentLoadedImpl) then,
  ) = __$$PaymentLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    List<Payment> payments,
    List<Payment> filteredPayments,
    List<Student> students,
    List<Group> groups,
    int? selectedStudentId,
    int? selectedGroupId,
  });
}

/// @nodoc
class __$$PaymentLoadedImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$PaymentLoadedImpl>
    implements _$$PaymentLoadedImplCopyWith<$Res> {
  __$$PaymentLoadedImplCopyWithImpl(
    _$PaymentLoadedImpl _value,
    $Res Function(_$PaymentLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? payments = null,
    Object? filteredPayments = null,
    Object? students = null,
    Object? groups = null,
    Object? selectedStudentId = freezed,
    Object? selectedGroupId = freezed,
  }) {
    return _then(
      _$PaymentLoadedImpl(
        payments: null == payments
            ? _value._payments
            : payments // ignore: cast_nullable_to_non_nullable
                  as List<Payment>,
        filteredPayments: null == filteredPayments
            ? _value._filteredPayments
            : filteredPayments // ignore: cast_nullable_to_non_nullable
                  as List<Payment>,
        students: null == students
            ? _value._students
            : students // ignore: cast_nullable_to_non_nullable
                  as List<Student>,
        groups: null == groups
            ? _value._groups
            : groups // ignore: cast_nullable_to_non_nullable
                  as List<Group>,
        selectedStudentId: freezed == selectedStudentId
            ? _value.selectedStudentId
            : selectedStudentId // ignore: cast_nullable_to_non_nullable
                  as int?,
        selectedGroupId: freezed == selectedGroupId
            ? _value.selectedGroupId
            : selectedGroupId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$PaymentLoadedImpl implements PaymentLoaded {
  const _$PaymentLoadedImpl({
    required final List<Payment> payments,
    required final List<Payment> filteredPayments,
    required final List<Student> students,
    required final List<Group> groups,
    this.selectedStudentId,
    this.selectedGroupId,
  }) : _payments = payments,
       _filteredPayments = filteredPayments,
       _students = students,
       _groups = groups;

  final List<Payment> _payments;
  @override
  List<Payment> get payments {
    if (_payments is EqualUnmodifiableListView) return _payments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_payments);
  }

  final List<Payment> _filteredPayments;
  @override
  List<Payment> get filteredPayments {
    if (_filteredPayments is EqualUnmodifiableListView)
      return _filteredPayments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredPayments);
  }

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
  final int? selectedStudentId;
  @override
  final int? selectedGroupId;

  @override
  String toString() {
    return 'PaymentState.loaded(payments: $payments, filteredPayments: $filteredPayments, students: $students, groups: $groups, selectedStudentId: $selectedStudentId, selectedGroupId: $selectedGroupId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentLoadedImpl &&
            const DeepCollectionEquality().equals(other._payments, _payments) &&
            const DeepCollectionEquality().equals(
              other._filteredPayments,
              _filteredPayments,
            ) &&
            const DeepCollectionEquality().equals(other._students, _students) &&
            const DeepCollectionEquality().equals(other._groups, _groups) &&
            (identical(other.selectedStudentId, selectedStudentId) ||
                other.selectedStudentId == selectedStudentId) &&
            (identical(other.selectedGroupId, selectedGroupId) ||
                other.selectedGroupId == selectedGroupId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_payments),
    const DeepCollectionEquality().hash(_filteredPayments),
    const DeepCollectionEquality().hash(_students),
    const DeepCollectionEquality().hash(_groups),
    selectedStudentId,
    selectedGroupId,
  );

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentLoadedImplCopyWith<_$PaymentLoadedImpl> get copyWith =>
      __$$PaymentLoadedImplCopyWithImpl<_$PaymentLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )
    loaded,
    required TResult Function() saving,
    required TResult Function() saved,
    required TResult Function(String message) error,
  }) {
    return loaded(
      payments,
      filteredPayments,
      students,
      groups,
      selectedStudentId,
      selectedGroupId,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )?
    loaded,
    TResult? Function()? saving,
    TResult? Function()? saved,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(
      payments,
      filteredPayments,
      students,
      groups,
      selectedStudentId,
      selectedGroupId,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )?
    loaded,
    TResult Function()? saving,
    TResult Function()? saved,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(
        payments,
        filteredPayments,
        students,
        groups,
        selectedStudentId,
        selectedGroupId,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitial value) initial,
    required TResult Function(PaymentLoading value) loading,
    required TResult Function(PaymentLoaded value) loaded,
    required TResult Function(PaymentSaving value) saving,
    required TResult Function(PaymentSaved value) saved,
    required TResult Function(PaymentError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitial value)? initial,
    TResult? Function(PaymentLoading value)? loading,
    TResult? Function(PaymentLoaded value)? loaded,
    TResult? Function(PaymentSaving value)? saving,
    TResult? Function(PaymentSaved value)? saved,
    TResult? Function(PaymentError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitial value)? initial,
    TResult Function(PaymentLoading value)? loading,
    TResult Function(PaymentLoaded value)? loaded,
    TResult Function(PaymentSaving value)? saving,
    TResult Function(PaymentSaved value)? saved,
    TResult Function(PaymentError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class PaymentLoaded implements PaymentState {
  const factory PaymentLoaded({
    required final List<Payment> payments,
    required final List<Payment> filteredPayments,
    required final List<Student> students,
    required final List<Group> groups,
    final int? selectedStudentId,
    final int? selectedGroupId,
  }) = _$PaymentLoadedImpl;

  List<Payment> get payments;
  List<Payment> get filteredPayments;
  List<Student> get students;
  List<Group> get groups;
  int? get selectedStudentId;
  int? get selectedGroupId;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentLoadedImplCopyWith<_$PaymentLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PaymentSavingImplCopyWith<$Res> {
  factory _$$PaymentSavingImplCopyWith(
    _$PaymentSavingImpl value,
    $Res Function(_$PaymentSavingImpl) then,
  ) = __$$PaymentSavingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PaymentSavingImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$PaymentSavingImpl>
    implements _$$PaymentSavingImplCopyWith<$Res> {
  __$$PaymentSavingImplCopyWithImpl(
    _$PaymentSavingImpl _value,
    $Res Function(_$PaymentSavingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PaymentSavingImpl implements PaymentSaving {
  const _$PaymentSavingImpl();

  @override
  String toString() {
    return 'PaymentState.saving()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PaymentSavingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )
    loaded,
    required TResult Function() saving,
    required TResult Function() saved,
    required TResult Function(String message) error,
  }) {
    return saving();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )?
    loaded,
    TResult? Function()? saving,
    TResult? Function()? saved,
    TResult? Function(String message)? error,
  }) {
    return saving?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )?
    loaded,
    TResult Function()? saving,
    TResult Function()? saved,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (saving != null) {
      return saving();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitial value) initial,
    required TResult Function(PaymentLoading value) loading,
    required TResult Function(PaymentLoaded value) loaded,
    required TResult Function(PaymentSaving value) saving,
    required TResult Function(PaymentSaved value) saved,
    required TResult Function(PaymentError value) error,
  }) {
    return saving(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitial value)? initial,
    TResult? Function(PaymentLoading value)? loading,
    TResult? Function(PaymentLoaded value)? loaded,
    TResult? Function(PaymentSaving value)? saving,
    TResult? Function(PaymentSaved value)? saved,
    TResult? Function(PaymentError value)? error,
  }) {
    return saving?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitial value)? initial,
    TResult Function(PaymentLoading value)? loading,
    TResult Function(PaymentLoaded value)? loaded,
    TResult Function(PaymentSaving value)? saving,
    TResult Function(PaymentSaved value)? saved,
    TResult Function(PaymentError value)? error,
    required TResult orElse(),
  }) {
    if (saving != null) {
      return saving(this);
    }
    return orElse();
  }
}

abstract class PaymentSaving implements PaymentState {
  const factory PaymentSaving() = _$PaymentSavingImpl;
}

/// @nodoc
abstract class _$$PaymentSavedImplCopyWith<$Res> {
  factory _$$PaymentSavedImplCopyWith(
    _$PaymentSavedImpl value,
    $Res Function(_$PaymentSavedImpl) then,
  ) = __$$PaymentSavedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PaymentSavedImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$PaymentSavedImpl>
    implements _$$PaymentSavedImplCopyWith<$Res> {
  __$$PaymentSavedImplCopyWithImpl(
    _$PaymentSavedImpl _value,
    $Res Function(_$PaymentSavedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PaymentSavedImpl implements PaymentSaved {
  const _$PaymentSavedImpl();

  @override
  String toString() {
    return 'PaymentState.saved()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PaymentSavedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )
    loaded,
    required TResult Function() saving,
    required TResult Function() saved,
    required TResult Function(String message) error,
  }) {
    return saved();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )?
    loaded,
    TResult? Function()? saving,
    TResult? Function()? saved,
    TResult? Function(String message)? error,
  }) {
    return saved?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )?
    loaded,
    TResult Function()? saving,
    TResult Function()? saved,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (saved != null) {
      return saved();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitial value) initial,
    required TResult Function(PaymentLoading value) loading,
    required TResult Function(PaymentLoaded value) loaded,
    required TResult Function(PaymentSaving value) saving,
    required TResult Function(PaymentSaved value) saved,
    required TResult Function(PaymentError value) error,
  }) {
    return saved(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitial value)? initial,
    TResult? Function(PaymentLoading value)? loading,
    TResult? Function(PaymentLoaded value)? loaded,
    TResult? Function(PaymentSaving value)? saving,
    TResult? Function(PaymentSaved value)? saved,
    TResult? Function(PaymentError value)? error,
  }) {
    return saved?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitial value)? initial,
    TResult Function(PaymentLoading value)? loading,
    TResult Function(PaymentLoaded value)? loaded,
    TResult Function(PaymentSaving value)? saving,
    TResult Function(PaymentSaved value)? saved,
    TResult Function(PaymentError value)? error,
    required TResult orElse(),
  }) {
    if (saved != null) {
      return saved(this);
    }
    return orElse();
  }
}

abstract class PaymentSaved implements PaymentState {
  const factory PaymentSaved() = _$PaymentSavedImpl;
}

/// @nodoc
abstract class _$$PaymentErrorImplCopyWith<$Res> {
  factory _$$PaymentErrorImplCopyWith(
    _$PaymentErrorImpl value,
    $Res Function(_$PaymentErrorImpl) then,
  ) = __$$PaymentErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$PaymentErrorImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$PaymentErrorImpl>
    implements _$$PaymentErrorImplCopyWith<$Res> {
  __$$PaymentErrorImplCopyWithImpl(
    _$PaymentErrorImpl _value,
    $Res Function(_$PaymentErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$PaymentErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PaymentErrorImpl implements PaymentError {
  const _$PaymentErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'PaymentState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentErrorImplCopyWith<_$PaymentErrorImpl> get copyWith =>
      __$$PaymentErrorImplCopyWithImpl<_$PaymentErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )
    loaded,
    required TResult Function() saving,
    required TResult Function() saved,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )?
    loaded,
    TResult? Function()? saving,
    TResult? Function()? saved,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<Payment> payments,
      List<Payment> filteredPayments,
      List<Student> students,
      List<Group> groups,
      int? selectedStudentId,
      int? selectedGroupId,
    )?
    loaded,
    TResult Function()? saving,
    TResult Function()? saved,
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
    required TResult Function(PaymentInitial value) initial,
    required TResult Function(PaymentLoading value) loading,
    required TResult Function(PaymentLoaded value) loaded,
    required TResult Function(PaymentSaving value) saving,
    required TResult Function(PaymentSaved value) saved,
    required TResult Function(PaymentError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitial value)? initial,
    TResult? Function(PaymentLoading value)? loading,
    TResult? Function(PaymentLoaded value)? loaded,
    TResult? Function(PaymentSaving value)? saving,
    TResult? Function(PaymentSaved value)? saved,
    TResult? Function(PaymentError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitial value)? initial,
    TResult Function(PaymentLoading value)? loading,
    TResult Function(PaymentLoaded value)? loaded,
    TResult Function(PaymentSaving value)? saving,
    TResult Function(PaymentSaved value)? saved,
    TResult Function(PaymentError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class PaymentError implements PaymentState {
  const factory PaymentError({required final String message}) =
      _$PaymentErrorImpl;

  String get message;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentErrorImplCopyWith<_$PaymentErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
