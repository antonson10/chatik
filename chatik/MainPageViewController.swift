//
//  MainPageViewController.swift
//  chatik
//
//  Created by Dmitriy Egorov on 09/11/16.
//  Copyright © 2016 Migo group. All rights reserved.
//

import UIKit
import SendBirdSDK
import Dispatch

class MainPageViewController: UIViewController, UITextFieldDelegate
{
    
    @IBOutlet weak var connectToOpenChatButton: UIButton!
    @IBOutlet weak var connectToBaseChatButton: UIButton!
    //let USER_ID = "anton.chugunov10@gmail.com"
    //let USER_ID = "00000001"
    let USER_ID = "anton.chugunov9@yandex.ru"
    let USER_NICKNAME = "Antoha"

    @IBOutlet weak var userIdentifier: UITextField!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.userIdentifier.text = USER_ID
        self.userIdentifier.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connectToDB(sender: UIButton)
    {
        if let user_id = self.userIdentifier.text
        {
            SBDMain.connectWithUserId(user_id)
            { (USER_NICKNAME, error) in
                if error != nil {
                    print("Error!")
                }
                else {
                    print("Connected!!!!")
                }
            }
        }
        else
        {
            print("input user id")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        self.userIdentifier.resignFirstResponder()
        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        
    }
 

}
