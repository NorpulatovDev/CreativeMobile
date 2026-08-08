import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    String message = 'Validation failed',
    this.fieldErrors,
  }) : super(message);

  @override
  List<Object> get props => [message, fieldErrors ?? {}];
}

/// The write was refused because the phone number entered already belongs to
/// another teacher record. Since the phone number is the teacher's identity on
/// the backend, going ahead would merge the two into one person: a single shared
/// login, and each seeing the other's groups.
///
/// That is correct for one teacher working in several branches and wrong for two
/// different people who happen to share a number, so only the admin can decide.
/// Re-submit with `confirmSamePerson: true` to go ahead.
class SamePersonConfirmationFailure extends Failure {
  /// Backend `code` that identifies this case, so it is matched on structure
  /// rather than on the wording of the message.
  static const code = 'TEACHER_SAME_PERSON_CONFIRMATION_REQUIRED';

  const SamePersonConfirmationFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No cached data available']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}