import UIKit
import CoreMotion

class ViewController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        motionManager = CMMotionManager()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var motionManager: CMMotionManager
    
    override func loadView() {
        super.loadView()
    }
}

