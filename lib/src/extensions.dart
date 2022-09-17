extension TrimCharEx on String {
  String trimCharRight(String char) {
    if (!endsWith(char)) {
      return this;
    }

    return substring(0, length - 1);
  }

  String trimCharLeft(String char) {
    if (!startsWith(char)) {
      return this;
    }

    return substring(1);
  }

  String trimChar(String char) {
    return trimCharLeft(char).trimCharRight(char);
  }
}
