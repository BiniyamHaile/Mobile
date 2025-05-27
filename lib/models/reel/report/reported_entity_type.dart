enum ReportedEntityType {
  reel('reel'),
  comment('comment'),
  user('user');

  final String value;
  const ReportedEntityType(this.value);

  factory ReportedEntityType.fromValue(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Unknown ReportedEntityType value: $value'),
    );
  }
}