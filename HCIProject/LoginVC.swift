//
//  LoginVC.swift
//  HCIProject
//
//  Created by AB Brooks on 11/13/18.
//  Copyright © 2018 AB Brooks. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var usernameTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTF.attributedPlaceholder = NSAttributedString(string: "username",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 166/255, green: 166/255, blue: 167/255, alpha: 0.5)])
        passwordTF.attributedPlaceholder = NSAttributedString(string: "password",
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 166/255, green: 166/255, blue: 167/255, alpha: 0.5)])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        return true
    }

    @IBAction func signIn(_ sender: Any) {
        self.performSegue(withIdentifier: "goARModeVC", sender: self)
    }
}
