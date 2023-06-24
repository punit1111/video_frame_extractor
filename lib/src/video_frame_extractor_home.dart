import 'dart:io';

import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// output frame formats
enum FrameFormat { JPEG, PNG, WEBP }

/// [VideoFrameExtractor] providing functionality to extract frames from file or network
class VideoFrameExtractor {
  /// method to generate frames providing video file
  static Future<List<String>> fromFile(
      {required File video,
      int imagesCount = 10,
      Duration from = Duration.zero,
      Duration to = Duration.zero,
      FrameFormat frameFormat = FrameFormat.PNG,
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
          frameFormat: frameFormat,
          quality: quality,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          destinationDirectoryPath: destinationDirectoryPath);
      return frames;
    } catch (e) {
      rethrow;
    }
  }

  /// method to generate frames providing video network url
  static Future<List<String>> fromNetwork(
      {required String videoUrl,
      int imagesCount = 10,
      Duration from = Duration.zero,
      Duration to = Duration.zero,
      FrameFormat frameFormat = FrameFormat.PNG,
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
          frameFormat: frameFormat,
          quality: quality,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          destinationDirectoryPath: destinationDirectoryPath);
      return frames;
    } catch (e) {
      rethrow;
    }
  }

  /// to check provided destination path is valid or invalid
  static Future<void> _isDestinationPathValid(
      String destinationDirectoryPath) async {
    bool isDirectoryExists = await Directory(destinationDirectoryPath).exists();
    if (!isDirectoryExists) {
      throw Exception('Directory Not Found: $destinationDirectoryPath');
    }
  }

  /// this method generates frames using [VideoThumbnail]
  static Future<List<String>> _generateFrames(
      {required dynamic videoPlayerController,
      required Duration to,
      required Duration from,
      required int imagesCount,
      required String video,
      Function(double progress)? onProgress,
      required FrameFormat frameFormat,
      required int quality,
      required int maxHeight,
      required int maxWidth,
      required String destinationDirectoryPath}) async {
    try {
      List<String> frames = [];
      int totalMilliSecs = 0;
      int endDuration = 0;

      /// getting total video duration from video initialized
      int totalDuration = videoPlayerController.value.duration.inMilliseconds;

      /// preparing start / end duration
      if (to == Duration.zero || to.inMilliseconds > totalDuration) {
        endDuration = videoPlayerController.value.duration.inMilliseconds;
      } else {
        endDuration = to.inMilliseconds;
      }

      if (from.inMilliseconds.isNegative) {
        from = Duration.zero;
      }

      /// total video duration
      totalMilliSecs = endDuration - (from.inMilliseconds);

      for (int i = 0; i < imagesCount; i++) {
        /// given output image count
        /// calculating time in milliseconds at which frame to be generated
        int ms = ((totalMilliSecs ~/ imagesCount) * i) + from.inMilliseconds;

        if (ms.isNegative || ms > endDuration) {
          continue;
        }

        /// [VideoThumbnail] used to generate frame
        String? currentFrame = await VideoThumbnail.thumbnailFile(
          video: video,
          timeMs: ms,
          imageFormat: _getImageFormat(frameFormat),
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

      /// disposing video controller
      videoPlayerController.dispose();
      return frames;
    } catch (e) {
      rethrow;
    }
  }

  /// returns compatible format for [VideoThumbnail]
  static _getImageFormat(FrameFormat frameFormat) {
    switch (frameFormat) {
      case FrameFormat.PNG:
        return ImageFormat.PNG;
      case FrameFormat.JPEG:
        return ImageFormat.JPEG;
      case FrameFormat.WEBP:
        return ImageFormat.WEBP;
      default:
        return ImageFormat.PNG;
    }
  }
}
