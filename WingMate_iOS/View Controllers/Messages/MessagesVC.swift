//
//  Messages.swift
//  WingMate_iOS
//
//  Created by Anish on 9/26/21.
//

import UIKit
import Parse
import MessageUI
import CoreServices
import AssetsLibrary
import SVProgressHUD

// ------------------------------------------------
// MARK: - SENDER CELL
// ------------------------------------------------
class SenderCell: UITableViewCell {
    /*--- VIEWS ---*/
    @IBOutlet weak var sDateLabel: UILabel!
    @IBOutlet weak var sMessageTextView: UITextView!
    @IBOutlet weak var messageBg: UIView!
    @IBOutlet weak var lbl: UILabel!
    
}



// ------------------------------------------------
// MARK: - RECEIVER CELL
// ------------------------------------------------
class ReceiverCell: UITableViewCell {
    /*--- VIEWS ---*/
    @IBOutlet weak var rDateLabel: UILabel!
    @IBOutlet weak var rMessageTextView: UITextView!
    @IBOutlet weak var dp: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var messageBg: UIView!
    
}


class MessagesVC: BaseViewController {
    
    /*--- VIEWS ---*/
    @IBOutlet weak var messagesTableView: UITableView!
   
    @IBOutlet weak var receiverUsernameLabel: UILabel!
    @IBOutlet weak var writeMessageView: UIView!
    @IBOutlet weak var messageTxt: UITextField!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var typeMessageViewConstraint: NSLayoutConstraint!
    
    
    /*--- VARIABLES ---*/
    var userObj = PFUser(className: DBTable.USER_CLASS_NAME)
    var messagesArray = [PFObject]()
    var theMessages = [PFObject]()
    var instantsArray = [PFObject]()
    var skip = 0
    var cellHeight = CGFloat()
    var refreshTimer = Timer()
    var lastMessage = ""
    var imageToSend:UIImage?
    var isLoadFirstTime = false
    var msgSentById = ""
    var presenter = ProfilePresenter()
    var chatNotification = false
    // ------------------------------------------------
    // MARK: - VIEW DID APPEAR
    // ------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // ------------------------------------------------
    // MARK: - VIEW DID LOAD
    // ------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
   
       
        // Receiver Username
        receiverUsernameLabel.text = "\(userObj[DBColumn.nick]!)"
    
        // Call function
        startRefreshTimer()
        
