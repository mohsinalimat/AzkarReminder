import UIKit
import CoreLocation


extension String{
    subscript (i: Int) -> String {
        
        return String(Array(self)[i])
    }
}

class PrayerTimesViewController: UIViewController, CLLocationManagerDelegate { //implements CLLocationManagerDelegate to get location
    
    
    //{"fajr":"05:27","sunrise":"06:48","zuhr":"12:25","asr":"15:35","maghrib":"18:01","isha":"19:18"}
    
    let locationManager = CLLocationManager()
    let URL_1 = "http://api.xhanch.com/islamic-get-prayer-time.php?lng="
    let URL_2 = "&lat="
    let URL_3 = "&yy="
    let URL_4 = "&mm="
    let URL_5 = "&gmt="
    let URL_6 = "&m=json"
    
    let FAJIR  = "fajr"
    let DUHUR = "zuhr"
    let ASR = "asr"
    let MAGRIB = "maghrib"
    let ISHA = "isha"
    let SUNRISE = "sunrise"
    
    let DAYSNUM = 30
    
    let ADNASOUND = "adanNaser.mp3"
    
    let fajirMessage = "حان الان موعد اذان الفجر"
    let sunriseMessage = "شروق"
    let duhurMessage = "حان الان موعد اذان الظهر"
    let asrMessage = "حان الان موعد اذان العصر"
    let magribMessage = "حان الان موعد اذان المغرب"
    let ishaMessage = "حان الان موعد اذان العشاء"

    
    
    @IBOutlet weak var fajirLabel: UILabel!
    @IBOutlet weak var sunRiseLabel: UILabel!
    @IBOutlet weak var duhurLabel: UILabel!
    @IBOutlet weak var asrLabel: UILabel!
    @IBOutlet weak var mageribLabel: UILabel!
    @IBOutlet weak var ishaLabel: UILabel!
    
    
    
    @IBAction func testLocalNotif(sender: AnyObject)
    {
        #if DEBUG
            
            println("fajir ==" + fajirLabel.text!)
            UIApplication.sharedApplication().cancelAllLocalNotifications();
            
            var notification = UILocalNotification()
            var calendar = NSCalendar.currentCalendar()
            var alaramDate = NSDate()
            let flags: NSCalendarUnit = NSCalendarUnit.CalendarUnitYear |
            NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute
            var components = calendar.components(flags, fromDate: alaramDate)
            components.hour = 3
            components.minute = 29
            
            
            // schduale the notitfcation and userInfo for it
           // var notificationInfo = [ "Hour" : hourString , "body" : message , "day" : day]
           // notification.userInfo = notificationInfo
            notification.fireDate = calendar.dateFromComponents(components)
            notification.alertBody = "blaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
            notification.soundName = "sub.caf"
            UIApplication.sharedApplication().scheduleLocalNotification(notification)

            
//            postNotificationForPrayer(FAJIR)
//            postNotificationForPrayer(DUHUR)
//            postNotificationForPrayer(ASR)
//            postNotificationForPrayer(MAGRIB)
//            postNotificationForPrayer(ISHA)
        #endif

    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        decorateViewController()
        
        
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitDay  , fromDate: date)
        let day = components.day

