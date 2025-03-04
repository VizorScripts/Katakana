extension AppDelegate {
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        if identifier == "com.yourcompany.app.backgroundSession" {
            VideoDownloader.shared.backgroundCompletionHandler = completionHandler
        }
    }
}