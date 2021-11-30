import UIKit
import CoreMotion

class RootPage: NSObject, LYPage {
    override init() {
        sections = []
        super.init()
        reloadSections()
    }
    
    func reloadSections() {
        var sections:[AnyObject] = []
        do {
            let section = LYListSection()
            section.title = "Device Motion"
            section.action = { [weak self] in
                guard let `self` = self else { return }
                let pageVC = LYPageViewController()
                pageVC.page = DeviceMotionPage()
                self.delegate?.parentViewControllerForPage(self).navigationController?.pushViewController(pageVC, animated:true)
            }
            sections.append(section)
        }
        do {
            let section = LYListSection()
            section.title = "Device Motion"
            section.action = { [weak self] in
                guard let `self` = self else { return }
                let pageVC = LYPageViewController()
                pageVC.page = DeviceMotionPage()
                self.delegate?.parentViewControllerForPage(self).navigationController?.pushViewController(pageVC, animated:true)
            }
            sections.append(section)
        }
        self.sections = sections
        self.delegate?.pageDidUpdate(self)
    }
    
    // MARK: LYPage
    
    var delegate: LYPageDelegate?
    var sections: [AnyObject]
    let title = "Sensor Fusion"
}

class DeviceMotionPage: NSObject, LYPage {
    override init() {
        sections = []
        queue = NSOperationQueue()
        motionManager = CMMotionManager()
        super.init()
        motionManager.startDeviceMotionUpdatesUsingReferenceFrame(.XArbitraryCorrectedZVertical, toQueue:queue){ [weak self] deviceMotion, error in
            dispatch_async(dispatch_get_main_queue()) {
                self?.deviceMotion = deviceMotion
                self?.reloadSections()
            }
        }
        reloadSections()
    }
    
    let queue: NSOperationQueue
    let motionManager: CMMotionManager
    var deviceMotion: CMDeviceMotion?
    var x: Double = 0
    var y: Double = 0
    var z: Double = 0
    
    func reloadSections() {
       guard let deviceMotion = self.deviceMotion else {
           let section = LYListSection()
           section.title = "No Data"
           self.sections = [section]
           self.delegate?.pageDidUpdate(self)
           return
       }
        var sections:[AnyObject] = []
        do {
            let header = LYListHeaderSection()
            header.title = "Attitude"
            sections.append(header)
            
            let roll = LYListSection()
            roll.title = "Roll"
            roll.detailTitle = String(format: "%.2f", deviceMotion.attitude.roll)
            sections.append(roll)
            
            let pitch = LYListSection()
            pitch.title = "Pitch"
            pitch.detailTitle = String(format: "%.2f", deviceMotion.attitude.pitch)
            sections.append(pitch)
            
            let yaw = LYListSection()
            yaw.title = "Yaw"
            yaw.detailTitle = String(format: "%.2f", deviceMotion.attitude.yaw)
            sections.append(yaw)
        }
        do {
            let header = LYListHeaderSection()
            header.title = "Rotation"
            sections.append(header)
            
            let roll = LYListSection()
            roll.title = "x"
            roll.detailTitle = String(format: "%.2f", deviceMotion.rotationRate.x)
            sections.append(roll)
            
            let pitch = LYListSection()
            pitch.title = "y"
            pitch.detailTitle = String(format: "%.2f", deviceMotion.rotationRate.y)
            sections.append(pitch)
            
            let yaw = LYListSection()
            yaw.title = "z"
            yaw.detailTitle = String(format: "%.2f", deviceMotion.rotationRate.z)
            sections.append(yaw)
        }
        do {
            let header = LYListHeaderSection()
            header.title = "Gravity"
            sections.append(header)
            
            let roll = LYListSection()
            roll.title = "x"
            roll.detailTitle = String(format: "%.2f", deviceMotion.gravity.x)
            sections.append(roll)
            
            let pitch = LYListSection()
            pitch.title = "y"
            pitch.detailTitle = String(format: "%.2f", deviceMotion.gravity.y)
            sections.append(pitch)
            
            let yaw = LYListSection()
            yaw.title = "z"
            yaw.detailTitle = String(format: "%.2f", deviceMotion.gravity.z)
            sections.append(yaw)
        }
        do {
            let header = LYListHeaderSection()
            header.title = "User Acceleration"
            sections.append(header)
            
            x = x * 0.8 + deviceMotion.userAcceleration.x * 0.2
            y = y * 0.8 + deviceMotion.userAcceleration.y * 0.2
            z = z * 0.8 + deviceMotion.userAcceleration.z * 0.2
            
            let roll = LYListSection()
            roll.title = "x"
            roll.detailTitle = String(format: "%.2f", x)
            sections.append(roll)
            
            let pitch = LYListSection()
            pitch.title = "y"
            pitch.detailTitle = String(format: "%.2f", y)
            sections.append(pitch)
            
            let yaw = LYListSection()
            yaw.title = "z"
            yaw.detailTitle = String(format: "%.2f", z)
            sections.append(yaw)
        }
        do {
            let header = LYListHeaderSection()
            header.title = "Magnetic Field"
            sections.append(header)
            
            let roll = LYListSection()
            roll.title = "x"
            roll.detailTitle = String(format: "%.2f", deviceMotion.magneticField.field.x)
            sections.append(roll)
            
            let pitch = LYListSection()
            pitch.title = "y"
            pitch.detailTitle = String(format: "%.2f", deviceMotion.magneticField.field.y)
            sections.append(pitch)
            
            let yaw = LYListSection()
            yaw.title = "z"
            yaw.detailTitle = String(format: "%.2f", deviceMotion.magneticField.field.z)
            sections.append(yaw)
        }
        self.sections = sections
        self.delegate?.pageDidUpdate(self)
    }
    
    // MARK: LYPage
    
    var delegate: LYPageDelegate?
    var sections: [AnyObject]
    let title = "Device Motion"
}
