import Flutter
import UIKit
import ObjectiveC

private let unityCommandsChannel = "fitgame/unity_commands"
private let unityEventsChannel = "fitgame/unity_events"
private let unityViewType = "fitgame/unity_view"
private let unityBridgeObject = "UnityBridge"
private let unityBridgeMethod = "PostMessage"
private let unityEventNotification = Notification.Name("FitGameUnityEvent")

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let registrar = engineBridge.applicationRegistrar
    let messenger = registrar.messenger()

    FlutterMethodChannel(
      name: unityCommandsChannel,
      binaryMessenger: messenger
    ).setMethodCallHandler { call, result in
      switch call.method {
      case "postMessage":
        guard let message = call.arguments as? String, !message.isEmpty else {
          result(FlutterError(
            code: "INVALID_MESSAGE",
            message: "Unity command message is empty.",
            details: nil
          ))
          return
        }
        if FitGameUnityRuntime.shared.postMessage(
          gameObject: unityBridgeObject,
          method: unityBridgeMethod,
          message: message
        ) {
          result(nil)
        } else {
          FitGameUnityEventStream.emit(
            FitGameUnityEventStream.unavailableEvent(
              requestId: FitGameUnityEventStream.readRequestId(message)
            )
          )
          result(nil)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    FlutterEventChannel(
      name: unityEventsChannel,
      binaryMessenger: messenger
    ).setStreamHandler(FitGameUnityEventStream.shared)

    NotificationCenter.default.addObserver(
      forName: unityEventNotification,
      object: nil,
      queue: .main
    ) { notification in
      if let json = notification.object as? String {
        FitGameUnityEventStream.emit(json)
      } else if let json = notification.object as? NSString {
        FitGameUnityEventStream.emit(json as String)
      }
    }

    registrar.register(
      FitGameUnityViewFactory(),
      withId: unityViewType
    )
  }
}

final class FitGameUnityViewFactory: NSObject, FlutterPlatformViewFactory {
  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    FitGameUnityPlatformView(frame: frame)
  }
}

final class FitGameUnityPlatformView: NSObject, FlutterPlatformView {
  private let container: FitGameUnityContainerView

  init(frame: CGRect) {
    container = FitGameUnityContainerView(frame: frame)
    container.backgroundColor = UIColor(red: 0.03, green: 0.04, blue: 0.05, alpha: 1)
    super.init()

    if let unityView = FitGameUnityRuntime.shared.attach() {
      container.attach(unityView)
    } else {
      let label = UILabel(frame: container.bounds.insetBy(dx: 20, dy: 20))
      label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      label.numberOfLines = 0
      label.textColor = .white
      label.text = "UnityFramework is not attached. Export Unity as an iOS Library into ios/UnityLibrary."
      container.addSubview(label)
    }
  }

  func view() -> UIView {
    container
  }
}

final class FitGameUnityContainerView: UIView {
  private weak var unityView: UIView?

  func attach(_ view: UIView) {
    unityView = view
    view.removeFromSuperview()
    view.isUserInteractionEnabled = false
    view.frame = bounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(view)
    refreshUnitySurface()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    unityView?.frame = bounds
    refreshUnitySurface()
  }

  private func refreshUnitySurface() {
    guard let unityView else {
      return
    }
    unityView.setNeedsLayout()
    unityView.layoutIfNeeded()
    callOptionalSelector("updateLayerDrawableSizeFromBounds", on: unityView)
    callOptionalSelector("updateUnityBackbufferSize", on: unityView)
    callOptionalSelector("recreateRenderingSurfaceIfNeeded", on: unityView)
  }

  private func callOptionalSelector(_ name: String, on object: NSObject) {
    let selector = NSSelectorFromString(name)
    if object.responds(to: selector) {
      object.perform(selector)
    }
  }
}

final class FitGameUnityRuntime {
  static let shared = FitGameUnityRuntime()

  private var unityFramework: NSObject?
  private var unityView: UIView?
  private var pendingMessages: [UnityMessage] = []

  func attach() -> UIView? {
    if let unityView {
      return unityView
    }
    guard let framework = loadUnityFramework() else {
      return nil
    }
    unityFramework = framework
    setDataBundleId(framework)
    runEmbedded(framework)
    unityView = readUnityView(framework)
    restoreFlutterWindowFocus()
    flushPendingMessages()
    return unityView
  }

  func postMessage(gameObject: String, method: String, message: String) -> Bool {
    guard let framework = unityFramework else {
      guard isUnityFrameworkAvailable() else {
        return false
      }
      pendingMessages.append(UnityMessage(
        gameObject: gameObject,
        method: method,
        message: message
      ))
      return true
    }
    return sendMessage(framework, gameObject: gameObject, method: method, message: message)
  }

  private func loadUnityFramework() -> NSObject? {
    if let unityFramework {
      return unityFramework
    }

    let frameworkPath = Bundle.main.bundlePath + "/Frameworks/UnityFramework.framework"
    guard let bundle = Bundle(path: frameworkPath) else {
      return nil
    }
    if !bundle.isLoaded {
      bundle.load()
    }
    guard
      let frameworkClass = bundle.principalClass as? NSObject.Type,
      let framework = frameworkClass
        .perform(NSSelectorFromString("getInstance"))?
        .takeUnretainedValue() as? NSObject
    else {
      return nil
    }
    return framework
  }

