import Combine
import Photos
import UniformTypeIdentifiers

class DownloadManager: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    func startDownload(url: URL) {
        let task = VideoDownloader.shared.downloadVideo(url: url) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let outputURL):
                    print("✅ Download completed: \(outputURL)")
                    self?.askWhereToSave(outputURL)
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

    /// Ask user where they want to save the file: Photos or Files
    private func askWhereToSave(_ url: URL) {
        let alert = UIAlertController(title: "Save Video", message: "Where would you like to save the video?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Save to Photos", style: .default) { _ in
            self.saveToPhotoLibrary(url)
        })

        alert.addAction(UIAlertAction(title: "Save to Files", style: .default) { _ in
            self.saveToFiles(url)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // Show the alert (Make sure this runs on the main thread)
        DispatchQueue.main.async {
            if let topController = UIApplication.shared.windows.first?.rootViewController {
                topController.present(alert, animated: true)
            }
        }
    }

    /// Save to Photos app
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

    /// Save to Files app with a user-selected location
    private func saveToFiles(_ url: URL) {
        let documentPicker = UIDocumentPickerViewController(forExporting: [url])
        documentPicker.delegate = UIApplication.shared.windows.first?.rootViewController as? UIDocumentPickerDelegate
        DispatchQueue.main.async {
            UIApplication.shared.windows.first?.rootViewController?.present(documentPicker, animated: true)
        }
    }

    private func updateProgress(_ progress: Double) {
        print("📥 Download progress: \(Int(progress * 100))%")
    }
}
