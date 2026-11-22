//
//  Recipe Parser
//  Developed by Joshua Kistler and Justin Zheng
//  C323 Mobile App Development Final Project
//

import UIKit
import UserNotifications

class NotificationViewController: UIViewController {
    
    @IBOutlet var datePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func selectTime() {
        let date = datePicker.date
        print(date.formatted())
        print(Date.now.formatted())
        checkPermission()
    }
    
    func checkPermission() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.dispatchNotification()
            case .denied:
                return
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    if didAllow {
                        self.dispatchNotification()
                    }
                }
            default:
                return
            }
            
        }
    }
    
    func dispatchNotification() {
        let identifier = "grocery-list-notification"
        let title = "Grocery List Reminder!"
        let body = "Let's do some grocery shopping."
        let isDaily = false
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        DispatchQueue.main.async {
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.datePicker.date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
            notificationCenter.add(request)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
