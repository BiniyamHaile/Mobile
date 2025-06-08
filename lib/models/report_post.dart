class PostReport {
  final String id;
  final String ?content_id;
  final String? reporterId;
  final String mainReason;
  final String? subreason;
  final String status;
  final String? resolvedBy;
  final String? reportType;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostReport({
    required this.id,
    required this.content_id,
    this.reporterId,
    required this.mainReason,
    this.subreason,
    required this.status,
    this.resolvedBy,
    this.reportType,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostReport.fromJson(Map<String, dynamic> json) {
    return PostReport(
      id: json['_id'] ?? json['id'],
      content_id: json['content_id'],
      reporterId: json['reporterId'],
      mainReason: json['mainReason'],
      subreason: json['subreason'],
      status: json['status'],
      resolvedBy: json['resolvedBy'],
      reportType: json['reportType'],
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'content_id': content_id,
        'reporterId': reporterId,
        'mainReason': mainReason,
        'subreason': subreason,
        'status': status,
        'resolvedBy': resolvedBy,
        'reportType': reportType,
        'resolvedAt': resolvedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
