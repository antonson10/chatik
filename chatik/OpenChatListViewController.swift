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

class OpenChatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    
    let channelCellIdentifier = "openChannels"
    
    
    private var openChannelListQuery:SBDOpenChannelListQuery?
    private var channels:[SBDOpenChannel] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.connectToOpenChannel()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func connectToOpenChannel()
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
    
    @IBAction func clickBack(sender: UIBarButtonItem)
    {
        closeOpenChatList()
    }
    
    func closeOpenChatList()
    {
        let presentedModally = presentingViewController is UINavigationController
        if presentedModally
        {
            dismissViewControllerAnimated(true, completion: {})
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

