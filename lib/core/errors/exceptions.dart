/// Base exception — all custom exceptions extend this.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

/// Thrown when the backend returns a non-2xx response.
class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {super.code, this.statusCode, super.originalError});
}

/// Thrown when there is no internet / host unreachable.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection', Object? originalError])
      : super(code: 'network_error', originalError: originalError);
}

/// Thrown when reading/writing local cache fails.
class CacheException extends AppException {
  const CacheException([super.message = 'Cache error', Object? originalError])
      : super(code: 'cache_error', originalError: originalError);
}

/// Thrown when a Firestore transaction or write fails.
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code, super.originalError});
}

/// Thrown by auth operations.
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.originalError});

  /// Converts a Firebase auth error code to a human-readable message.
  factory AuthException.fromFirebase(dynamic error) {
    final code = error?.code as String? ?? '';
    final message = switch (code) {
      'user-not-found'         => 'No account found with this email address',
      'wrong-password'         => 'Incorrect password. Please try again',
      'email-already-in-use'   => 'An account with this email already exists',
      'weak-password'          => 'Password is too weak (minimum 6 characters)',
      'invalid-email'          => 'Invalid email address',
      'too-many-requests'      => 'Too many attempts. Please try again later',
      'network-request-failed' => 'Network error. Check your internet connection',
      'operation-not-allowed'  => 'This sign-in method is not enabled',
      'user-disabled'          => 'This account has been disabled',
      'invalid-credential'     => 'Invalid credentials',
      _                        => 'Something went wrong. Please try again',
    };
    return AuthException(message, code: code, originalError: error);
  }
}

/// Thrown when a bid is rejected (too low, auction ended, etc.).
class BidException extends AppException {
  const BidException(super.message, {super.code, super.originalError});
}

/// Thrown when a payment fails or is cancelled.
class PaymentException extends AppException {
  const PaymentException(super.message, {super.code, super.originalError});
}

/// Thrown for validation errors (form fields, params, etc.).
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;
  const ValidationException(super.message, {this.fieldErrors, super.code});
}
