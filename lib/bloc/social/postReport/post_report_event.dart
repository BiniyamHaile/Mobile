import 'package:mobile/models/report_post.dart';

abstract class PostReportEvent {}

class CreatePostReport extends PostReportEvent {
  final PostReport report;

  CreatePostReport(this.report);
}
