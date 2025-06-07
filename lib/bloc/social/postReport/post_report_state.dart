abstract class PostReportState {}

class PostReportInitial extends PostReportState {}

class PostReportLoading extends PostReportState {}

class PostReportSuccess extends PostReportState {}

class PostReportFailure extends PostReportState {
  final String message;

  PostReportFailure(this.message);
}
