//
//  TerminalCallback.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/31/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import Foundation

public class TerminalCallback : RestCallBack {
    
    public var terminals: Dictionary<String,Int>?
    public var error: NSError?
    public var timeStamp: Int?
    
    private let callBack: ()->Void
    
    public init( callBack: () -> Void ) {
        self.callBack = callBack
    }
    
    public func jsonCallBack(url: NSURL, timestamp: Int, json:AnyObject?) {
        terminals = RouteFetcher.getTerminal(json!)
        timeStamp = timestamp;
        error = nil
        callBack()
    }
    
    public func textCallBack(url: NSURL, text: String) {
        println("Unexpected value on TerminalCallback.textCallBack... Generating Error!")
        var error = NSError(
            domain: AppDelegate.Constants.Application.ErrorCode.Domain,
            code: AppDelegate.Constants.Application.ErrorCode.Values.UnexpectedResponse,
            userInfo: nil)
        errorCallBack(url, error: error)
    }
    
    public func errorCallBack(url: NSURL, error: NSError) {
        self.error = error
        callBack()
    }
    
    public func externalErrorCallBack(url: NSURL, error: NSError) {
        self.error = error
        callBack()
    }
}