//
//  PrivacyPolicyVC.swift
//  WingMate_iOS
//
//  Created by Anish on 11/16/21.
//

import UIKit
import WebKit

class PrivacyPolicyVC: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = Bundle.main.url(forResource: "privacyPolicy", withExtension: "html")
        webView.load(URLRequest(url: url!))
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
