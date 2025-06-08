import 'package:equatable/equatable.dart';
import 'package:mobile/models/reel/report/report_reason_details_dto.dart';
import 'package:mobile/models/reel/report/reported_entity_type.dart';

class CreateReportDto extends Equatable {
  final ReportReasonDetailsDto reasonDetails;

  final String reportedEntityId;
  final ReportedEntityType reportedEntityType; 

  const CreateReportDto({
    required this.reasonDetails,
    required this.reportedEntityId,
    required this.reportedEntityType,
  });

  Map<String, dynamic> toJson() {
    return {
      'reasonDetails': reasonDetails.toJson(),
      'reportedEntityId': reportedEntityId,
      'reportedEntityType':
          reportedEntityType.value,
    };
  }

  @override
  List<Object?> get props => [
    reasonDetails,
    reportedEntityId,
    reportedEntityType,
  ];
}
