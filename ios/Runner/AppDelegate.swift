import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyDq8iGgIDkAV8XgKDCsvgNuPcViWbDhbvA")
    GeneratedPluginRegistrant.register(with: self)
    return supe r.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
