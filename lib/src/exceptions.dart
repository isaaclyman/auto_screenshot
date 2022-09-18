String generateError(Exception e, String? error) {
  final errorOutput = error == null ? '' : ' \n$error';
  return '\n✗ ERROR: ${(e).runtimeType.toString()}$errorOutput';
}

class InvalidConfigException implements Exception {
  const InvalidConfigException([this.message]);
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
}

class InvalidPathException implements Exception {
  const InvalidPathException([this.message]);
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
}

class InvalidDeviceException implements Exception {
  const InvalidDeviceException([this.message]);
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
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

class MissingBinaryException implements Exception {
  const MissingBinaryException([this.message]);
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
}

class UnsupportedDeviceException implements Exception {
  const UnsupportedDeviceException([this.message]);
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
}

class TestFailureException implements Exception {
  const TestFailureException([this.message]);
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
}

class IOSSimulatorBootException implements Exception {
  const IOSSimulatorBootException([this.message]);
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
}

class AndroidEmulatorBootException implements Exception {
  const AndroidEmulatorBootException([this.message]);
  final String? message;

  @override
  String toString() {
    return generateError(this, message);
  }
}
