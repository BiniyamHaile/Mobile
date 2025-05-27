import 'package:equatable/equatable.dart';

class ReportReasonDetailsDto extends Equatable {
  final String mainReason;
  final String? subReason;
  final String? details;

  const ReportReasonDetailsDto({
    required this.mainReason,
    this.subReason,
    this.details,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {'mainReason': mainReason};

    if (subReason != null) {
      json['subReason'] = subReason;
    }
    if (details != null) {
      json['details'] = details;
    }

    return json;
  }

  @override
  List<Object?> get props => [mainReason, subReason, details];
}
