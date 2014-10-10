//
//  CoreDataSave.swift
//  AzkarReminderApp
//
//  Created by muhammad abed el razek on 10/10/14.
//  Copyright (c) 2014 aboelbisher. All rights reserved.
//
import UIKit
import CoreData

let FAJIR  = "fajr"
let DUHUR = "zuhr"
let ASR = "asr"
let MAGRIB = "maghrib"
let ISHA = "isha"
let SUNRISE = "sunrise"

func saveTimeAtDay(day : NSString , fajir : NSString , sunRise : NSString , duhur : NSString , asr : NSString , magrib : NSString , isha : NSString)
{
    var appDel : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var context : NSManagedObjectContext = appDel.managedObjectContext!
    
    let tmpDic :Dictionary = getTimeAtDay(day)
    if(tmpDic.count != 0) // the entity is already saved
    {
        return;
    }
    
    var newTime = NSEntityDescription.insertNewObjectForEntityForName("Times", inManagedObjectContext: context) as NSManagedObject
    newTime.setValue(day, forKey: "day")
    newTime.setValue(fajir, forKey: FAJIR)
    newTime.setValue(sunRise, forKey: SUNRISE)
    newTime.setValue(duhur, forKey: DUHUR)
    newTime.setValue(asr, forKey: ASR)
    newTime.setValue(magrib, forKey: MAGRIB)
    newTime.setValue(isha, forKey: ISHA)
    
    //TODO : add error handling
    context.save(nil)
    
    //#if DEGUB
    println("saved Entity = " + newTime.description);
    //#endif
    
}

func getTimeAtDay(day: NSString)-> [String : String]
{
    var appDel : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var context : NSManagedObjectContext = appDel.managedObjectContext!
    
    var request : NSFetchRequest = NSFetchRequest(entityName: "Times")
    let predicate : NSPredicate = NSPredicate(format: "day = %@", day)
    request.predicate = predicate
    
    // TODO : add error handling
    var results : NSArray = context.executeFetchRequest(request, error: nil)!
    
    
    var timesDic : [String : String] = Dictionary()
    
    if results.count > 0 //it suppose to have one element
    {
        var time = results[0] as NSManagedObject
        timesDic[FAJIR] = time.valueForKey(FAJIR) as NSString
        timesDic[SUNRISE] = time.valueForKey(SUNRISE) as NSString
        timesDic[DUHUR] = time.valueForKey(DUHUR) as NSString
        timesDic[ASR] = time.valueForKey(ASR) as NSString
        timesDic[MAGRIB] = time.valueForKey(MAGRIB) as NSString
        timesDic[ISHA] = time.valueForKey(ISHA) as NSString
    }
    
    return timesDic

}




