enum ReportStatus {
  pending('Pending'),
  underReview('UnderReview'),
  resolved('Resolved'),
  dismissed('Dismissed');

  final String value;
  const ReportStatus(this.value);

  factory ReportStatus.fromValue(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Unknown ReportStatus value: $value'),
    );
  }
}
