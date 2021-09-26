//
//  SelectPaymentOptionVC.swift
//  WingMate_iOS
//
//  Created by Anish on 9/12/21.
//

import UIKit
import Parse
import SVProgressHUD

class SelectPaymentOptionVC: BaseViewController {

    
    @IBOutlet private var multiRadioButton: [UIButton]!{
        didSet{
            multiRadioButton.forEach { (button) in
                button.setImage(UIImage(named:"unCheck"), for: .normal)
                button.setImage(UIImage(named:"tik"), for: .selected)
                button.setBackgroundImage(UIImage(named: "checkedPay"), for: .selected)
            }
        }
    }

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //Handle with single Action
    @IBAction private func maleFemaleAction(_ sender: UIButton){
        uncheck()
        sender.checkboxAnimation {
            print(sender.titleLabel?.text ?? "")
            print(sender.isSelected)
        }
        
        // NOTE:- here you can recognize with tag.
        print(sender.tag)
    }
    
    func uncheck(){
        multiRadioButton.forEach { (button) in
            button.isSelected = false
        }
    }
    @IBAction func continueAction(_ sender: UIButton) {
        if PFUser.current()?.value(forKey: DBColumn.isPaidUser) as? Bool ?? false {
            self.showToast(message: "You're already a paid user")
        } else {
            PFUser.current()?.setValue(true, forKey: DBColumn.isPaidUser)
            SVProgressHUD.show()
            ParseAPIManager.updateUserObject() { (success) in
                SVProgressHUD.dismiss()
                if success {
                    APP_MANAGER.session = PFUser.current()
//                    self.showToast(message: "Congrats on becoming a paid user")
                    
                    let vc = DoneVC(nibName: "DoneVC", bundle: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.showToast(message: "Failed to update to paid user")
                }
            } onFailure: { (error) in
                self.showToast(message: error)
            }
        }
    }
}

extension UIButton {
    //MARK:- Animate check mark
    func checkboxAnimation(closure: @escaping () -> Void){
        guard let image = self.imageView else {return}
        self.adjustsImageWhenHighlighted = false
        self.isHighlighted = false
        
        UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
            image.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
        }) { (success) in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                self.isSelected = !self.isSelected
                //to-do
                closure()
                image.transform = .identity
            }, completion: nil)
        }
        
    }
}
