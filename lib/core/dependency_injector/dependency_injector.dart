import 'package:get_it/get_it.dart';
import 'package:mobile/bloc/comment/comment_bloc.dart';
import 'package:mobile/bloc/reel/reel_bloc.dart';
import 'package:mobile/bloc/reel/reel_post_details/post_details_bloc.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/services/api/comment/comment_repository.dart';
import 'package:mobile/services/api/comment/comment_repository_impl.dart';
import 'package:mobile/services/api/reel/reel_repository.dart';
import 'package:mobile/services/api/reel/reel_repository_impl.dart';
import 'package:mobile/services/api/reel_feed/reel_feed_repository.dart';
import 'package:mobile/services/api/reel_feed/reel_feed_repository_impl.dart';
import 'package:mobile/ui/routes/app_routes.dart';

final getIt = GetIt.instance;

void injectionSetup() {
  getIt.registerSingleton<ApiEndpoints>(ApiEndpoints());
  final apiEndpoints = getIt<ApiEndpoints>();

  getIt.registerSingleton<AppRoutes>(AppRoutes());

  getIt.registerLazySingleton<VideoFeedRepository>(
    () => VideoFeedRepositoryImpl(apiEndpoints: apiEndpoints),
  );

  getIt.registerLazySingleton<ReelRepository>(
      () => ReelRepositoryImpl(apiEndpoints: apiEndpoints));

  getIt.registerFactory<ReelFeedAndActionBloc>(
    () => ReelFeedAndActionBloc(
      getIt<VideoFeedRepository>(),
      getIt<ReelRepository>(),
    ),
  );

  getIt.registerFactory<PostDetailsBloc>(() => PostDetailsBloc());

  getIt.registerLazySingleton<CommentRepository>(
      () => CommentRepositoryImpl(apiEndpoints: apiEndpoints));

  getIt.registerFactory<CommentBloc>(
    () => CommentBloc(getIt<CommentRepository>(), getIt<ReelRepository>()),
  );
}
