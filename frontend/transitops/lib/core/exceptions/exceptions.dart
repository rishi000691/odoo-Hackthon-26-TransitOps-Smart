/// Base class representing errors/failures in the application.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Server/API error failures.
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

/// Local database / Hive / secure storage caching failures.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Authentication/JWT authorization failures.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Connectivity/Network timeout failures.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Unknown/unexpected failures.
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
