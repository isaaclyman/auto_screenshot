extension UrlJoinEx on String {
  String joinUrl(String other) {
    if (endsWith('/')) {
      return substring(0, length - 1).joinUrl(other);
    }

    if (other.startsWith('/')) {
      return joinUrl(other.substring(1));
    }

    return "$this/$other";
  }
}