        // Call query
        if PFUser.current() != nil { queryMessages() }
    }
    // ------------------------------------------------
    // MARK: - VIEW WILL APPEAR
    // ------------------------------------------------
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
       
    
    }
    // ------------------------------------------------
    // MARK: - KEYBOARD HIDE AND SHOW OBSERVERS
    // ------------------------------------------------
    @objc func keyboardWillShow(_ notification: Notification) {
        if let kFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let kRect = kFrame.cgRectValue
            let kHeight = kRect.height
            
            UIView.animate(withDuration: 0.5, animations: {
                self.typeMessageViewConstraint.constant = kHeight - 40
                self.view.layoutIfNeeded()
                })
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // Move writeMessageView on the bottom of the screen
 
        UIView.animate(withDuration: 0.5, animations: {
            self.typeMessageViewConstraint.constant = 20
            self.view.layoutIfNeeded()
            })
    }
    
    // ------------------------------------------------
    // MARK: - DISMISS KEYBOARD ON SCROLL DOWN
    // ------------------------------------------------
    var lastContentOffset: CGFloat = 0
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            dismissKeyboard()
        }
    }
    // ------------------------------------------------
    // MARK: - START THE REFRESH MESSAGES TIMER
    // ------------------------------------------------
    func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(queryMessages), userInfo: nil, repeats: true)
    }
    
    
    
    // ------------------------------------------------
    // MARK: - QUERY MESSAGES
    // ------------------------------------------------
    @objc func queryMessages() {
  
        if isLoadFirstTime == false{
            SVProgressHUD.show()
        }
     
        let currentUser = PFUser.current()!
        let messId1 = "\(currentUser.objectId!)\(userObj.objectId!)"
        let messId2 = "\(userObj.objectId!)\(currentUser.objectId!)"
        let notificationsQuery = PFUser.query()
        
        notificationsQuery!.whereKey("objectId", equalTo:userObj.objectId!)
        notificationsQuery?.findObjectsInBackground(block: { (object, error) in
            if error == nil {
                for item in object! {
                    let noti = item["allowChatNotification"] as! Bool
                    self.chatNotification = noti
                }
            }
        })
      
        
        
        let predicate = NSPredicate(format:"messageID = '\(messId1)' OR messageID = '\(messId2)'")
        let query = PFQuery(className: DBTable.MESSAGES_CLASS_NAME, predicate: predicate)
        query.order(byAscending: "createdAt")
        query.skip = skip
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                for i in 0..<objects!.count {
                    self.messagesArray.append(objects![i])
                    
                }
                if (objects!.count == 100) {
                    self.skip = self.skip + 100
                    self.queryMessages()
                } else {
                    self.messagesArray = objects!
                    
                    let messDiff = self.messagesArray.count - self.theMessages.count
                    print("MESSAGES ARRAY: \(self.messagesArray.count)")
                    print("THE MESSAGES: \(self.theMessages.count)")
                    print("MESS DIFF: \(messDiff)\n")
                    
                    // New messages
                    if self.theMessages.count < self.messagesArray.count {
                        let temp = self.theMessages.count
                        for i in 0..<messDiff {
                            self.theMessages.append(self.messagesArray[i+temp])
                            let indexP = IndexPath(row: i+temp, section: 0)
                            self.messagesTableView.insertRows(at: [indexP], with: .fade)
                            SVProgressHUD.dismiss()
                        }// ./ For
                        
                    // Some message has been deleted
                    } else if messDiff < 0 {
                        self.theMessages = self.messagesArray
                        self.messagesTableView.reloadData()
                    }
                    
                    // Scroll TableView down to the bottom
                    if self.theMessages.count != 0 {
                        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.emptyFunc), userInfo: nil, repeats: false)
                        
                        if self.isLoadFirstTime == false{
                            self.isLoadFirstTime = true
                            self.scrollTableViewToBottom()
                        }
                       
                    }
                   
                    
                   
                }// ./ If
                SVProgressHUD.dismiss()
            // error
            } else {// self.simpleAlert("\(error!.localizedDescription)")
        }}
    }
    @objc func emptyFunc(){}
    // ------------------------------------------------
    // MARK: - SEND MESSAGE BUTTON
    // ------------------------------------------------
    @IBAction func sendMessageButt(_ sender: Any) {
        // Stop the refresh timer
        refreshTimer.invalidate()
        
        let mObj = PFObject(className: DBTable.MESSAGES_CLASS_NAME)
        let currentUser = PFUser.current()!
        let profilePic = APP_MANAGER.session?.value(forKey: DBColumn.profilePic) as? String ?? ""
        // Save Message to Inbox Class
        mObj["profilePic"] = profilePic
        mObj["receiverId"] = userObj.objectId
        mObj["senderId"] = currentUser.objectId
        mObj[DBColumn.MESSAGES_SENDER] = currentUser
        mObj[DBColumn.MESSAGES_RECEIVER] = userObj
        mObj[DBColumn.MESSAGES_MESSAGE_ID] = "\(currentUser.objectId!)\(userObj.objectId!)"
        mObj[DBColumn.MESSAGES_MESSAGE] = messageTxt.text!
       
        lastMessage = messageTxt.text!
       
        self.sendMessageButton.isHidden = true
        // Saving...
        mObj.saveInBackground { (success, error) -> Void in
            if error == nil {
            //    self.hideHUD()
                let currentUser = PFUser.current()!
                self.sendMessageButton.isHidden = true
                self.messageTxt.resignFirstResponder()
                
                // Call function
                self.updateInstants()
                
                
                // Add message to the array (it's temporary, before a new query gets automatically called)
                self.theMessages.append(mObj)
                self.messagesTableView.reloadData()
                self.scrollTableViewToBottom()
                
                // Reset variables
                self.imageToSend = nil
                self.startRefreshTimer()
                // Send Push notification
                //payload message: GoLujo: 'u there '
                let pushMessage = "\(currentUser[DBColumn.nick]!): '\(self.lastMessage)'"
                let data = [
                    "badge" : "Increment",
                    "alert" : pushMessage,
                    "sound" : "bingbong.aiff"
                ]
                
                let request = [
                    "userObjectID" : self.userObj.objectId!,
                    "data" : data,
                    "senderId" : "\(currentUser.objectId!)",
                    "senderName": currentUser.username!
                ] as [String : Any]
                
                if self.chatNotification == true {
                PFCloud.callFunction(inBackground: "pushiOS", withParameters: request as [String : Any], block: { (results, error) in
                    if error == nil { print ("\nPUSH NOTIFICATION SENT TO: \(self.userObj[DBColumn.nick]!)\nMESSAGE: \(pushMessage)")
                    } else { //elf.simpleAlert("\(error!.localizedDescription)")
                    }})// ./ PFCloud
                let requestAndriod = [
                    "userObjectID" : self.userObj.objectId!,
                    "data" : pushMessage,
                    "senderId" : "\(currentUser.objectId!)",
                    "senderName": DBColumn.nick
                ] as [String : Any]
                PFCloud.callFunction(inBackground: "pushAndroid", withParameters: requestAndriod as [String : Any], block: { (results, error) in
                    if error == nil { print ("\nPUSH NOTIFICATION SENT TO ANDRIOD: \(self.userObj[DBColumn.nick]!)\nMESSAGE: \(pushMessage)")
                    } else { //elf.simpleAlert("\(error!.localizedDescription)")
                    }})// ./ PFCloud
                
                // error
            } else {
                // self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)")
        }}
        //pushAndroid
        }
      
    }
    
    // ------------------------------------------------
    // MARK: - UPDATE THE INSTANTS CLASS
    // ------------------------------------------------
    func updateInstants() {
        let currentUser = PFUser.current()!
        
        let messId1 = "\(currentUser.objectId!)\(userObj.objectId!)"
        let messId2 = "\(userObj.objectId!)\(currentUser.objectId!)"
        
        let predicate = NSPredicate(format:"\(DBColumn.INSTANTS_ID) = '\(messId1)'  OR  \(DBColumn.INSTANTS_ID) = '\(messId2)' ")
        let query = PFQuery(className: DBTable.instants, predicate: predicate)
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.instantsArray = objects!
                
                // Parse Object
                var iObj = PFObject(className: DBTable.instants)
                if self.instantsArray.count != 0 { iObj = self.instantsArray[0] }
                
                // Prepare data
                // iObj[INSTANTS_LAST_MESSAGE] = self.lastMessage
                iObj[DBColumn.INSTANTS_SENDER] = currentUser
                iObj[DBColumn.INSTANTS_RECEIVER] = self.userObj
                iObj[DBColumn.INSTANTS_ID] = "\(currentUser.objectId!)\(self.userObj.objectId!)"
                iObj["lastMessage"] = self.messageTxt.text ?? ""
                iObj["isUnread"] = true
                iObj["msgSentBy"] = "\(currentUser.objectId!)"
                iObj["msgCreateAt"] = Date()
                
                // Save...
                iObj.saveInBackground { (success, error) -> Void in
                    if error == nil { print("LAST MESS SAVED!")
                        self.messageTxt.text = ""
                    } else { //self.simpleAlert("\(error!.localizedDescription)")
                }}
                
            // error
            } else { //self.simpleAlert("\(error!.localizedDescription)")
        }}// ./ query
    }
    func markedSavedUserMessage(){
        
        let currentUser = PFUser.current()!
        
        if self.msgSentById != currentUser.objectId {
        let messId1 = "\(currentUser.objectId!)\(userObj.objectId!)"
        let messId2 = "\(userObj.objectId!)\(currentUser.objectId!)"
        
        let predicate = NSPredicate(format:"\(DBColumn.INSTANTS_ID) = '\(messId1)'  OR  \(DBColumn.INSTANTS_ID) = '\(messId2)' ")
        let query = PFQuery(className: DBTable.instants, predicate: predicate)
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.instantsArray = objects!
                // Parse Object
                var iObj = PFObject(className: DBTable.instants)
                if self.instantsArray.count != 0 { iObj = self.instantsArray[0] }
          
                iObj["isUnread"] = false
                // Save...
                iObj.saveInBackground { (success, error) -> Void in
                    if error == nil { print("unread updated!")
                    } else { //self.simpleAlert("\(error!.localizedDescription)")
                }}
                
            // error
            } else { //self.simpleAlert("\(error!.localizedDescription)")
            }}// ./ query
        }
    }
    // ------------------------------------------------
    // MARK: - SCROLL TABLEVIEW TO BOTTOM
    // ------------------------------------------------
     func scrollTableViewToBottom() {
        self.markedSavedUserMessage()
        messagesTableView.scrollToRow(at: IndexPath(row: self.theMessages.count-1, section: 0), at: .bottom, animated: true)
        SVProgressHUD.dismiss()
    }
    
    
    
    // ------------------------------------------------
    // MARK: - DISMISS KEYBOARD
    // ------------------------------------------------
    func dismissKeyboard() {
        messageTxt.resignFirstResponder()
    }
    // ------------------------------------------------
    // MARK: - BACK BUTTON
    // ------------------------------------------------
    @IBAction func backButt(_ sender: Any) {
        // Remove Notification observer
        NotificationCenter.default.removeObserver(self)
        
        // Invalidate refreshTimer
        refreshTimer.invalidate()
        
        // Go back
        _ = navigationController?.popViewController(animated: true)
    }
    // ------------------------------------------------
    // MARK: - VIEW WILL DISAPPEAR
    // ------------------------------------------------
    override func viewWillDisappear(_ animated: Bool) {
        // Remove Notification observer
        NotificationCenter.default.removeObserver(self)
        
        // Invalidate refreshTimer
        refreshTimer.invalidate()
        
    }

}
extension MessagesVC:UITextFieldDelegate {
    // ------------------------------------------------
    // MARK: - TEXT FIELD DELEGATES
    // ------------------------------------------------
    func textFieldDidEndEditing(_ textField: UITextField) {
       // sendMessageButton.isHidden = true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let chars = newText.count
        print("CHARS: \(chars)")
        if chars != 0 {
            sendMessageButton.isHidden = false
        } else {
            sendMessageButton.isHidden = false
        }
    return true
    }
}


