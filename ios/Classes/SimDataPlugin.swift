import Flutter
import UIKit
import MessageUI

public class SimDataPlugin: NSObject, FlutterPlugin, MFMessageComposeViewControllerDelegate {

    private var pendingResult: FlutterResult?
    private var timeoutWorkItem: DispatchWorkItem?
    private weak var composer: MFMessageComposeViewController?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "sim_data", binaryMessenger: registrar.messenger())
        let instance = SimDataPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "send_sms":
            sendMessage(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func sendMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard MFMessageComposeViewController.canSendText() else {
            result(FlutterError(code: "UNAVAILABLE",
                                message: "This device cannot send text messages",
                                details: nil))
            return
        }

        guard let args = call.arguments as? [String: Any],
              let phoneNumber = args["phone"] as? String,
              let msg = args["msg"] as? String else {
            result(FlutterError(code: "INVALID_ARGS",
                                message: "Expected 'phone' and 'msg' string arguments",
                                details: nil))
            return
        }

        // Only one compose screen at a time.
        guard pendingResult == nil else {
            result(FlutterError(code: "IN_PROGRESS",
                                message: "A message compose screen is already open",
                                details: nil))
            return
        }

        guard let presenter = topViewController() else {
            result(FlutterError(code: "NO_VC",
                                message: "No view controller available to present from",
                                details: nil))
            return
        }

        // Timeout in seconds; missing or <= 0 means no timeout.
        let timeout = (args["timeout"] as? NSNumber)?.doubleValue ?? 0

        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        messageController.recipients = [phoneNumber]
        messageController.body = msg

        pendingResult = result
        composer = messageController

        presenter.present(messageController, animated: true) { [weak self] in
            // Start the clock only once the sheet is actually on screen.
            guard let self = self, timeout > 0 else { return }
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self, self.pendingResult != nil else { return }
                self.composer?.dismiss(animated: true, completion: nil)
                self.complete(with: FlutterError(code: "TIMEOUT",
                                                 message: "User did not send the message within \(Int(timeout)) seconds",
                                                 details: nil))
            }
            self.timeoutWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: workItem)
        }
    }

    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true, completion: nil)

            switch result {
            case .sent:
                complete(with: "sent")
            case .cancelled:
                complete(with: FlutterError(code: "CANCELLED",
                                            message: "User cancelled the message",
                                            details: nil))
            case .failed:
                complete(with: FlutterError(code: "SEND_FAILED",
                                            message: "The message failed to send",
                                            details: nil))
            @unknown default:
                complete(with: FlutterError(code: "UNKNOWN",
                                            message: "Unknown message compose result",
                                            details: nil))
            }
        }

    /// Calls the pending Flutter result exactly once and tears down the timeout.
    private func complete(with value: Any?) {
        timeoutWorkItem?.cancel()
        timeoutWorkItem = nil
        composer = nil
        let result = pendingResult
        pendingResult = nil
        result?(value)
    }

    private func topViewController() -> UIViewController? {
        var keyWindow: UIWindow?
        if #available(iOS 13.0, *) {
            keyWindow = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            keyWindow = UIApplication.shared.keyWindow
        }

        var top = keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}