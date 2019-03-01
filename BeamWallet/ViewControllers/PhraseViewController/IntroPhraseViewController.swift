//
//  IntroPhraseViewController.swift
//  BeamWallet
//
//  Created by Denis on 3/1/19.
//  Copyright © 2019 Denis. All rights reserved.
//

import UIKit

class IntroPhraseViewController: UIViewController {
    
    @IBOutlet private weak var stackWidth: NSLayoutConstraint!
    @IBOutlet private weak var mainStack: UIStackView!
    @IBOutlet private weak var stackY: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Create new wallet"
        
        if Device.screenType == .iPhones_5_5s_5c_SE {
            stackWidth.constant = 290
            stackY.constant = 15
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //MARK: IBAction
    
    @IBAction func onNext(sender :UIButton) {
        let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        let vc = DisplayPhraseViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}