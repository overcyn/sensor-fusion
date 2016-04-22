import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var rootVC: UINavigationController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let pageVC = LYPageViewController()
        pageVC.page = DeviceMotionPage()
        
        rootVC = UINavigationController(rootViewController:pageVC)
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        return true
    }
}

