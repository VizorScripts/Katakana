import Combine
import Photos

class DownloadManager: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    func startDownload(url: URL) {
        let task = VideoDownloader.shared.downloadVideo(url: url) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let outputURL):
                    print("✅ Download completed: \(outputURL)")
                    self?.saveToPhotoLibrary(outputURL)
                case .failure(let error):
                    print("❌ Download failed: \(error.localizedDescription)")
                }
            }
        }

        // Progress tracking
        NotificationCenter.default.publisher(for: .init("DownloadProgressNotification"))
            .compactMap { $0.userInfo?["progress"] as? Double }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.updateProgress(progress)
            }
            .store(in: &cancellables)
    }

    private func saveToPhotoLibrary(_ url: URL) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    print("✅ Video saved to Photo Library!")
                } else {
                    print("❌ Failed to save video: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }

    private func updateProgress(_ progress: Double) {
        print("📥 Download progress: \(Int(progress * 100))%")
        // Add UI updates here if needed
    }
}