  private func setDataBundleId(_ framework: NSObject) {
    let selector = NSSelectorFromString("setDataBundleId:")
    guard framework.responds(to: selector) else {
      return
    }
    typealias SetDataBundleId = @convention(c) (
      NSObject,
      Selector,
      UnsafePointer<CChar>
    ) -> Void
    let implementation = framework.method(for: selector)
    let set = unsafeBitCast(implementation, to: SetDataBundleId.self)
    "com.unity3d.framework".withCString { bundleId in
      set(framework, selector, bundleId)
    }
  }

  private func runEmbedded(_ framework: NSObject) {
    let selector = NSSelectorFromString("runEmbeddedWithArgc:argv:appLaunchOpts:")
    guard framework.responds(to: selector) else {
      return
    }
    typealias RunEmbedded = @convention(c) (
      NSObject,
      Selector,
      Int32,
      UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>,
      [UIApplication.LaunchOptionsKey: Any]?
    ) -> Void
    let implementation = framework.method(for: selector)
    let run = unsafeBitCast(implementation, to: RunEmbedded.self)
    run(framework, selector, CommandLine.argc, CommandLine.unsafeArgv, nil)
  }

  private func restoreFlutterWindowFocus() {
    DispatchQueue.main.async {
      let windows = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap(\.windows)
      guard
        let flutterWindow = windows.first(where: { window in
          window.rootViewController is FlutterViewController ||
            String(describing: type(of: window)).contains("Flutter")
        })
      else {
        return
      }

      for window in windows where window !== flutterWindow {
        let controllerName = window.rootViewController
          .map { String(describing: type(of: $0)) } ?? ""
        if controllerName.contains("Unity") {
          window.isUserInteractionEnabled = false
          window.windowLevel = .normal - 1
        }
      }
      flutterWindow.makeKeyAndVisible()
    }
  }

  private func readUnityView(_ framework: NSObject) -> UIView? {
    let appControllerSelector = NSSelectorFromString("appController")
    guard
      framework.responds(to: appControllerSelector),
      let controller = framework
        .perform(appControllerSelector)?
        .takeUnretainedValue() as? NSObject
    else {
      return nil
    }
    let unityViewSelector = NSSelectorFromString("unityView")
    if
      controller.responds(to: unityViewSelector),
      let unityView = controller
        .perform(unityViewSelector)?
        .takeUnretainedValue() as? UIView
    {
      return unityView
    }
    let rootViewSelector = NSSelectorFromString("rootView")
    return controller
      .perform(rootViewSelector)?
      .takeUnretainedValue() as? UIView
  }

  private func sendMessage(
    _ framework: NSObject,
    gameObject: String,
    method: String,
    message: String
  ) -> Bool {
    let selector = NSSelectorFromString("sendMessageToGOWithName:functionName:message:")
    guard framework.responds(to: selector) else {
      return false
    }
    typealias SendMessage = @convention(c) (
      NSObject,
      Selector,
      NSString,
      NSString,
      NSString
    ) -> Void
    let implementation = framework.method(for: selector)
    let send = unsafeBitCast(implementation, to: SendMessage.self)
    send(framework, selector, gameObject as NSString, method as NSString, message as NSString)
    return true
  }

  private func flushPendingMessages() {
    guard let framework = unityFramework else {
      return
    }
    let messages = pendingMessages
    pendingMessages.removeAll()
    for pending in messages {
      _ = sendMessage(
        framework,
        gameObject: pending.gameObject,
        method: pending.method,
        message: pending.message
      )
    }
  }

  private func isUnityFrameworkAvailable() -> Bool {
    let frameworkPath = Bundle.main.bundlePath + "/Frameworks/UnityFramework.framework"
    return Bundle(path: frameworkPath) != nil
  }

  private struct UnityMessage {
    let gameObject: String
    let method: String
    let message: String
  }
}

final class FitGameUnityEventStream: NSObject, FlutterStreamHandler {
  static let shared = FitGameUnityEventStream()
  private static var eventSink: FlutterEventSink?

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    Self.eventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    Self.eventSink = nil
    return nil
  }

  static func emit(_ json: String) {
    eventSink?(json)
  }

  static func unavailableEvent(requestId: String) -> String {
    """
    {"type":"UNITY_UNAVAILABLE","requestId":"\(escape(requestId))","success":false,"error":"UnityFramework is not attached on iOS.","payload":{}}
    """
  }

  static func readRequestId(_ message: String) -> String {
    guard
      let data = message.data(using: .utf8),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else {
      return ""
    }
    return json["requestId"] as? String ?? ""
  }

  private static func escape(_ value: String) -> String {
    value
      .replacingOccurrences(of: "\\", with: "\\\\")
      .replacingOccurrences(of: "\"", with: "\\\"")
  }
}

@_cdecl("FitGameEmitUnityEvent")
func FitGameEmitUnityEvent(_ pointer: UnsafePointer<CChar>?) {
  guard let pointer else {
    return
  }
  FitGameUnityEventStream.emit(String(cString: pointer))
}
