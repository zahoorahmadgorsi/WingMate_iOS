//
//  DashboardVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 14/11/2020.
//

import UIKit
import SVProgressHUD
import Parse

class DashboardVC: BaseViewController {

    //MARK: - Outlets & Constraints
    @IBOutlet weak var labelName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    
    
    
}
