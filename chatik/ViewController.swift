//
//  ViewController.swift
//  chatik
//
//  Created by Dmitriy Egorov on 01/11/16.
//  Copyright © 2016 Migo group. All rights reserved.
//

import UIKit
import SendBirdSDK
import Dispatch

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    var isUploaded:Bool = false{
        didSet {
            reloadMyTable()
        }
    }
    
    let channelCellIdentifier = "openChannels"
    //let USER_ID = "anton.chugunov10@gmail.com"
    //let USER_ID = "00000001"
    let USER_ID = "anton.chugunov9@yandex.ru"
    let USER_NICKNAME = "Antoha"
    
    private var openChannelListQuery:SBDOpenChannelListQuery?
    private var channels:[SBDOpenChannel] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        isUploaded = false
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func connectToDB(sender: UIButton)
    {
        SBDMain.connectWithUserId(USER_ID)
        { (USER_NICKNAME, error) in
            if error != nil {
                print("Error!")
            }
            else {
                print("Connected!!!!")
            }
        }
    }

    @IBAction func connectToOpenChannel(sender: UIButton)
    {
        self.channels.removeAll()
        self.openChannelListQuery = SBDOpenChannel.createOpenChannelListQuery()
        self.openChannelListQuery?.limit = 20
        if self.openChannelListQuery?.hasNext == false
        {
            return
        }
        loadChannelListQuery()
    }
    
    func loadChannelListQuery()
    {
        self.openChannelListQuery?.loadNextPageWithCompletionHandler({ (channels, error) in
            if error != nil
            {
                print("Error!")
                return
            }
            
            for channel in channels!
            {
                self.channels.append(channel)
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        })
        
    }
    
    func reloadMyTable()
    {
        if isUploaded
        {
            self.tableView.reloadData()
            isUploaded = false
        }
    }
    
    //MARK: TableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(channelCellIdentifier, forIndexPath: indexPath)
        let channel = channels[indexPath.row]
        cell.textLabel?.text = channel.name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("should to open chat")
    }
    
    //MARK: SEGUES
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "connectToOpenChat"
        {
            var chat:SBDOpenChannel = SBDOpenChannel()
            /*if(sender is UIBarButtonItem)
            {
                for channel in self.channels
                {
                    if channel.name == "chat.ru"
                    {
                        chat = channel
                    }
                }
            }*/
            if let selectedChat = sender as? UITableViewCell
            {
                let indexPath = tableView.indexPathForCell(selectedChat)!
                chat = channels[indexPath.row]
            }
            let nav = segue.destinationViewController as! UINavigationController
            let destVC = nav.topViewController as! OpenChatViewController
            destVC.openChat = chat
            print("Opening " + chat.name + "...")
        }
    }
}

