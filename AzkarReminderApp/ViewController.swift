//
//  ViewController.swift
//  AzkarReminderApp
//
//  Created by muhammad abed el razek on 9/16/14.
//  Copyright (c) 2014 aboelbisher. All rights reserved.
//

import UIKit

class ViewController: UIViewController , NSURLConnectionDelegate
{
    
    
    let MAX_HOUR = 24
    let URL = "http://www.wabbass.byethost9.com/Azkar.html"
    let JSON_ARRAY_NAME = "MyStringArray"
    
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var collision : UICollisionBehavior!
    

    
    @IBOutlet weak var ta3telTaf3elLabel: UILabel!
    @IBOutlet weak var sa3aLabel: UILabel!
    @IBOutlet weak var zakerneKolLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var switcher: UISwitch!

    var azkar :NSArray?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        

        var tapRec = UITapGestureRecognizer(target: self, action: "viewTapped:")
        animator = UIDynamicAnimator(referenceView: view)
        let welcomeView = createWelcomeView(self.view)
        welcomeView.addGestureRecognizer(tapRec);
        
        createLabelAtCenterOfView(welcomeView)
        createImageViewAtCenterOf(welcomeView)
        
        gravity = UIGravityBehavior(items: [welcomeView])
        gravity.angle = CGFloat(-M_PI_2);
        gravity.magnitude = 2;
        animator.addBehavior(gravity)
        
        collision = UICollisionBehavior(items: [welcomeView])
        collision.addBoundaryWithIdentifier("bottom", fromPoint: CGPoint(x: 0, y: self.view.bounds.height*2), toPoint: CGPoint(x: self.view.bounds.width, y: self.view.bounds.height*2));
        collision.addBoundaryWithIdentifier("top", fromPoint: CGPoint(x: 0, y: -1), toPoint: CGPoint(x: self.view.bounds.width, y: -1))
        animator.addBehavior(collision);

        
        
        var myValue : Float = 0.0
        myValue = NSUserDefaults.standardUserDefaults().floatForKey("sliderValue")
        var intValue  = Int(myValue * 10)
        if(myValue - Float(intValue) >= 0.5)
        {
            intValue += 1
        }
        var hourString = intValue.description
        hourLabel.text = hourString
        slider.setValue( myValue, animated: true)
        
