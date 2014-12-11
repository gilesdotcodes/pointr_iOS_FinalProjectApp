//
//  FirstViewController.swift
//  Pointr
//
//  Created by Stephen Giles on 02/12/2014.
//  Copyright (c) 2014 Stephen Giles. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var findFriendName: UITextField!
    
    
    @IBOutlet weak var friendList: UILabel!
    @IBOutlet weak var chooseFriend: UIPickerView!
    @IBOutlet weak var pointSlider: UISlider!
    @IBOutlet weak var pointsSent: UILabel!
    @IBOutlet weak var friendSent: UILabel!
    var currentFriend: String!
    
    var friendFound: String = ""
    var connectionFound: String = ""
    
    var pointsAwarded: Float = 0
    
//    let friendListData = ["Tim","Fadie","Andrew","Steve","Snozza","Craig","Zee"]
    var friendListData = [String]()
    
    func loadData() {
        friendListData.removeAll(keepCapacity: false)
        
        var findFriendListData:PFQuery = PFQuery(className:"Connections")
        var currentUserObject = PFUser.currentUser()
        var currentUser = currentUserObject.username
        println(currentUser)
        
        findFriendListData.whereKey("user1", equalTo:currentUser)
        findFriendListData.findObjectsInBackgroundWithBlock
            {
                (objects:[AnyObject]! , error:NSError!) -> Void in
                if error == nil
                {
                    for(var i=0; i<objects.count; i++) {
                        var object=objects[i] as PFObject
                        var name = object.objectForKey("user2") as String
                        println(name)
                        if(name != currentUser) {
                            self.friendListData.append(name)
                        }
                    }
                    self.chooseFriend.reloadAllComponents()
                }
                
        }
    
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool){
        
        
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        chooseFriend.dataSource = self
        chooseFriend.delegate = self
        self.loadData()
        
    }
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return friendListData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        return friendListData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentFriend = friendListData[row]
        friendSent.text = "to \(currentFriend)"
    }

    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let pickerLabel = UILabel()
        let titleData = friendListData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Chalkboard SE", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel.backgroundColor = UIColor.whiteColor()
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .Center
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
    @IBAction func updatePoints(sender: AnyObject) {
        pointsAwarded = pointSlider.value
        refreshUI()
    }
    
    
    func refreshUI() {
        pointsSent.text = "Award \(Int (pointSlider.value)) point(s)"
    }
    
    func refreshMainPage() {
        pointsSent.text = ""
        friendSent.text = ""
        pointSlider.value = 0
    }

    
    @IBAction func sendPoints(sender: AnyObject) {
        if(Int(pointsAwarded)>0 && currentFriend != nil){
            var currentUser = PFUser.currentUser()
            var points:PFObject = PFObject(className: "Points")
            points["sender"] = currentUser.username
            points["receiver"] = currentFriend
            points["points"] = Int(pointsAwarded)

            points.saveInBackgroundWithTarget(nil, selector: nil)
            
            var alert = UIAlertController(title: "Awesome!", message: "You sent \(currentFriend) \(Int(pointsAwarded)) points!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Send more points!", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            self.refreshMainPage()
        }
        
    }
    
    @IBAction func addFriend(sender: AnyObject) {
        var currentUser = PFUser.currentUser()
        self.checkFriendExists(findFriendName.text)
        self.checkConnectionExists(findFriendName.text)
        if(friendFound == "true" && connectionFound == "false") {
        
            var connection:PFObject = PFObject(className: "Connections")
            connection["user1"] = currentUser.username
            connection["user2"] = findFriendName.text
            connection.saveInBackgroundWithTarget(nil, selector: nil)
            
            var reverseConnection:PFObject = PFObject(className: "Connections")
            reverseConnection["user1"] = findFriendName.text
            reverseConnection["user2"] = currentUser.username
            reverseConnection.saveInBackgroundWithTarget(nil, selector: nil)
            
            var alert = UIAlertController(title: "Success", message: "The user \(findFriendName.text) has been added to your friend list!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Search again", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            self.refreshMainPage()
            self.loadData()
        
        }
        if(friendFound == "true" && connectionFound == "true") {
            var alert = UIAlertController(title: "Oops!", message: "You're already friends with \(findFriendName.text)!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            findFriendName.text = ""
        }
        else {
            var alert = UIAlertController(title: "Error", message: "The user \(findFriendName.text) does not exist!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Search again", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            findFriendName.text = ""
        }
    
    }

    func checkFriendExists(name: String) {
        var friendQuery:PFQuery = PFQuery(className:"_User")
        var result:String!
        friendQuery.whereKey("username", equalTo:name)
        var object = friendQuery.getFirstObject()
        if object != nil {
            println("Retrieved object")
            result = "true"
        } else {
            println("Request failed")
            result = "false"
        }
        self.friendFound = result
    }
    
    func checkConnectionExists(name: String) {
        var currentUser = PFUser.currentUser()
        self.checkFriendExists(findFriendName.text)
        var connectionQuery:PFQuery = PFQuery(className:"Connections")
        var result:String!
        connectionQuery.whereKey("user1", equalTo:currentUser.username)
        connectionQuery.whereKey("user2", equalTo: name)
        var object = connectionQuery.getFirstObject()
        if object != nil {
            println("Connection exists")
            result = "true"
        } else {
            println("Connection does NOT exist")
            result = "false"
        }
        self.connectionFound = result
    }
    
    @IBAction func viewTapped(sender : AnyObject) {
        findFriendName.resignFirstResponder()
    }
    
//    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//        super.touchesBegan(touches, withEvent: event)
//        self.view.resignFirstResponder()
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