        //self.automaticLocationFinder();
        let timesDic = getTimeAtDay(day.description)
        if(timesDic.count == 0)
        {
            self.automaticLocationFinder()
        }
        else
        {
            updateLabels(timesDic)
        }
        
        
    }
    
    @IBAction func findMyLocation(sender: AnyObject)
    {
        automaticLocationFinder();
    }
    
    func automaticLocationFinder() //created this function to call from viewDidLoad for automaticFindLocation
    {
        //make the delegate self and accuracy and ask user for permission to get location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) // updated to location
    {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil)
            {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0
            {
                // placeMark at location 0 is the location
                let placeMark : CLPlacemark = placemarks[0] as CLPlacemark
                let location : CLLocation = placeMark.location;
                let coordinate : CLLocationCoordinate2D = location.coordinate;
                // get coordination and send it to finction to
                
                self.updatedToLocation(coordinate.longitude.description, latitude: coordinate.latitude.description);

            } else {
                println("Problem with the data received from geocoder")
            }
        })
    }
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!)
    {
        println("Error while updating location " + error.localizedDescription)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updatedToLocation(longtitude : NSString , latitude : NSString) // get longtitude and latitude and and GMT and year and month as NSString
    {
        locationManager.stopUpdatingLocation()
        print("my longtitude" + longtitude + "\n");
        print("my latitude" + latitude + "\n");
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay  , fromDate: date)
        let month = components.month
        let year = components.year
        let day = components.day
        
        
        #if DEBUG
        print("year = " + year.description + "\n")
        print("moth = " + month.description + "\n")
        print("day = " + day.description + "\n")
        #endif
        
        
        let timeZone : NSTimeZone = NSTimeZone.localTimeZone();
        
        
        #if DEBUG
        print("time zone = " + timeZone.description + "\n");
        #endif
            
            
        let secondsFromGMT : Int = timeZone.secondsFromGMT
        let GMT : Int = secondsFromGMT / 3600;
        
        
        
        #if DEBUG
        print("seconds from GMT = " + secondsFromGMT.description + "\n")
        #endif
            
        PrayerTimesUrlFrom(longtitude: longtitude, latitude: latitude, year: year.description, month: month.description, day: day.description ,GMT: GMT.description);
    }
    
    
    func PrayerTimesUrlFrom(longtitude myLongtitude : NSString , latitude :NSString , year : NSString , month : NSString , day : NSString ,GMT : NSString)
    {// make a url from lng and lat to get the prayer times as JSON and download them and store them 
        
        var urlString = URL_1;
        urlString = urlString + myLongtitude + URL_2 + latitude + URL_3 + year + URL_4 + month + URL_5 + GMT + URL_6;
        let urlRequest : NSURLRequest = NSURLRequest(URL: NSURL(string: urlString));
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(urlRequest) { data, urlResponse, error in
            
            if(error != nil)
            {
                print(error);
                return;
            }
            var jsonErrorOptional: NSError?
            // parse th JSON
            var webString : NSString = NSString(data: data, encoding: NSUTF8StringEncoding);
            
            
            #if DEBUG
            print("myWebString ====== " + webString + "\n");
            #endif
            

            let myData = (webString as NSString).dataUsingEncoding(NSUTF8StringEncoding);
            let jsonOptional: NSDictionary! = NSJSONSerialization.JSONObjectWithData(myData!, options: NSJSONReadingOptions(0), error: &jsonErrorOptional) as NSDictionary
            
            for (var i = 0; i <= self.DAYSNUM ; i++)
            {
                var timesDic  = jsonOptional.objectForKey(i.description) as NSDictionary?
                if(timesDic != nil)
                {
                    self.getTimesAndStore(times: timesDic! ,day: i.description)
                }
            }
            
        }
        task.resume()
    }
    
    
    func getTimesAndStore(times timesLocal : NSDictionary , day : NSString) //  this function update the labels
    {
        let fajir = timesLocal.objectForKey(self.FAJIR) as NSString
        let sunRise = timesLocal.objectForKey(self.SUNRISE) as NSString
        let duhur = timesLocal.objectForKey(self.DUHUR) as NSString
        let asr = timesLocal.objectForKey(self.ASR) as NSString
        let magrib = timesLocal.objectForKey(self.MAGRIB) as NSString
        let isha = timesLocal.objectForKey(self.ISHA) as NSString

        saveTimeAtDay(day, fajir, sunRise, duhur, asr, magrib, isha)
    }
    
    func updateLabels(times : [String : String])
    {
        fajirLabel.text = times[self.FAJIR]
        sunRiseLabel.text = times[self.SUNRISE]
        duhurLabel.text = times[self.DUHUR]
        asrLabel.text = times[self.ASR]
        mageribLabel.text = times[self.MAGRIB]
        ishaLabel.text = times[self.ISHA]
    }
    
    func decorateViewController()
    {
        self.view.backgroundColor = UIColor.grayColor()
    }
    
    
    
    
    func postNotificationForPrayer(prayer: String) //function decide what prayer time I want to make a local notification for
    {
        

        //get the current day 😄
        var calendar = NSCalendar.currentCalendar()
        var alaramDate = NSDate()
        let flags: NSCalendarUnit = NSCalendarUnit.CalendarUnitYear |
            NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute
        var components = calendar.components(flags, fromDate: alaramDate)
        let currentDay = components.day
        
        
        switch prayer
        {
            
        case FAJIR:
            postPrayerTimeNotificationAtTime(fajirLabel.text, message: fajirMessage, day: currentDay.description)
            
        case SUNRISE:
            postPrayerTimeNotificationAtTime(sunRiseLabel.text, message: sunriseMessage, day: currentDay.description)
            
        case DUHUR:
            postPrayerTimeNotificationAtTime(duhurLabel.text, message: duhurMessage, day: currentDay.description)
            
        case ASR:
            postPrayerTimeNotificationAtTime(asrLabel.text , message: asrMessage , day:currentDay.description)
            
        case MAGRIB:
            postPrayerTimeNotificationAtTime(mageribLabel.text , message: magribMessage , day: currentDay.description)
            
        case ISHA:
            postPrayerTimeNotificationAtTime(ishaLabel.text , message : ishaMessage , day: currentDay.description)
            
            
        default :
            #if DEBUG
            println("Error not valid prayerTime name!!!!!");
            #endif
        }
    }
    
    
    func postPrayerTimeNotificationAtTime(time : String? , message : String , day :String)//post a local notification for a given prayerTime a message and a day
        
    {
        if time == nil
        {
            
            println("error nill value");
            return;
        }
        
        let localTime = time!
        
        //time = XY:WZ
        
        let hourString = time![0] + time![1];
        let minuteString = time![3] + time![4];

        
        
        if let hour = hourString.toInt()
        {
            
            if let minute = minuteString.toInt()
            {
                #if DEBUG
                    println("setting notification on hour: " + hour.description + "and minute: " + minute.description)
                #endif
                // make notification which repeats it self every day
                var notification = UILocalNotification()
                var calendar = NSCalendar.currentCalendar()
                var alaramDate = NSDate()
                let flags: NSCalendarUnit = NSCalendarUnit.CalendarUnitYear |
                    NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute
                var components = calendar.components(flags, fromDate: alaramDate)
                components.hour = hour
                components.minute = minute
                
                
                // schduale the notitfcation and userInfo for it
                var notificationInfo = [ "Hour" : hourString , "body" : message , "day" : day]
                notification.userInfo = notificationInfo
                notification.fireDate = calendar.dateFromComponents(components)
                notification.alertBody = message
                notification.soundName = ADNASOUND
                UIApplication.sharedApplication().scheduleLocalNotification(notification)

            }
            else
            {
                println("error wrong conversion")
                return
            }
        }
        else
        {
            println("error wrong conversion")
            return
        }
        
    }
    
    

    
}