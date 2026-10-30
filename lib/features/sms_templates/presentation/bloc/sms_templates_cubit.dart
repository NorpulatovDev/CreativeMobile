import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/sms_template_model.dart';
import '../../data/repositories/sms_template_repository.dart';

// States

abstract class SmsTemplatesState extends Equatable {
  const SmsTemplatesState();

  @override
  List<Object?> get props => [];
}

class SmsTemplatesLoading extends SmsTemplatesState {}

class SmsTemplatesLoaded extends SmsTemplatesState {
  final List<SmsTemplateModel> templates;
  // Type currently being saved/reset, so only that card shows a spinner.
  final String? savingType;
  // One-shot feedback for a snackbar; cleared on the next emit.
  final String? message;
  final bool isError;

  const SmsTemplatesLoaded(
    this.templates, {
    this.savingType,
    this.message,
    this.isError = false,
  });

  @override
  List<Object?> get props => [templates, savingType, message, isError];
}

class SmsTemplatesError extends SmsTemplatesState {
  final String message;

  const SmsTemplatesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit

class SmsTemplatesCubit extends Cubit<SmsTemplatesState> {
  final SmsTemplateRepository _repository;

  SmsTemplatesCubit(this._repository) : super(SmsTemplatesLoading());

  List<SmsTemplateModel> get _templates => switch (state) {
        SmsTemplatesLoaded s => s.templates,
        _ => const [],
      };

  Future<void> load() async {
    emit(SmsTemplatesLoading());
    final (templates, failure) = await _repository.getAll();
    if (isClosed) return;
    if (failure != null) {
      emit(SmsTemplatesError(failure.message));
    } else {
      emit(SmsTemplatesLoaded(templates ?? []));
    }
  }

  /// Returns true on success so the edit sheet can close itself.
  Future<bool> save(String type, String body) =>
      _apply(type, () => _repository.update(type, body), 'Shablon saqlandi');

  Future<bool> reset(String type) => _apply(
      type, () => _repository.reset(type), 'Standart matn tiklandi');

  Future<bool> _apply(
    String type,
    Future<(SmsTemplateModel?, dynamic)> Function() call,
    String successMessage,
  ) async {
    emit(SmsTemplatesLoaded(_templates, savingType: type));
    final (updated, failure) = await call();
    if (isClosed) return false;
    if (failure != null || updated == null) {
      emit(SmsTemplatesLoaded(_templates,
          message: failure?.message ?? 'Xatolik', isError: true));
      return false;
    }
    emit(SmsTemplatesLoaded(
      [for (final t in _templates) t.type == type ? updated : t],
      message: successMessage,
    ));
    return true;
  }
}
