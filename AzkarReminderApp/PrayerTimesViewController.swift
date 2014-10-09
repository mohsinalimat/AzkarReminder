import UIKit
import CoreLocation

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
    let ESHA = "isha"

    
    
    @IBOutlet weak var fajirLabel: UILabel!
//    @IBOutlet weak var fajirLabel: UILabel!
//    @IBOutlet weak var duhurLabel: UILabel!
//    @IBOutlet weak var asrLabel: UILabel!
//    @IBOutlet weak var magribLabel: UILabel!
//    @IBOutlet weak var eshaLabel: UILabel!
    
    
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        self.automaticLocationFinder();
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
            
            
            let timesDic  = jsonOptional.objectForKey(day) as NSDictionary?
            
//            let fajir = myArray?.objectForKey(self.FAJIR) as NSString
//            let duhur = myArray?.objectForKey(self.DUHUR) as NSString
//            let asr = myArray?.objectForKey(self.ASR) as NSString
//            let magrib = myArray?.objectForKey(self.MAGRIB) as NSString
//            let esha = myArray?.objectForKey(self.ESHA) as NSString
//            
//            let timesArray : NSArray
            
            
            self.getTimesAndUpdateLabels(times: timesDic!)

            //let
            
            
            
            
//            #if DEBUG
//                print("ptinting Array");
//            for item in myArray!
//            {
//                print(item);
//                print("\n");
//            }
//            #endif
            
        }
        task.resume()
    }
    
    
    func getTimesAndUpdateLabels(times timesLocal : NSDictionary) //  this function update the labels
    {
        fajirLabel.text = timesLocal[self.FAJIR] as NSString
    }

    
}