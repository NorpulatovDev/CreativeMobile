import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/inquiry_model.dart';
import '../../data/repositories/inquiry_repository.dart';

// Events
abstract class InquiryEvent extends Equatable {
  const InquiryEvent();

  @override
  List<Object?> get props => [];
}

class InquiryLoadAll extends InquiryEvent {}

class InquiryLoadByStatus extends InquiryEvent {
  final InquiryStatus status;

  const InquiryLoadByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class InquiryCreate extends InquiryEvent {
  final String fullName;
  final String parentName;
  final String parentPhoneNumber;
  final String? interestedCourses;
  final String? notes;

  const InquiryCreate({
    required this.fullName,
    required this.parentName,
    required this.parentPhoneNumber,
    this.interestedCourses,
    this.notes,
  });

  @override
  List<Object?> get props =>
      [fullName, parentName, parentPhoneNumber, interestedCourses, notes];
}

class InquiryUpdate extends InquiryEvent {
  final int id;
  final String fullName;
  final String parentName;
  final String parentPhoneNumber;
  final String? interestedCourses;
  final InquiryStatus status;
  final String? notes;

  const InquiryUpdate({
    required this.id,
    required this.fullName,
    required this.parentName,
    required this.parentPhoneNumber,
    this.interestedCourses,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        parentName,
        parentPhoneNumber,
        interestedCourses,
        status,
        notes
      ];
}

class InquiryDelete extends InquiryEvent {
  final int id;

  const InquiryDelete(this.id);

  @override
  List<Object?> get props => [id];
}

// States
abstract class InquiryState extends Equatable {
  const InquiryState();

  @override
  List<Object?> get props => [];
}

class InquiryInitial extends InquiryState {}

class InquiryLoading extends InquiryState {}

class InquiryLoaded extends InquiryState {
  final List<InquiryModel> inquiries;

  const InquiryLoaded(this.inquiries);

  @override
  List<Object?> get props => [inquiries];
}

class InquiryError extends InquiryState {
  final String message;

  const InquiryError(this.message);

  @override
  List<Object?> get props => [message];
}

class InquiryActionSuccess extends InquiryState {
  final String message;

  const InquiryActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class InquiryBloc extends Bloc<InquiryEvent, InquiryState> {
  final InquiryRepository _repository;
  List<InquiryModel> _inquiries = [];

  InquiryBloc(this._repository) : super(InquiryInitial()) {
    on<InquiryLoadAll>(_onLoadAll);
    on<InquiryLoadByStatus>(_onLoadByStatus);
    on<InquiryCreate>(_onCreate);
    on<InquiryUpdate>(_onUpdate);
    on<InquiryDelete>(_onDelete);
  }

  Future<void> _onLoadAll(
    InquiryLoadAll event,
    Emitter<InquiryState> emit,
  ) async {
    emit(InquiryLoading());
    final (inquiries, failure) = await _repository.getAll();
    if (failure != null) {
      emit(InquiryError(failure.message));
    } else {
      _inquiries = inquiries ?? [];
      emit(InquiryLoaded(_inquiries));
    }
  }

  Future<void> _onLoadByStatus(
    InquiryLoadByStatus event,
    Emitter<InquiryState> emit,
  ) async {
    emit(InquiryLoading());
    final statusString = _statusToString(event.status);
    final (inquiries, failure) = await _repository.getByStatus(statusString);
    if (failure != null) {
      emit(InquiryError(failure.message));
    } else {
      _inquiries = inquiries ?? [];
      emit(InquiryLoaded(_inquiries));
    }
  }

  Future<void> _onCreate(
    InquiryCreate event,
    Emitter<InquiryState> emit,
  ) async {
    emit(InquiryLoading());
    final (inquiry, failure) = await _repository.create(
      InquiryRequest(
        fullName: event.fullName,
        parentName: event.parentName,
        parentPhoneNumber: event.parentPhoneNumber,
        interestedCourses: event.interestedCourses,
        notes: event.notes,
      ),
    );
    if (failure != null) {
      emit(InquiryError(failure.message));
      emit(InquiryLoaded(_inquiries));
    } else {
      _inquiries = [..._inquiries, inquiry!];
      emit(const InquiryActionSuccess('So\'rov muvaffaqiyatli qo\'shildi'));
      emit(InquiryLoaded(_inquiries));
    }
  }

  Future<void> _onUpdate(
    InquiryUpdate event,
    Emitter<InquiryState> emit,
  ) async {
    emit(InquiryLoading());
    final (inquiry, failure) = await _repository.update(
      event.id,
      InquiryRequest(
        fullName: event.fullName,
        parentName: event.parentName,
        parentPhoneNumber: event.parentPhoneNumber,
        interestedCourses: event.interestedCourses,
        status: event.status,
        notes: event.notes,
      ),
    );
    if (failure != null) {
      emit(InquiryError(failure.message));
      emit(InquiryLoaded(_inquiries));
    } else {
      _inquiries =
          _inquiries.map((i) => i.id == event.id ? inquiry! : i).toList();
      emit(const InquiryActionSuccess('So\'rov yangilandi'));
      emit(InquiryLoaded(_inquiries));
    }
  }

  Future<void> _onDelete(
    InquiryDelete event,
    Emitter<InquiryState> emit,
  ) async {
    emit(InquiryLoading());
    final failure = await _repository.delete(event.id);
    if (failure != null) {
      emit(InquiryError(failure.message));
      emit(InquiryLoaded(_inquiries));
    } else {
      _inquiries = _inquiries.where((i) => i.id != event.id).toList();
      emit(const InquiryActionSuccess('So\'rov o\'chirildi'));
      emit(InquiryLoaded(_inquiries));
    }
  }

  String _statusToString(InquiryStatus status) {
    switch (status) {
      case InquiryStatus.newInquiry:
        return 'NEW';
      case InquiryStatus.contacted:
        return 'CONTACTED';
      case InquiryStatus.enrolled:
        return 'ENROLLED';
      case InquiryStatus.rejected:
        return 'REJECTED';
    }
  }
}