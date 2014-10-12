//
//  CompassViewController.swift
//  AzkarReminderApp
//
//  Created by muhammad abed el razek on 10/11/14.
//  Copyright (c) 2014 aboelbisher. All rights reserved.
//

import UIKit
import CoreLocation



class CompassViewController: UIViewController , CLLocationManagerDelegate
{
    
    @IBOutlet weak var compassImage: UIImageView!
    
    
    let locationManager : CLLocationManager = CLLocationManager()
    var currentHeading : CLHeading = CLHeading()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = 1
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
    }
    
    
    
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!)
    {
        var oldRad = -manager.heading.trueHeading * M_PI / 180.0
        let newRad = -newHeading.trueHeading * M_PI / 180.0
        var theAnimation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation")
        theAnimation.fromValue = NSNumber(double: oldRad)
        theAnimation.toValue = NSNumber(double: newRad)
        theAnimation.duration = 0.2
        compassImage.layer.addAnimation(theAnimation, forKey: "animateMyRotation")
        compassImage.transform = CGAffineTransformMakeRotation(CGFloat(newRad))
    }

    
}