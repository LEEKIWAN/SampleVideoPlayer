//
//  VideoUtil.swift
//
//
//  Created by kiwan on 2020/08/27.
//  Copyright © 2020 kiwan. All rights reserved.
//

import Foundation

class VideoUtil {
    
    static func fileSizeToString(fileSize: Int64) -> String {
        var size = Float(fileSize) / (1024 * 1024)
        if size > 1000 {
            size = size / 1024
            
            return String(format: "%.2f GB", size)
        }
        else  {
            return String(format: "%.2f MB", size)
        }
        
    }
    
    static func integerToDate(int: Int32) -> Date {
        let addedInterval = Double(int)
        let addedTime = Date(timeIntervalSince1970: addedInterval)
        return addedTime
    }
    
    
    static func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.M.dd"
        
        return dateFormatter.string(from: date)
    }
    
    static func expireDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.M.dd H:mm"
        
        return dateFormatter.string(from: date)
    }
    
    
    static func durationToHoursMinutesSeconds(duration: TimeInterval) -> (Int?, Int?, Int?) {
        let hrs = duration / 3600
        let mins = (duration.truncatingRemainder(dividingBy: 3600)) / 60
        let seconds = (duration.truncatingRemainder(dividingBy:3600)).truncatingRemainder(dividingBy:60)
        return (Int(hrs) > 0 ? Int(hrs) : nil , Int(mins) > 0 ? Int(mins) : nil, Int(seconds) > 0 ? Int(seconds) : nil)
    }
    
    static func durationToString(duration: TimeInterval) -> String {
        let time = durationToHoursMinutesSeconds(duration: duration)
        switch time {
        case (nil, let x? , let y?):
            let secondText = y < 10 ? "0\(y)" : "\(y)"
            return "\(x):\(secondText)"
        case (nil, let x?, nil):
            return "\(x):00"
        case (let x?, nil, nil):
            return "\(x):00:00"
        case (nil, nil, let x?):
            let secondText = x < 10 ? "0\(x)" : "\(x)"
            return "0:\(secondText)"
        case (let x?, nil, let z?):
            let secondText = z < 10 ? "0\(z)" : "\(z)"
            return "\(x):00:\(secondText)"
        case (let x?, let y?, nil):
            let minuteText = y < 10 ? "0\(y)" : "\(y)"
            return "\(x):\(minuteText):00"
        case (let x?, let y?, let z?):
            let minuteText = y < 10 ? "0\(y)" : "\(y)"
            let secondText = z < 10 ? "0\(z)" : "\(z)"
            return "\(x):\(minuteText):\(secondText)"
        default:
            return "0:00"
        }
    }
    
    static func durationToDate(duration: Int) -> String {
        let day = duration / (3600 * 24);
        let remain = duration % (3600 * 24);
        let hour = remain / 3600;
        let minute = remain % 3600 / 60;
//        let second = remain % 60;
        
        var string = ""
        
        if day > 0 {
            string = "\(day)" + "Day"
        }

        if hour > 0 {
            string = "\(string) \(hour)" + "Hour"
        }

        if minute > 0 {
            string = " \(string) \(minute)" + "Minute"
        }

//        if second > 0 {
//            string = " \(string) \(second)초"
//        }
        
        return string
    }
}

