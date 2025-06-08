
import 'package:mobile/models/reel/like/like_dto.dart';
import 'package:mobile/models/reel/like/like_reel_response_dto.dart';
import 'package:mobile/models/reel/reel.dart';
import 'package:mobile/models/reel/report/create_report_dto.dart';
import 'package:mobile/models/reel/share_reel_response_dto.dart';
import 'package:mobile/models/reel/update_reel.dart';

abstract class ReelRepository {
  Future<void> postReel({
    required String videoFilePath,
    required CreateReelDto reelData,
  });

  Future<void> updateReel({
    required String reelId,
    required UpdateReelDto updateData,
  });

  Future<void> deleteReel({required String reelId});

  Future<LikeReelResponseDto> like({required CreateLikeDto likeData});
  Future<ShareReelResponseDto> shareReel({required String reelId});

  Future<void> reportReel({required CreateReportDto reportData});
}