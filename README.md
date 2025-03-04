# Sukai is derived from Sukaidaunrōdā (スカイダウンローダー) meaning sky downloader!

**Video Downloader & Converter Module for iOS Development**

Sukai is a production-ready iOS framework for background HLS stream downloads and FFmpeg-based MP4 conversion. It features:

- **Resumable Downloads:** Efficiently continue downloads in the background or even after app termination.
- **Robust File Management:** Automatically handle temporary and final files, ensuring storage remains uncluttered.
- **UIKit & SwiftUI Integration:** Seamlessly fits into any iOS project architecture.
- **HLS Streaming & Conversion:** Download HLS streams with URLSession, convert them to MP4 using MobileFFmpeg, and even save videos directly to the user’s photo library.
- **Reactive Programming:** Utilizes Combine to manage state and UI updates for a smooth user experience.

Built with URLSession, MobileFFmpeg, and Combine, Katakana is your robust solution for downloading, converting, and managing video content on iOS.







> **Features**
---------------------------------------------------------------------------
1. **Background Downloads**
Downloads continue even when the app is in the background or terminated.

Uses URLSession with background(withIdentifier:) configuration.

2. **HLS Stream Downloading**
Downloads HLS streams (.m3u8) to a temporary file.

Handles segmented video downloads efficiently.

3. **FFmpeg Video Conversion**
Converts downloaded HLS streams to x264-encoded MP4 files.

Customizable encoding parameters (e.g., -crf, -preset).

4. **Resumable Downloads**
Supports pausing and resuming downloads using resumeData.

5. **File Management**
Automatically manages temporary and final files.

Cleans up temporary files after conversion.

6. **Progress Tracking**
Tracks download progress in real-time using URLSessionDownloadDelegate.

7. **Error Handling**
Robust error handling for downloads and conversions.

Provides clear feedback for failures.

8. **Background Session Handling**
Handles app relaunch after background download completion.

9. **Photo Library Integration**
Saves converted videos to the user’s photo library.

10. **Thread Safety**
Ensures safe access to shared resources using DispatchQueue.

11. **Combine Framework Integration**
Uses Combine for reactive programming and UI updates.

12. **Modular Design**
Separates concerns into distinct classes (e.g., VideoDownloader, FFmpegProcessor).

13. **UIKit and SwiftUI Compatibility**
Works seamlessly with both UIKit and SwiftUI.

14. **Network Resilience**
Handles network interruptions gracefully.
___________________________________________________________________________
___________________________________________________________________________






> **Installation**
---------------------------------------------------------------------------
**1. Add FFmpeg Framework**
- Download FFmpeg-iOS-Lam.
- Drag "FFmpeg.xcframework" into your Xcode project.
- Enable "Embed & Sign" in Framework settings.



**2. Add Header Search Paths**
- Add the following to your project's header search paths:

      $(PROJECT_DIR)/FFmpeg.xcframework/ios-arm64/Headers




**3. Enable Background Modes**
- Go to your project settings in Xcode.
- Under Signing & Capabilities, add:
- Background Modes → Enable "Background fetch" and "Background processing".



**4. Update Info.plist**
- Add the following to your Info.plist:

      <key>NSAppTransportSecurity</key>
      <dict>
          <key>NSAllowsArbitraryLoads</key>
          <true/>
      </dict>


___________________________________________________________________________
___________________________________________________________________________










> Usage
---------------------------------------------------------------------------


**1. Start a Download**


    let url = URL(string: "https://example.com/stream.m3u8")!
    VideoDownloader.shared.downloadHLSStream(url: url) { result in
        switch result {
        case .success(let convertedURL):
            print("Video saved at: \(convertedURL)")
        case .failure(let error):
            print("Download failed: \(error.localizedDescription)")
        }
    }



**2. Track Progress**
- Use Combine to track download progress:


      @Published var downloadProgress: Double = 0

      func startDownload(url: URL) {
          let task = VideoDownloader.shared.downloadHLSStream(url: url) { result in
              // Handle result
          }
    
          NotificationCenter.default.publisher(for: .init("DownloadProgressNotification"))
              .compactMap { $0.userInfo?["progress"] as? Double }
              .receive(on: DispatchQueue.main)
              .sink { [weak self] progress in
                  self?.downloadProgress = progress
              }
              .store(in: &cancellables)
      }








**3. Save to Photo Library**
   
    PHPhotoLibrary.shared().performChanges {
        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: convertedURL)
    } completionHandler: { success, error in
        if !success {
            print("Failed to save video: \(error?.localizedDescription ?? "")")
        }
    }

___________________________________________________________________________
___________________________________________________________________________





> Customization
---------------------------------------------------------------------------
**1. Change FFmpeg Encoding Parameters**
Modify the FFmpeg command in FFmpegProcessor.swift:



    let command = """
    -i \(inputURL.path) \
    -c:v libx264 \
    -preset fast \
    -crf 23 \
    -c:a aac \
    -b:a 128k \
    -movflags +faststart \
    -y \(outputURL.path)
    """




**2. Update Background Session Identifier**
Change the session identifier in VideoDownloader.swift:



    let config = URLSessionConfiguration.background(
        withIdentifier: "com.yourcompany.app.backgroundSession"
    )



**3. Adjust File Storage Paths**
Modify file paths in VideoDownloader.swift:


    let tempDir = FileManager.default.temporaryDirectory
    let tempFile = tempDir.appendingPathComponent(originalURL.lastPathComponent)




---------------------------------------


**Requirements**
 > iOS 14+
 > Xcode 13+
 > FFmpeg-iOS-Lam

  License
This project is licensed under the MIT License. See the LICENSE file for details.

  Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.

  Credits
FFmpeg-iOS-Lam for the FFmpeg framework.

Apple’s URLSession and Combine frameworks for background downloads and reactive programming.


**Enjoy seamless video downloads and conversions! 🚀**
~ e.ias
