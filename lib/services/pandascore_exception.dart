class PandaScoreException implements Exception {
  final String message;
  final int? statusCode;

  PandaScoreException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
