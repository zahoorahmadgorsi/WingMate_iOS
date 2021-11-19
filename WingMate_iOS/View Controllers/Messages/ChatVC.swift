//
//  ChatVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 16/02/2021.
//

import UIKit
import Parse
import SVProgressHUD

var firstTimeLoader = true

class ChatVC: BaseViewController {

    @IBOutlet weak var imageViewProfile: UIImageView!
    /*--- VIEWS ---*/
    @IBOutlet weak var instantsTableView: UITableView!
    @IBOutlet weak var noResulsLabel: UILabel!
    /*--- VARIABLES ---*/
    var instantsArray = [PFObject]()
    var skip = 0
    var  username = String()
    var refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.instantsTableView.tableFooterView = UIView()
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.addPullToRefresh()
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.setProfileImage(imageViewProfile: self.imageViewProfile)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        skip = 0
        instantsArray = [PFObject]()
        
        // Call query
        queryInstants()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    func addPullToRefresh() {
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.instantsTableView.refreshControl = refreshControl
    }
    @objc func refresh(_ sender: AnyObject) {
        queryInstants()
    }
    // ------------------------------------------------
    // MARK: - QUERY INSTANTS
    // ------------------------------------------------
    func queryInstants() {
        refreshControl.endRefreshing()
        instantsArray.removeAll()
        
        if firstTimeLoader == true {
            firstTimeLoader = false
            SVProgressHUD.show()
        }
        
        let currentUser = PFUser.current()!
        
        // Query
        let query = PFQuery(className: DBTable.instants)
        query.includeKey(DBTable.USER_CLASS_NAME)
        query.whereKey(DBColumn.INSTANTS_ID, contains: "\(currentUser.objectId!)")
        query.order(byDescending: "updatedAt")
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                for i in 0..<objects!.count {
                    self.instantsArray.append(objects![i]) }
                if (objects!.count == 100) {
                    self.skip = self.skip + 100
                    self.queryInstants()
                }
                
         
                SVProgressHUD.dismiss()
                
                if self.instantsArray.count == 0 {
                    self.noResulsLabel.isHidden = false
                    self.instantsTableView.backgroundColor = UIColor.clear
                } else {
                    self.noResulsLabel.isHidden = true
                    self.instantsTableView.reloadData()
                }
                
            // error
            } else {
            
                SVProgressHUD.dismiss()
                self.showToast(message:"\(error!.localizedDescription)")
        }}

    }
    
    //MARK: - Button Actions
    @IBAction func profilePictureButtonPressed(_ sender: Any) {
//        self.previewImage(imageView: self.imageViewProfile)
        let vc = ProfileVC(user: APP_MANAGER.session!)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ChatVC:UITableViewDataSource, UITableViewDelegate {
    // ------------------------------------------------
    // MARK: - SHOW DATA IN TABLEVIEW
    // ------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instantsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InstantCell
        cell.avatarImg.image = UIImage(named: "ItunesArtwork")
        cell.newMessage.isHidden = true
        cell.timeLbl.text = "..."
        // Parse Object
        var iObj = PFObject(className: DBTable.instants)
        iObj = instantsArray[indexPath.row]
        // currentUser
        let currentUser = PFUser.current()!
        if let hideLbl = iObj["msgSentBy"] as? String {
        if hideLbl != currentUser.objectId {
            let isUnread = iObj["isUnread"] as! Bool
            if isUnread == true {
                cell.newMessage.isHidden = false
            }else {
                cell.newMessage.isHidden = true
            }
          }
        }
      
        // Date
        print("Updated At time is = \(iObj.updatedAt!)")
        print("Updated At date is = \(Date())")
        
        // cell.timeLbl.text = timeAgoSinceDate(iObj.updatedAt!, currentDate: Date(), numericDates: true)
        if let pastDate = iObj["msgCreateAt"] as? Date  {

        cell.timeLbl.text = timeAgoSinceDate(pastDate, currentDate: Date(), numericDates: false)
        
        }
       
        
        

       
        
        cell.lastMessageLabel.text = "\(iObj["lastMessage"] ?? "")"
        
        // senderUser
        let senderUser = iObj[DBColumn.INSTANTS_SENDER] as! PFUser
        senderUser.fetchIfNeededInBackground(block: { (up, error) in
            
            // receiverUser
            let receiverUser = iObj[DBColumn.INSTANTS_RECEIVER] as! PFUser
            receiverUser.fetchIfNeededInBackground(block: { (ou, error) in
                
                // Avatar Image of the User you're chatting with
                if senderUser.objectId == currentUser.objectId {
                    let imageFile = receiverUser[DBColumn.profilePic] as! String
                    self.setImageWithUrl(imageUrl: imageFile, imageView: cell.avatarImg)
                    cell.usernameLabel.text = "\(receiverUser[DBColumn.nick]!)"
                   
                } else {
                    let imageFile = senderUser[DBColumn.profilePic] as! String
                    self.setImageWithUrl(imageUrl: imageFile, imageView: cell.avatarImg)
                    cell.usernameLabel.text = "\(senderUser[DBColumn.nick]!)"
                }
                
            })// ./ receiverUser
            
        })// ./ senderUser
        
        
    return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }
    
    
    // ------------------------------------------------
    // MARK: - CHAT WITH USER
    // ------------------------------------------------
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Parse Object
        var iObj = PFObject(className: DBTable.instants)
        iObj = instantsArray[indexPath.row]
        // currentUser
        let currentUser = PFUser.current()!
        let hideLbl = iObj["msgSentBy"]
        
        // senderUser
        let senderUser = iObj[DBColumn.INSTANTS_SENDER] as! PFUser
        senderUser.fetchIfNeededInBackground(block: { (up, error) in
            
            // receiverUser
            let receiverUser = iObj[DBColumn.INSTANTS_RECEIVER] as! PFUser
            receiverUser.fetchIfNeededInBackground(block: { (ou, error) in
                if error == nil {
                    // Chat with receiverUser
                    let chatNotification = receiverUser["allowChatNotification"] as! Bool
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as! MessagesVC
                    vc.chatNotification = chatNotification
                    if senderUser.objectId == currentUser.objectId {
                        vc.userObj = receiverUser
                        vc.msgSentById = "\(hideLbl ?? "")"
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        vc.userObj = senderUser
                        vc.msgSentById = "\(hideLbl ?? "")"
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    }
                    
                // error
                } else { //elf.simpleAlert("\(error!.localizedDescription)")
            }})// ./ receiverUser
            
        })// ./ senderUser
    }

}


