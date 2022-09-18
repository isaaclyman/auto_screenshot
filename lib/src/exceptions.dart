String generateError(Exception e, String? error) {
  final errorOutput = error == null ? '' : ' \n$error';
  return '\n✗ ERROR: ${(e).runtimeType.toString()}$errorOutput';
}

class AggregateException implements Exception {
  const AggregateException(this.exceptions);
  final Iterable<Exception> exceptions;

  @override
  String toString() {
    final childExceptionLog = exceptions.map((e) => '$e').join('\n');

    return generateError(
        this, "{${exceptions.length} exception(s)}$childExceptionLog");
  }
}

class MessageException implements Exception {
  const MessageException(this.message);
  final String message;

  @override
  String toString() {
    return generateError(this, message);
  }
}

class InvalidConfigException extends MessageException {
  const InvalidConfigException(super.message);
}

class InvalidPathException extends MessageException {
  const InvalidPathException(super.message);
}

class InvalidDeviceException extends MessageException {
  InvalidDeviceException(super.message);
}

class MissingBinaryException extends MessageException {
  MissingBinaryException(super.message);
}

class TestFailureException extends MessageException {
  TestFailureException(super.message);
}

class IOSSimulatorBootException extends MessageException {
  IOSSimulatorBootException(super.message);
}

class AndroidEmulatorBootException extends MessageException {
  AndroidEmulatorBootException(super.message);
}

class IOSCommandException extends MessageException {
  IOSCommandException(super.message);
}

class AndroidCommandException extends MessageException {
  AndroidCommandException(super.message);
}

class MissingPackageException extends MessageException {
  MissingPackageException(super.message);
}
