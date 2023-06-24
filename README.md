
## Video Frame Extractor

Extract frames from video file or video network url.

![Sample](https://github.com/punit1111/video_frame_extractor/blob/main/doc/preview.gif)


## Example

```

    await VideoFrameExtractor.fromNetwork(
      videoUrl: 'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      imagesCount: 4,
      destinationDirectoryPath: 'E:/video_to_images/exported',
      maxWidth: 10,
      maxHeight: 20,
      quality: 1,
      imageFormat: ImageFormat.PNG,
      onProgress: (progress) {},
    );
    
```
