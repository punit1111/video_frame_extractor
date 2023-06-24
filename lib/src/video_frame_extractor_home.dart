import 'dart:io';

import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoFrameExtractor {
  static Future<List<String>> fromFile(
      {required File video,
      int imagesCount = 10,
      Duration from = Duration.zero,
      Duration to = Duration.zero,
      ImageFormat imageFormat = ImageFormat.PNG,
      int quality = 10,
      int maxHeight = 0,
      int maxWidth = 0,
      Function(double progress)? onProgress,
      required String destinationDirectoryPath}) async {
    try {
      await _isDestinationPathValid(destinationDirectoryPath);
      var videoPlayerController = VideoPlayerController.file(video);
      await videoPlayerController.initialize();
      var frames = await _generateFrames(
          videoPlayerController: videoPlayerController,
          to: to,
          from: from,
          imagesCount: imagesCount,
          video: video.path,
          onProgress: onProgress,
          imageFormat: imageFormat,
          quality: quality,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          destinationDirectoryPath: destinationDirectoryPath);
      return frames;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<String>> fromNetwork(
      {required String videoUrl,
      int imagesCount = 10,
      Duration from = Duration.zero,
      Duration to = Duration.zero,
      ImageFormat imageFormat = ImageFormat.PNG,
      int quality = 10,
      int maxHeight = 0,
      int maxWidth = 0,
      Function(double progress)? onProgress,
      required String destinationDirectoryPath}) async {
    try {
      await _isDestinationPathValid(destinationDirectoryPath);
      dynamic videoPlayerController;

      videoPlayerController = VideoPlayerController.network(videoUrl);
      await videoPlayerController.initialize();

      var frames = await _generateFrames(
          videoPlayerController: videoPlayerController,
          to: to,
          from: from,
          imagesCount: imagesCount,
          video: videoUrl,
          onProgress: onProgress,
          imageFormat: imageFormat,
          quality: quality,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          destinationDirectoryPath: destinationDirectoryPath);
      return frames;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> _isDestinationPathValid(
      String destinationDirectoryPath) async {
    bool isDirectoryExists = await Directory(destinationDirectoryPath).exists();
    if (!isDirectoryExists) {
      throw Exception('Directory Not Found: $destinationDirectoryPath');
    }
  }

  static Future<List<String>> _generateFrames(
      {required dynamic videoPlayerController,
      required Duration to,
      required Duration from,
      required int imagesCount,
      required String video,
      Function(double progress)? onProgress,
      required ImageFormat imageFormat,
      required int quality,
      required int maxHeight,
      required int maxWidth,
      required String destinationDirectoryPath}) async {
    try {
      List<String> frames = [];
      int totalMilliSecs = 0;
      int endDuration = 0;
      int totalDuration = videoPlayerController.value.duration.inMilliseconds;

      if (to == Duration.zero || to.inMilliseconds > totalDuration) {
        endDuration = videoPlayerController.value.duration.inMilliseconds;
      } else {
        endDuration = to.inMilliseconds;
      }

      if (from.inMilliseconds.isNegative) {
        from = Duration.zero;
      }

      totalMilliSecs = endDuration - (from.inMilliseconds);

      for (int i = 0; i < imagesCount; i++) {
        int ms = ((totalMilliSecs ~/ imagesCount) * i) + from.inMilliseconds;

        if (ms.isNegative || ms > endDuration) {
          continue;
        }

        String? currentFrame = await VideoThumbnail.thumbnailFile(
          video: video,
          timeMs: ms,
          imageFormat: imageFormat,
          quality: quality,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          thumbnailPath: "$destinationDirectoryPath/extracted_$i.png",
        );

        if (currentFrame != null) {
          frames.add(currentFrame);
        }

        double progress =
            double.parse(((i + 1) / imagesCount).toStringAsFixed(2));
        onProgress?.call(progress);
      }
      videoPlayerController.dispose();
      return frames;
    } catch (e) {
      rethrow;
    }
  }
}
