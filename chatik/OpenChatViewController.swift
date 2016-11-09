//
//  OpenChatViewController.swift
//  chatik
//
//  Created by Dmitriy Egorov on 02/11/16.
//  Copyright © 2016 Migo group. All rights reserved.
//

import UIKit
import SendBirdSDK
import AVKit
import AVFoundation

class OpenChatViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, SBDChannelDelegate, SBDConnectionDelegate
{
    var openChat: SBDOpenChannel?
    var messageQuery: SBDPreviousMessageListQuery?
    var messages: [SBDBaseMessage] = []
    var delegateIdentifier: String?
    let messageCellidentifier = "messageCell"
    var isOnPlaceholderStyle = false

    @IBOutlet weak var textView: UITextView!
    /*{
        didSet
        {
            if self.textView.text.utf16.count == 0
            {
                setPlaceholderStyle()
            }
        }
    }*/
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let openChat = openChat
        {
            textView.layer.borderWidth = 1.0
            textView.layer.borderColor = UIColor.darkGrayColor().CGColor
            textView.layer.cornerRadius = 5
            sendButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Disabled)
            sendButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            
            navigationItem.title = openChat.name
            connectToOpenChat()
            
            textView.delegate = self
            self.tableView.delegate = self
            self.tableView.dataSource = self
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
            
            self.delegateIdentifier = self.description
            SBDMain.addChannelDelegate(self as SBDChannelDelegate, identifier: self.delegateIdentifier!)
            SBDMain.addConnectionDelegate(self as SBDConnectionDelegate, identifier: self.delegateIdentifier!)
            setPlaceholderStyle()
        }

    }
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        loadPreviousMessages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Open chat functions
    
    func connectToOpenChat()
    {
        self.openChat!.enterChannelWithCompletionHandler
            { (error) in
                if error != nil { print("can not enter the channel!") }
                else { print("entering the channel...") }
        }
    }
    //another commit
    func loadPreviousMessages()
    {
        self.messageQuery = self.openChat?.createPreviousMessageListQuery()
        self.messages.removeAll()
        self.messageQuery?.loadPreviousMessagesWithLimit(30, reverse: false, completionHandler: { (previousMessages, error) in
            if error != nil
            {
                print("Can not load previous messages")
            }
            else
            {
                print("Loading previous messages...")
                for message in previousMessages!
                {
                    self.messages.append(message)
                    print("message added")
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.scrollToLastMessage()
            })
        })
        
    }
    
    @IBAction func back(sender: UIBarButtonItem)
    {
        SBDMain.removeChannelDelegateForIdentifier(self.delegateIdentifier!)
        SBDMain.removeConnectionDelegateForIdentifier(self.delegateIdentifier!)
        let presentedModally = presentingViewController is UINavigationController
        if presentedModally
        {
            self.openChat!.exitChannelWithCompletionHandler(
                { (error) in
                if error != nil {
                    print("can not exit the channel!")
                    }
                })
            dismissViewControllerAnimated(true, completion: {})
        }
    }
    
    func closeOpenChat()
    {
        
    }
    
    @IBAction func send(sender: UIButton)
    {
        let message = self.textView.text
        self.openChat!.sendUserMessage(message) { (userMessage, error) in
            if error != nil
            {
                print("can not send a message!")
            }
            else
            {
                self.loadPreviousMessages()
                self.setPlaceholderStyle()
            }
        }
    }
    
    //MARK: Channel Delegate
    
    func channel(sender: SBDBaseChannel, didReceiveMessage message: SBDBaseMessage)
    {
        if sender == self.openChat
        {
            self.loadPreviousMessages()
        }
    }
    
    
    
    // MARK: TableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(messageCellidentifier, forIndexPath: indexPath)
        //display messages
        let message = messages[indexPath.row]
        if message is SBDUserMessage
        {
            let userMessage = message as! SBDUserMessage
            cell.textLabel?.text = userMessage.sender!.nickname!
            cell.detailTextLabel?.text = userMessage.message!
        }
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: TextView
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if text == "\n"
        {
            textView.resignFirstResponder()
            return false
        }
        if(isOnPlaceholderStyle && text != "Input message...")
        {
            setNonPlaceholderStyle()
        }
        return true
    }
    func textViewDidChange(textView: UITextView)
    {
        if self.textView.text.utf16.count == 0
        //if !textView.hasText()
        {
            setPlaceholderStyle()
        }
    }
    
    func textViewDidChangeSelection(textView: UITextView)
    {
        if isOnPlaceholderStyle
        {
            textView.selectedRange = NSMakeRange(0, 0)
        }
    }
    
    func setPlaceholderStyle()
    {
        textView.text = "Input message..."
        textView.textColor = UIColor.lightGrayColor()
        textView.selectedRange = NSMakeRange(0, 0)
        sendButton.enabled = false
        isOnPlaceholderStyle = true
    }
    func setNonPlaceholderStyle()
    {
        textView.text = ""
        textView.textColor = UIColor.darkTextColor()
        sendButton.enabled = true
        isOnPlaceholderStyle = false
    }
    
    
    func keyboardWillShow(notification: NSNotification)
    {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        {
            
            self.view.frame.size.height -= keyboardSize.height
            //self.scrollToLastMessage() она еще не показалась здесь
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        {
            self.view.frame.size.height += keyboardSize.height
        
        }
    }
    
    func keyboardDidShow(notification: NSNotification)
    {
        self.scrollToLastMessage()
    }
    
    func scrollToLastMessage()
    {
        if(self.messages.count != 0)
        {
            let indexPathToScroll = NSIndexPath(forRow: self.messages.count-1, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(indexPathToScroll, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        }
    }
    
    

    // MARK: - Navigation
    
    

    /* In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }*/
    

}