extension MessagesVC : UITableViewDataSource,UITableViewDelegate {
    // ------------------------------------------------
    // MARK: - SHOW DATA IN TABLEVIEW
    // ------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theMessages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        // Parse Object
        
        var mObj = PFObject(className: DBTable.MESSAGES_CLASS_NAME)
        mObj = theMessages[indexPath.row]
        let currentuser = PFUser.current()!
        
        // userPointer
        var userPointer = mObj[DBColumn.MESSAGES_SENDER] as! PFUser
        do { userPointer = try userPointer.fetchIfNeeded() } catch {}
        
            // ------------------------------------------------
            // MARK: - SENDER CELL
            // ------------------------------------------------
            if userPointer.objectId == currentuser.objectId {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! SenderCell
                    
                // Layouts
                cell.backgroundColor = UIColor.clear
                cell.contentView.backgroundColor = UIColor.clear
               
                    
                // Get Date
                cell.sDateLabel.text = timeAgoSinceDate2(mObj.createdAt!, currentDate: Date(), numericDates: false)
        
                // Message
                cell.lbl.text = "\(mObj[DBColumn.MESSAGES_MESSAGE]!)"
                cell.messageBg.cornerRadius = 10
                cell.messageBg.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner,.layerMinXMaxYCorner]
   
