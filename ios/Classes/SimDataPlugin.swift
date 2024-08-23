import Flutter
import UIKit
import MessageUI

public class SimDataPlugin: NSObject, FlutterPlugin, MFMessageComposeViewControllerDelegate {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "sim_data", binaryMessenger: registrar.messenger())
    let instance = SimDataPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
      break
    case "send_sms":
      Messages(call: call);
      break
    default:
      result(FlutterMethodNotImplemented)
    }
  }

    func Messages(call: FlutterMethodCall) {
    if MFMessageComposeViewController.canSendText() == true {
        guard let args = call.arguments as? [String : Any] else {return}
        let phoneNumber = args["phone"] as! String
        let msg = args["msg"] as! String
        let recipients:[String] = [phoneNumber]
        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate  = self
        messageController.recipients = recipients
        messageController.body = msg
        messageController.present(messageController, animated: true)
    } else {
        let alertController = UIAlertController(title: "Error", message: "Cannot send text message", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        let topViewController = UIApplication.shared.keyWindow?.rootViewController
        topViewController?.present(alertController, animated: true, completion: nil)
    }
  }

  public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    controller.dismiss(animated: true, completion: nil)
  }
}
