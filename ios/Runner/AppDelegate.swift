import Flutter
import UIKit
import MessageUI

@main
@objc class AppDelegate: FlutterAppDelegate, MFMessageComposeViewControllerDelegate {
  private var smsResult: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController
    let smsChannel = FlutterMethodChannel(
      name: "com.example.creative/sms",
      binaryMessenger: controller.binaryMessenger
    )

    smsChannel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "sendSms" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard
        let args = call.arguments as? [String: Any],
        let phone = args["phone"] as? String,
        let message = args["message"] as? String
      else {
        result(FlutterError(code: "INVALID", message: "phone and message required", details: nil))
        return
      }
      self?.sendSms(phone: phone, message: message, result: result)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func sendSms(phone: String, message: String, result: @escaping FlutterResult) {
    guard MFMessageComposeViewController.canSendText() else {
      result(FlutterError(code: "NOT_SUPPORTED", message: "SMS not supported on this device", details: nil))
      return
    }
    let composer = MFMessageComposeViewController()
    composer.messageComposeDelegate = self
    composer.recipients = [phone]
    composer.body = message
    smsResult = result
    window?.rootViewController?.present(composer, animated: true)
  }

  func messageComposeViewController(
    _ controller: MFMessageComposeViewController,
    didFinishWith result: MessageComposeResult
  ) {
    controller.dismiss(animated: true)
    switch result {
    case .sent:
      smsResult?("sent")
    case .cancelled:
      smsResult?(FlutterError(code: "CANCELLED", message: "User cancelled", details: nil))
    case .failed:
      smsResult?(FlutterError(code: "FAILED", message: "SMS failed to send", details: nil))
    @unknown default:
      smsResult?(FlutterError(code: "UNKNOWN", message: "Unknown result", details: nil))
    }
    smsResult = nil
  }
}