        getJson();
       
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        setDecorations();
        self.view.backgroundColor = UIColor.grayColor();
    }
    
    
    func setDecorations()
    {
        self.ta3telTaf3elLabel.textColor = UIColor.yellowColor();
        self.sa3aLabel.textColor = UIColor.yellowColor();
        self.zakerneKolLabel.textColor = UIColor.yellowColor();
        self.hourLabel.textColor = UIColor.yellowColor();
        self.hourLabel.textAlignment = NSTextAlignment.Center;
        
        self.slider.tintColor = UIColor.yellowColor();
        self.switcher.tintColor = UIColor.yellowColor();
    }
    
    func posNotification(atHour : Int , message: String)
    {
        
        if(atHour < 0 || atHour > 24)
        {
            #if DEBUG
            NSLog("wrong hour to set!")
            NSLog(atHour.description)
            #endif
            return ;
        }
        
        var notification = UILocalNotification()
        var calendar = NSCalendar.currentCalendar()
        var alaramDate = NSDate()
        let flags: NSCalendarUnit = NSCalendarUnit.CalendarUnitYear |
            NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute
        var components = calendar.components(flags, fromDate: alaramDate)
        components.hour = atHour
        components.minute = 0
        
        var stringHour = String(atHour)
        
        
        var notificationInfo = [ "Hour" : stringHour , "body" : message]
        notification.userInfo = notificationInfo
        notification.repeatInterval = NSCalendarUnit.CalendarUnitDay
        notification.fireDate = calendar.dateFromComponents(components)
        notification.alertBody = message
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func postNotifications()
    {
        var sliderValue = self.slider.value
        
        var intValue  = Int(sliderValue * 10)
        if(sliderValue - Float(intValue) >= 0.5)
        {
            intValue += 1
        }
        
        for var i = 0; i <= MAX_HOUR; i+=intValue
        {
            var random = arc4random_uniform(UInt32(self.azkar!.count))
            var message : NSString = azkar![Int(random)] as NSString
            posNotification(i, message: message)
            
        }
    }
    
    
    
    @IBAction func changed(sender: UISwitch)
    {
        if(sender.on)
        {
            postNotifications()
        }
        else
        {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
    }
    
    
    @IBAction func sliderValueChanged(sender: UISlider)
    {
        var floatValue = sender.value * 10
        
        
        
//        var stringFloatValue = "float value is "
//        stringFloatValue += floatValue.description
//        stringFloatValue += "\n"
        
        
        var intValue : Int = Int(floatValue)
        //var stringIntValue = "int value is: "
        
        
        
        if(floatValue - Float(intValue) >= 0.5)
        {
            intValue += 1
        }
        
        //stringIntValue + intValue.description + "\n"
        
        var newValue :Float = Float(intValue)
        newValue/=10
        self.slider.setValue(newValue, animated: true)
        
        NSUserDefaults.standardUserDefaults().setFloat(newValue, forKey: "sliderValue")
        
        var hourString = intValue.description
        hourLabel.text = hourString
        
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()

        
        if(newValue == 0)
        {
            self.switcher.setOn(false, animated: true);
        }
        else
        {
            if(!self.switcher.on)
            {
                self.switcher.setOn(true, animated: true);
            }
            postNotifications()
        }
    }
    
    
    
    func createWelcomeView(inView : UIView) ->UIView
    {
        let welcomeView = UIView(frame: CGRect(x: 0, y: 0, width: inView.bounds.size.width, height:inView.bounds.size.height))
        welcomeView.backgroundColor = UIColor.greenColor()
        // welcomeView.alpha = 1;
        inView.addSubview(welcomeView)
        
        return welcomeView;
        
    }
    
    func viewTapped(recognizer : UITapGestureRecognizer)
    {
        self.gravity.angle = CGFloat(M_PI_2);
    }
    

    @IBAction func showInfo(sender: UIButton)
    {
        self.gravity.angle = CGFloat(-M_PI_2);

    }
    
    
    func createLabelAtCenterOfView(inView : UIView)
    {
        var label : UILabel = UILabel(frame: inView.frame)
        label.text = "تطبيق اذكار"
        label.textColor = UIColor.blackColor()
        
        label.textAlignment = NSTextAlignment.Center
        label.sizeToFit()
        label.center = inView.center
        
        inView.addSubview(label)
    }
    
    func createImageViewAtCenterOf(inView : UIView)
    {
        var imageView : UIImageView = UIImageView(frame: inView.frame)
        
        var image : UIImage = UIImage(named: "frontScreen")
        imageView.image = image
        
        imageView.center = inView.center
        inView.addSubview(imageView)
    }
    
    
    
    
    func getJson()
    {
        let urlRequest = NSURLRequest(URL: NSURL(string: URL));

        let task = NSURLSession.sharedSession().dataTaskWithRequest(urlRequest) { data, urlResponse, error in
            
            if(error != nil)
            {
                print(error);
                return;
            }
            var jsonErrorOptional: NSError?
            var webString : NSString = NSString(data: data, encoding: NSUTF8StringEncoding);
            webString = webString.stringByReplacingOccurrencesOfString("<html>" , withString: "");
            webString = webString.stringByReplacingOccurrencesOfString("</html>", withString: "");
            webString = webString.stringByReplacingOccurrencesOfString("\n", withString: "")
            webString = webString.stringByReplacingOccurrencesOfString("\\", withString: "");
            let myData = (webString as NSString).dataUsingEncoding(NSUTF8StringEncoding);
            let jsonOptional: NSDictionary! = NSJSONSerialization.JSONObjectWithData(myData!, options: NSJSONReadingOptions(0), error: &jsonErrorOptional) as NSDictionary
            let myArray :NSArray?  = jsonOptional.objectForKey(self.JSON_ARRAY_NAME) as NSArray?;
            
            #if DEBUG
            for item in myArray!
            {
                print(item);
                print("\n");
            }
            #endif
            
            self.azkar = myArray;
        }
        task.resume()
    }
    
    
    
}

