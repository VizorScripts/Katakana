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
    
    func downloadHLSStream(url: URL, completion: @escaping (Result<URL, Error>) -> Void) -> URLSessionDownloadTask {
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
            FFmpegProcessor.shared.convertToX264(inputURL: tempFile, outputURL: tempDir.appendingPathComponent("converted_\(UUID().uuidString).mp4")) { result in
                completion(result)
                try? FileManager.default.removeItem(at: tempFile)
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