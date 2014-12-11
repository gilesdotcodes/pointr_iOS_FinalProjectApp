//
//  SecondViewController.swift
//  Pointr
//
//  Created by Stephen Giles on 02/12/2014.
//  Copyright (c) 2014 Stephen Giles. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet var myPoints: UILabel!
    
    @IBOutlet var myPointsNews1: UILabel!
    @IBOutlet var myPointsNews2: UILabel!
    @IBOutlet var myPointsNews3: UILabel!
    
    override func viewDidLoad() {
        myPoints.layer.masksToBounds = true
        myPoints.layer.cornerRadius = 10
        
        myPointsNews1.layer.masksToBounds = true
        myPointsNews1.layer.cornerRadius = 5

        myPointsNews2.layer.masksToBounds = true
        myPointsNews2.layer.cornerRadius = 5
        
        myPointsNews3.layer.masksToBounds = true
        myPointsNews3.layer.cornerRadius = 5
        
        super.viewDidLoad()
    }
    
    func loadMyDashboard() {
        self.loadMyPointsNews()
        self.loadMyPoints()
    }
    
    func loadMyPointsNews() {
        var myPointsNews: [String] = []
        var currentUser = PFUser.currentUser()
        var pointsNewsData:PFQuery = PFQuery(className:"Points")
        pointsNewsData.whereKey("receiver", equalTo:currentUser.username)
        pointsNewsData.orderByDescending("createdAt")
        pointsNewsData.limit = 3
        pointsNewsData.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                println("Success - loadMyPointsNews function")
                for object in objects {
                    var sender = object.objectForKey("sender") as String
                    var points = object.objectForKey("points") as Int
                    var sentence = ("\(sender) sent you \(points) points")
                    myPointsNews.append(sentence)
                    println(myPointsNews)
                }
                
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
            if(myPointsNews.count > 0){
                self.myPointsNews1.text = myPointsNews[0]
            }
            if(myPointsNews.count > 1) {
                self.myPointsNews2.text = myPointsNews[1]
            }
            if(myPointsNews.count > 2) {
                self.myPointsNews3.text = myPointsNews[2]
            }
        }
    }
    
    
    func loadMyPoints() {
        var myPointsValue: Int = 0
        var currentUser = PFUser.currentUser()
        var pointsData:PFQuery = PFQuery(className:"Points")
        pointsData.whereKey("receiver", equalTo:currentUser.username)
        pointsData.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                println("Success - loadMyPoints function")
                for object in objects {
                    var points = object.objectForKey("points") as Int
                   myPointsValue += points
                    println(myPointsValue)
                }

            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
        
        var myPointsValueAsString = String(myPointsValue)
        self.myPoints.text = myPointsValueAsString
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if((PFUser.currentUser()) != nil) {
            self.loadMyDashboard()
        }
        
        // see if there is a current user
        
        if((PFUser.currentUser()) == nil){
            
            var loginAlert:UIAlertController = UIAlertController(title: "Welcome to Pointr!", message: "Please sign up or login", preferredStyle: UIAlertControllerStyle.Alert)
            
            loginAlert.addTextFieldWithConfigurationHandler({
                textfield in
                textfield.placeholder = "Username"
                
            })
            
            loginAlert.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.Default, handler: {
                alertAction in
                let textFields:NSArray = loginAlert.textFields as AnyObject! as NSArray
                let usernameTextField:UITextField = textFields.objectAtIndex(0) as UITextField
                
                PFUser.logInWithUsernameInBackground(usernameTextField.text, password: "password"){
                    (user:PFUser!, error:NSError!)->Void in
                    if((user) != nil){
                        println("Login Successful")
                        self.loadMyDashboard()
                    }else{
                        self.presentViewController(loginAlert, animated: true, completion: nil)
                        usernameTextField.text = ""
                        loginAlert.title = "Error!"
                        loginAlert.message = "That username has not been found. Please sign up to use pointr."

                    }
                }
                
            }))
            
            
            
            loginAlert.addAction(UIAlertAction(title: "Sign Up", style: UIAlertActionStyle.Default, handler: {
                alertAction in
                let textFields:NSArray = loginAlert.textFields as AnyObject! as NSArray
                let usernameTextField:UITextField = textFields.objectAtIndex(0) as UITextField
                
                var user:PFUser = PFUser()
                user.username = usernameTextField.text
                user.password = "password"
    
                user.signUpInBackgroundWithBlock{
                    (success:Bool!, error:NSError!)-> Void in
                    
                    if (error == nil) {
                        println("Sign Up Successful")
                        self.loadMyDashboard()
                    }else{
                        self.presentViewController(loginAlert, animated: true, completion: nil)
                        usernameTextField.text = ""
                        loginAlert.title = "Error!"
                        loginAlert.message = "That username has already been registered. Please choose another username."
                        
                    }
                }
                
                
            }))
            
            self.presentViewController(loginAlert, animated: true, completion: nil)
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

