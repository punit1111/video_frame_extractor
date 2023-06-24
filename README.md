
## Video Frame Extractor

A Video Frame Extractor to extract frames from video file or video network URL.

![Sample](https://github.com/punit1111/video_frame_extractor/blob/main/doc/preview.gif)


## Example

```

    await VideoFrameExtractor.fromNetwork(
      videoUrl: 'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      imagesCount: 4,
      destinationDirectoryPath: '/storage/emulated/0/Download',
      onProgress: (progress) {},
    );
    
```
