//
//  RestCall.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/28/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public protocol RestCallBack  {    
    func jsonCallBack(url: NSURL, timestamp: Int, json:AnyObject?);
    func textCallBack(url: NSURL, text: String);
    func errorCallBack(url: NSURL, error: NSError);
    func externalErrorCallBack(url: NSURL, error: NSError);
}

public class RestCall {
    
    private let timeoutInMSeconds : Int64
    
    init( timeoutInMSeconds: Double) {
        self.timeoutInMSeconds = Int64(timeoutInMSeconds*Double(NSEC_PER_MSEC))
    }
    
    
    func executeGet(urlPath: String, callBack: RestCallBack) ->  NSURLSessionDataTask {
            
        var url = NSURL(string: urlPath)!
        var request = NSURLRequest(URL: url)
        var session = NSURLSession.sharedSession()
        var done = false
        
        var task = session.dataTaskWithURL(url, completionHandler:
            { (data, resp, error) -> Void in
                
                // Can be improved... part of this work could be done in the current thread
                dispatch_async(dispatch_get_main_queue()) {
                    
                    done = true
                    
                    if let theError = error {
                        callBack.errorCallBack( url, error: theError )
                    } else {
                        if let response = resp as? NSHTTPURLResponse {
                            if response.statusCode == 200 {
                                if response.MIMEType! == "text/plain" {
                                    var s = NSString(data: data!, encoding: 0)
                                    callBack.textCallBack( url, text: String(s!) );
                                } else {
                                    var jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(
                                        data!,
                                        options: NSJSONReadingOptions.MutableContainers,
                                        error: nil) as AnyObject?
                                    
                                    if let json = jsonResult as? Dictionary<String,AnyObject>{
                                        var timeStamp = json["timeStamp"] as? Int!
                                        var data: AnyObject? = json["data"]
                                        callBack.jsonCallBack( url, timestamp: timeStamp!, json: data );
                                    } else {
                                        var error = NSError(
                                            domain: AppDelegate.Constants.Application.ErrorCode.Domain,
                                            code: AppDelegate.Constants.Application.ErrorCode.Values.ReceivedInvalidJSON,
                                            userInfo: nil)
                                        callBack.errorCallBack(url, error: error)
                                    }
                                }
                            } else {
                                var s = NSString(data: data!, encoding: 0)
                                var error = NSError(
                                    domain: AppDelegate.Constants.Network.ErrorCode.Domain,
                                    code: response.statusCode,
                                    userInfo: ["ErrorMessage" : String(s!)])
                                callBack.externalErrorCallBack( url, error: error )
                            }
                        }
                    }
                }
                
        })
        
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, timeoutInMSeconds)
        dispatch_after(dispatchTime, dispatch_get_main_queue()) {
            if !done && task.state == NSURLSessionTaskState.Running {
                task.cancel()
                var error = NSError(
                    domain: AppDelegate.Constants.Application.ErrorCode.Domain,
                    code: AppDelegate.Constants.Application.ErrorCode.Values.Timeout,
                    userInfo: nil)
                callBack.errorCallBack( url, error: error )
            }
        }
        task.resume()
        return task
    }
    
    func executePost( let urlPath: String, stringPost: String, callBack : RestCallBack ) ->  NSURLSessionDataTask {
        let url = NSURL(string: urlPath)!
        var session = NSURLSession.sharedSession()
        var request = NSMutableURLRequest(URL: url)
        request.timeoutInterval = 60
        request.HTTPMethod = "POST"
        request.HTTPBody = stringPost.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPShouldHandleCookies = false
        var done = false
        
        var task = session.dataTaskWithRequest(request, completionHandler:
            { (data, resp, error) -> Void in
                
                // Can be improved... part of this work could be done in the current thread
                dispatch_async(dispatch_get_main_queue()) {
                    
                    done = true
                    
                    if let theError = error {
                        callBack.errorCallBack( url, error:theError )
                    } else {
                        if let response = resp as? NSHTTPURLResponse {
                            if response.statusCode == 200 {
                                if response.MIMEType! == "text/plain" {
                                    var s = NSString( data: data!, encoding:0)
                                    callBack.textCallBack(url, text: String(s!))
                                } else {
                                    var jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(
                                        data!,
                                        options: NSJSONReadingOptions.MutableContainers,
                                        error: nil) as AnyObject?
                                    
                                    if let json = jsonResult as? Dictionary<String,AnyObject>{
                                        var timeStamp = json["timeStamp"] as? Int!
                                        var data: AnyObject? = json["data"]
                                        callBack.jsonCallBack( url, timestamp: timeStamp!, json: data );
                                    } else {
                                        var error = NSError(
                                            domain: AppDelegate.Constants.Application.ErrorCode.Domain,
                                            code: AppDelegate.Constants.Application.ErrorCode.Values.ReceivedInvalidJSON,
                                            userInfo: nil)
                                        callBack.errorCallBack(url, error: error)
                                    }
                                }
                            } else {
                                var s = NSString(data: data!, encoding: 0)
                                var error = NSError(
                                    domain: AppDelegate.Constants.Network.ErrorCode.Domain,
                                    code: response.statusCode,
                                    userInfo: ["ErrorMessage" : String(s!)])
                                callBack.externalErrorCallBack( url, error: error )
                            }
                        }
                    }
                }
        })
        
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, timeoutInMSeconds)
        dispatch_after(dispatchTime, dispatch_get_main_queue()) {
            if !done && task.state == NSURLSessionTaskState.Running {
                task.cancel()
                var error = NSError(
                    domain: AppDelegate.Constants.Application.ErrorCode.Domain,
                    code: AppDelegate.Constants.Application.ErrorCode.Values.Timeout,
                    userInfo: nil)
                callBack.errorCallBack( url, error: error )
            }
        }

        task.resume()
        return task
    }

    func executePost( let urlPath: String, json: NSData, callBack : RestCallBack ) ->  NSURLSessionDataTask {
        let url = NSURL(string: urlPath)!
        var session = NSURLSession.sharedSession()
        var request = NSMutableURLRequest(URL: url)
        request.timeoutInterval = 60
        request.HTTPMethod = "POST"
        request.HTTPBody = json
        request.HTTPShouldHandleCookies = false
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var done = false

        var task = session.dataTaskWithRequest(request, completionHandler:
            { (data, resp, error) -> Void in
                
                // Can be improved... part of this work could be done in the current thread
                dispatch_async(dispatch_get_main_queue()) {
                    
                    done = true
                    
                    if let theError = error {
                        callBack.errorCallBack( url, error:theError )
                    } else {
                        if let response = resp as? NSHTTPURLResponse {
                            if response.statusCode == 200 {
                                if response.MIMEType! == "text/plain" {
                                    var s = NSString( data: data!, encoding:0)
                                    callBack.textCallBack(url, text: String(s!))
                                } else {
                                    var jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(
                                        data!,
                                        options: NSJSONReadingOptions.MutableContainers,
                                        error: nil) as AnyObject?
                                    
                                    if let json = jsonResult as? Dictionary<String,AnyObject>{
                                        var timeStamp = json["timeStamp"] as? Int!
                                        var data: AnyObject? = json["data"]
                                        callBack.jsonCallBack( url, timestamp: timeStamp!, json: data );
                                    } else {
                                        var error = NSError(
                                            domain: AppDelegate.Constants.Application.ErrorCode.Domain,
                                            code: AppDelegate.Constants.Application.ErrorCode.Values.ReceivedInvalidJSON,
                                            userInfo: nil)
                                        callBack.errorCallBack(url, error: error)
                                    }
                                }
                            } else {
                                var s = NSString(data: data!, encoding: 0)
                                var error = NSError(
                                    domain: AppDelegate.Constants.Network.ErrorCode.Domain,
                                    code: response.statusCode,
                                    userInfo: ["ErrorMessage" : String(s!)])
                                callBack.externalErrorCallBack( url, error: error )
                            }
                        }
                    }
                }
        })
        
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, timeoutInMSeconds)
        dispatch_after(dispatchTime, dispatch_get_main_queue()) {
            if !done && task.state == NSURLSessionTaskState.Running {
                task.cancel()
                var error = NSError(
                    domain: AppDelegate.Constants.Application.ErrorCode.Domain,
                    code: AppDelegate.Constants.Application.ErrorCode.Values.Timeout,
                    userInfo: nil)
                callBack.errorCallBack( url, error: error )
            }
        }

        task.resume()
        return task
    }
    

}