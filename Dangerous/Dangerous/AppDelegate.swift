import UIKit
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let launchCount = UserDefaults.standard.integer(forKey: "launchCount")
        registerDefaultsFromSettingsBundle()
        if launchCount == 0{
            let today = NSDate()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let formattedDate = dateFormatter.string(from: today as Date)
            UserDefaults.standard.set(formattedDate, forKey: "ogdate")
        }
        if launchCount == 3{
            SKStoreReviewController.requestReview()
        }
        UserDefaults.standard.set(launchCount + 1, forKey:"launchCount")
        return true
    }
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
// This utility function borrowed from here. It syncs the settings bundle with plist.
// https://stackoverflow.com/questions/46453789/swift-4-settings-bundle-get-defaults/46537668
func registerDefaultsFromSettingsBundle()
{
    let settingsUrl = Bundle.main.url(forResource: "Settings", withExtension: "bundle")!.appendingPathComponent("Root.plist")
    let settingsPlist = NSDictionary(contentsOf:settingsUrl)!
    let preferences = settingsPlist["PreferenceSpecifiers"] as! [NSDictionary]

    var defaultsToRegister = Dictionary<String, Any>()
    for preference in preferences {
        guard let key = preference["Key"] as? String else {
            NSLog("Key not fount")
            continue
        }
        defaultsToRegister[key] = preference["DefaultValue"]
    }
    UserDefaults.standard.register(defaults: defaultsToRegister)
}
