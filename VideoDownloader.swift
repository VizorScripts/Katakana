import Foundation

class VideoDownloader: NSObject, URLSessionDownloadDelegate {
    static let shared = VideoDownloader()
    
    private lazy var backgroundSession: URLSession = {
        let config = URLSessionConfiguration.background(
            withIdentifier: "com.yourcompany.app.backgroundSession"
        )
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    private var activeDownloads: [Int: (URL, (Result<URL, Error>) -> Void)] = [:]
    
    func downloadVideo(url: URL, completion: @escaping (Result<URL, Error>) -> Void) -> URLSessionDownloadTask {
        let task = backgroundSession.downloadTask(with: url)
        activeDownloads[task.taskIdentifier] = (url, completion)
        task.resume()
        return task
    }
    
    // MARK: - URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let (originalURL, completion) = activeDownloads[downloadTask.taskIdentifier] else { return }
        
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent(originalURL.lastPathComponent)
        
        do {
            try FileManager.default.moveItem(at: location, to: tempFile)
            
            // Check if the file is an HLS stream or direct MP4
            if originalURL.pathExtension == "m3u8" {
                // Convert HLS to MP4
                FFmpegProcessor.shared.convertToX264(inputURL: tempFile, outputURL: tempDir.appendingPathComponent("converted_\(UUID().uuidString).mp4")) { result in
                    completion(result)
                    try? FileManager.default.removeItem(at: tempFile)
                    self.activeDownloads.removeValue(forKey: downloadTask.taskIdentifier)
                }
            } else {
                // Direct MP4 download - no conversion needed
                let destinationURL = FileManager.default.documentsDirectory
                    .appendingPathComponent("downloaded_\(UUID().uuidString).mp4")
                try FileManager.default.moveItem(at: tempFile, to: destinationURL)
                completion(.success(destinationURL))
                self.activeDownloads.removeValue(forKey: downloadTask.taskIdentifier)
            }
        } catch {
            completion(.failure(error))
            activeDownloads.removeValue(forKey: downloadTask.taskIdentifier)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error, let completion = activeDownloads[task.taskIdentifier]?.1 else { return }
        completion(.failure(error))
        activeDownloads.removeValue(forKey: task.taskIdentifier)
    }
}
