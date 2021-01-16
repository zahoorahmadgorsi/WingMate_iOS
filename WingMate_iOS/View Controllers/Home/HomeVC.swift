//
//  HomeVC.swift
//  WingMate_iOS
//
//  Created by Danish Naeem on 1/9/21.
//

import UIKit

class HomeVC: BaseViewController {
    let presenter = HomePresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attach(vc: self)
    }
}

extension HomeVC: HomeDelegate {
    
}
