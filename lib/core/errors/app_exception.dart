enum AppErrorKind { network, auth, notFound, unknown }

class AppException implements Exception {
  final String message;
  final AppErrorKind kind;

  const AppException(this.message, {this.kind = AppErrorKind.unknown});

  @override
  String toString() => message;
}
