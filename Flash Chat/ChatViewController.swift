//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import  Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArray : [Message]  = [Message]()
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        do{
            try  Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }catch{
            print("error: there was a problem logging out")
        }
    }

    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        //when the send Button gets triggered we are going to create a reference to a new database inside our main database, and we are going to give it a name called "messages".
        let messagesDB=Database.database().reference().child("Messages")
        //to save the usere message as a dictionary.
        
        let messageDictionary=["Sender":Auth.auth().currentUser?.email, "MessageBody":messageTextfield.text!]
        //childByAutoId() it creates a custom random key for our message, so that our message ca be saved under their own unique独特的 identifier.
        
        messagesDB.childByAutoId().setValue(messageDictionary){
        //setValue(messageDictionary): essentially all that this line is doing is we are saving our message dictionary insider our "messages" database under a automaticallygenerated identifier.
            (error, referenc) in
            if error != nil {
                print(error!)
            }else{
                print("message saved successfully")
            }
            self.messageTextfield.isEnabled = true
            self.sendButton.isEnabled = true
            self.messageTextfield.text = ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextfield.delegate = self
        
        retrieveMessages()//在firebase内取出message
        
        configereTableView()//定义Cell的高度来自于func configereTableView()
        
        //Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName:"MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        //TODO: Set the tapGesture here:如果点击TextField以外的画面将键盘回收。
        let tabGesture=UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tabGesture)
    }
        @objc func tableViewTapped(){
        messageTextfield.endEditing(true)//键盘回收
    }
    
    //Declare configureTableView here:
    func configereTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension//定义Cell的高度以文字的多少而自动决定。
        messageTableView.estimatedRowHeight = 120.0//standard 高度定义为 120。
    }
    
    //MARK: - TableView DataSource Methods
    
    //TODO: Declare cellForRowAtIndexPath here:

    //MARK:- TextField Delegate Methods
    
    //Declare textFieldDidBeginEditing here:如果TextField被点击的话heightConstraint就以0.2秒的速度会升高到358pixel。
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2){
            self.heightConstraint.constant = 358
            self.view.layoutIfNeeded()//这语句和tableview.reload()功能相同，只是是Constrain Lyout的Reload，意思是只要uiview中有变动的话就reload。
        }
    }
    //Declare textFieldDidEndEditing here: 这个功能适合tabGesture一起使用的，tabGesture定义是让tableView反应用户点击了textField意外的地方，如果点击了textField意外的地方后heightConstraint将会以0.2秒的速度降下回到原来的50pixel。
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2){
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()//这语句和tableview.reload()功能相同，只是是Constrain Lyout的Reload，意思是只要uiview中有变动的话就reload。
        }
    }

    //MARK: - Send & Recieve from Firebase

    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages() {
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observe(DataEventType.childAdded, with: { (snapshot) in
            
            let snapShotValue = snapshot.value as! Dictionary<String, String>
            
            let text = snapShotValue["MessageBody"]!
            let sender = snapShotValue["Sender"]!
            print(text, sender)
            
            let message = Message()
            message.messageBody = text
            message.sender = sender
            self.messageArray.append(message)
            self.configereTableView()
            self.messageTableView.reloadData()
            
        })
        
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image=UIImage(named: "Die Diamantspitzhacke")
        return cell
        
    }
    
    //TODO: Declare numberOfRowsInSection here:
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
}

    
    
    

