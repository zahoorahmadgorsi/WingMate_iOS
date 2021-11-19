//
//  NotificationsSettingsVC.swift
//  WingMate_iOS
//
//  Created by Anish on 11/19/21.
//

import UIKit
import Parse

class NotificationsSettingsVC: UIViewController,UNUserNotificationCenterDelegate {

    
    @IBOutlet weak var notificationAll: UISwitch!
    @IBOutlet weak var chatNotification: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let isAllowedNotification = UserDefaults.standard.object(forKey: "notificationOn"){
            let noti = isAllowedNotification as! Bool
            if noti == true {
                self.notificationAll.isOn = true
            }else {
                self.notificationAll.isOn = false
                chatNotification.isOn = false
            }
        }
        let chatNoti = PFUser.current()?.value(forKey:"allowChatNotification") as? Bool ?? false
        if chatNoti == true{
            chatNotification.isOn = true
        }else{
            chatNotification.isOn = false
        }
    }
    
    

    @IBAction func allNotification(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.setValue(true, forKey: "notificationOn")
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.registerForRemoteNotifications()
                    })
                }
            }
        }else {
            UserDefaults.standard.setValue(false, forKey: "notificationOn")
            UIApplication.shared.unregisterForRemoteNotifications()
            self.chatNotification.isOn = false
            self.setNotifications(bool: false)
        }
    }
    
    @IBAction func chatNotifications(_ sender: UISwitch) {
        if sender.isOn {
            self.setNotifications(bool: true)
        }else {
            self.setNotifications(bool: false)
        }
    }
    func setNotifications(bool:Bool){
        let currentUser = PFUser.current()
        if currentUser != nil {
            currentUser!["allowChatNotification"] = bool
            currentUser!.saveInBackground()
        }
    }
}