                return cell
                    
                    
                
            // ------------------------------------------------
            // MARK: - RECEIVER CELL
            // ------------------------------------------------
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell", for: indexPath) as! ReceiverCell
                // senderUser
                var iObj = PFObject(className: DBTable.instants)
                iObj = theMessages[indexPath.row]
                let currentUser = PFUser.current()!
                let senderUser = iObj[DBColumn.INSTANTS_SENDER] as! PFUser
                senderUser.fetchIfNeededInBackground(block: { (up, error) in
                    
                    // receiverUser
                    let receiverUser = iObj[DBColumn.INSTANTS_RECEIVER] as! PFUser
                    receiverUser.fetchIfNeededInBackground(block: { (ou, error) in
                        
                        // Avatar Image of the User you're chatting with
                        if senderUser.objectId == currentUser.objectId {
                            let imageFile = receiverUser[DBColumn.profilePic] as! String
                            self.setImageWithUrl(imageUrl: imageFile, imageView: cell.dp)
                          
                           
                        } else {
                            print("Receiver userName = \(senderUser[DBColumn.nick] as! String)")
                            let imageFile = senderUser[DBColumn.profilePic] as! String
                            self.setImageWithUrl(imageUrl: imageFile, imageView: cell.dp)
                        }
                        
                    })// ./ receiverUser
                    
                })// ./ senderUser

                // Layouts
                cell.backgroundColor = UIColor.clear
                cell.contentView.backgroundColor = UIColor.clear
              
              //  let date = utcToLocal(dateStr: "\(mObj.createdAt!)")
               // cell.rDateLabel.text = date!
                // Get Date
                cell.rDateLabel.text = timeAgoSinceDate2(mObj.createdAt!, currentDate: Date(), numericDates: true)
                    
                // Message
                cell.rMessageTextView.text = "\(mObj[DBColumn.MESSAGES_MESSAGE]!)"
                cell.lbl.text = "\(mObj[DBColumn.MESSAGES_MESSAGE]!)"
                cell.messageBg.layer.cornerRadius = 10
                cell.messageBg.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner,.layerMaxXMaxYCorner]

                return cell
                    
            }// ./ If
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return cellHeight
        return UITableView.automaticDimension
    }
 

}
