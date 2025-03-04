import Foundation
import MobileFFmpeg

class FFmpegProcessor {
    static let shared = FFmpegProcessor()
    private init() {}
    
    func convertToX264(inputURL: URL, outputURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
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
        
        DispatchQueue.global(qos: .userInitiated).async {
            let returnCode = MobileFFmpeg.execute(command)
            
            DispatchQueue.main.async {
                switch returnCode {
                case RETURN_CODE_SUCCESS:
                    completion(.success(outputURL))
                default:
                    completion(.failure(NSError(
                        domain: "FFmpegError",
                        code: Int(returnCode),
                        userInfo: [NSLocalizedDescriptionKey: "Conversion failed with code \(returnCode)"]
                    ))
                }
            }
        }
    }
}