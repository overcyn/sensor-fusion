import UIKit
import CoreMotion

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
    var delegate: LYPageDelegate?
    
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
            
            let roll = LYListSection()
            roll.title = "x"
            roll.detailTitle = String(format: "%.2f", deviceMotion.userAcceleration.x)
            sections.append(roll)
            
            let pitch = LYListSection()
            pitch.title = "y"
            pitch.detailTitle = String(format: "%.2f", deviceMotion.userAcceleration.y)
            sections.append(pitch)
            
            let yaw = LYListSection()
            yaw.title = "z"
            yaw.detailTitle = String(format: "%.2f", deviceMotion.userAcceleration.z)
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
    
    var sections: [AnyObject]
    let title = "Device Motion"
}
