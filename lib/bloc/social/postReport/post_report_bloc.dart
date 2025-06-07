import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/social/postReport/post_report_event.dart';
import 'package:mobile/bloc/social/postReport/post_report_state.dart';
import 'package:mobile/repository/social/post_report_repository.dart';

class PostReportBloc extends Bloc<PostReportEvent, PostReportState> {
  final PostReportRepository repository;

  PostReportBloc({required this.repository}) : super(PostReportInitial()) {
    on<CreatePostReport>(_onCreatePostReport);
  }

  Future<void> _onCreatePostReport(
      CreatePostReport event, Emitter<PostReportState> emit) async {
    emit(PostReportLoading());

    try {
      await repository.createReport(event.report);
      emit(PostReportSuccess());
    } catch (e) {
      emit(PostReportFailure(e.toString()));
    }
  }
}
