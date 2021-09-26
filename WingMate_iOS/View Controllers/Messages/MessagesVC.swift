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

// ------------------------------------------------
// MARK: - SENDER CELL
// ------------------------------------------------
class SenderCell: UITableViewCell {
    /*--- VIEWS ---*/
    @IBOutlet weak var sDateLabel: UILabel!
    @IBOutlet weak var sMessageTextView: UITextView!
    
}



// ------------------------------------------------
// MARK: - RECEIVER CELL
// ------------------------------------------------
class ReceiverCell: UITableViewCell {
    /*--- VIEWS ---*/
    @IBOutlet weak var rDateLabel: UILabel!
    @IBOutlet weak var rMessageTextView: UITextView!
   
}


class MessagesVC: UIViewController {
    
    /*--- VIEWS ---*/
    @IBOutlet weak var messagesTableView: UITableView!
   
    @IBOutlet weak var receiverUsernameLabel: UILabel!
    @IBOutlet weak var writeMessageView: UIView!
    @IBOutlet weak var messageTxt: UITextField!
    @IBOutlet weak var sendMessageButton: UIButton!
 
    
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
                
        messageTxt.layer.cornerRadius = 22
        messageTxt.layer.borderColor = UIColor.lightGray.cgColor
        messageTxt.layer.borderWidth = 1
        // Add Padding left and right to the messageTxt
        messageTxt.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: messageTxt.frame.height))
        messageTxt.rightViewMode = .always
        messageTxt.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: messageTxt.frame.height))
        messageTxt.leftViewMode = .always
        
        // Receiver Username
        receiverUsernameLabel.text = "\(userObj[DBColumn.username]!)"
    
        // Call function
        startRefreshTimer()
        
        // Call query
        if PFUser.current() != nil { queryMessages() }
    }
    // ------------------------------------------------
    // MARK: - KEYBOARD HIDE AND SHOW OBSERVERS
    // ------------------------------------------------
    @objc func keyboardWillShow(_ notification: Notification) {
        if let kFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let kRect = kFrame.cgRectValue
            let kHeight = kRect.height
            
            // Move writeMessageView over the top of the keyboard
            writeMessageView.frame.origin.y = view.frame.size.height - kHeight - writeMessageView.frame.size.height
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // Move writeMessageView on the bottom of the screen
        writeMessageView.frame.origin.y = view.frame.size.height - writeMessageView.frame.size.height
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
        let currentUser = PFUser.current()!
        let messId1 = "\(currentUser.objectId!)\(userObj.objectId!)"
        let messId2 = "\(userObj.objectId!)\(currentUser.objectId!)"
        
        let predicate = NSPredicate(format:"messageID = '\(messId1)' OR messageID = '\(messId2)'")
        let query = PFQuery(className: DBTable.MESSAGES_CLASS_NAME, predicate: predicate)
        query.order(byAscending: "createdAt")
        
        query.skip = skip
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                for i in 0..<objects!.count { self.messagesArray.append(objects![i]) }
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
                        }// ./ For
                        
                    // Some message has been deleted
                    } else if messDiff < 0 {
                        self.theMessages = self.messagesArray
                        self.messagesTableView.reloadData()
                    }
                    
                    
                    // Scroll TableView down to the bottom
                    if self.theMessages.count != 0 {
                        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.scrollTableViewToBottom), userInfo: nil, repeats: false)
                    }
                }// ./ If
                
            // error
            } else {// self.simpleAlert("\(error!.localizedDescription)")
        }}
    }
    
    // ------------------------------------------------
    // MARK: - SEND MESSAGE BUTTON
    // ------------------------------------------------
    @IBAction func sendMessageButt(_ sender: Any) {
        // Stop the refresh timer
        refreshTimer.invalidate()
        
        let mObj = PFObject(className: DBTable.MESSAGES_CLASS_NAME)
        let currentUser = PFUser.current()!
        
        // Save Message to Inbox Class
        mObj[DBColumn.MESSAGES_SENDER] = currentUser
        mObj[DBColumn.MESSAGES_RECEIVER] = userObj
        mObj[DBColumn.MESSAGES_MESSAGE_ID] = "\(currentUser.objectId!)\(userObj.objectId!)"
        mObj[DBColumn.MESSAGES_MESSAGE] = messageTxt.text!
        lastMessage = messageTxt.text!
        messageTxt.text = ""
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
                
                
            // error
            } else {// self.hideHUD(); self.simpleAlert("\(error!.localizedDescription)")
        }}
        
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
                
                // Save...
                iObj.saveInBackground { (success, error) -> Void in
                    if error == nil { print("LAST MESS SAVED!")
                    } else { //self.simpleAlert("\(error!.localizedDescription)")
                }}
                
            // error
            } else { //self.simpleAlert("\(error!.localizedDescription)")
        }}// ./ query
    }
    // ------------------------------------------------
    // MARK: - SCROLL TABLEVIEW TO BOTTOM
    // ------------------------------------------------
    @objc func scrollTableViewToBottom() {
        messagesTableView.scrollToRow(at: IndexPath(row: self.theMessages.count-1, section: 0), at: .bottom, animated: true)
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
        sendMessageButton.isHidden = true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let chars = newText.count
        print("CHARS: \(chars)")
        if chars != 0 {
            sendMessageButton.isHidden = false
        } else {
            sendMessageButton.isHidden = true
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
                cell.sDateLabel.text = timeAgoSinceDate(mObj.createdAt!, currentDate: Date(), numericDates: true)
                    
                // Message
                cell.sMessageTextView.text = "\(mObj[DBColumn.MESSAGES_MESSAGE]!)"
                cell.sMessageTextView.sizeToFit()
                cell.sMessageTextView.frame.origin.x = 78
                cell.sMessageTextView.frame.size.width = cell.frame.size.width - 86
                cell.sMessageTextView.layer.cornerRadius = 5
                
                // Set cellHeight
                self.cellHeight = cell.sMessageTextView.frame.origin.y + cell.sMessageTextView.frame.size.height + 26
   
                return cell
                    
                    
                
            // ------------------------------------------------
            // MARK: - RECEIVER CELL
            // ------------------------------------------------
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell", for: indexPath) as! ReceiverCell
                    
                // Layouts
                cell.backgroundColor = UIColor.clear
                cell.contentView.backgroundColor = UIColor.clear
              
                    
                // Get Date
                cell.rDateLabel.text = timeAgoSinceDate(mObj.createdAt!, currentDate: Date(), numericDates: true)
                    
                // Message
                cell.rMessageTextView.text = "\(mObj[DBColumn.MESSAGES_MESSAGE]!)"
                cell.rMessageTextView.sizeToFit()
                cell.rMessageTextView.frame.origin.x = 10
                cell.rMessageTextView.frame.size.width = cell.frame.size.width - 86
                cell.rMessageTextView.layer.cornerRadius = 5
                    
                // Set cellHeight
                self.cellHeight = cell.rMessageTextView.frame.origin.y + cell.rMessageTextView.frame.size.height + 26
                    
            
                return cell
                    
            }// ./ If
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    
    
    
    // ------------------------------------------------
    // MARK: - UNSEND MESSAGE BY SWIPING CELL LEFT
    // ------------------------------------------------
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Parse Object
        var mObj = PFObject(className: DBTable.MESSAGES_CLASS_NAME)
        mObj = self.theMessages[indexPath.row]
        let currentUser = PFUser.current()!
        
        // UNSEND ACTION
        let unsendAction = UITableViewRowAction(style: .default, title: "Unsend") { (action, indexPath) in
            
            // User Pointer
            let userPointer = mObj[DBColumn.MESSAGES_SENDER] as! PFUser
            userPointer.fetchIfNeededInBackground(block: { (user, error) in
                if error == nil {
                    if userPointer.objectId! == currentUser.objectId! {
                        mObj.deleteInBackground(block: { (succ, error) in
                            self.theMessages.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                            
                            // Update the Instants class
                            self.updateInstants()
                        })
                        
                    // error
                    } else { //self.simpleAlert("You can Unsend only your own messages!")
                        
                    }
                    
                // error
                } else { //self.simpleAlert("\(error!.localizedDescription)")
                    
                }
            })// ./ userPointer
            
        }
        unsendAction.backgroundColor = UIColor.darkGray
        return [unsendAction]
    }
    
}
