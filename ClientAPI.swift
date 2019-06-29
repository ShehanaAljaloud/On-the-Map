//
//  ClientAPI.swift
//  On The Map
//
//  Created by Shehana Aljaloud on 03/06/2019.
//  Copyright © 2019 Shehana Aljaloud. All rights reserved.
//

import Foundation
import UIKit


class ClientAPI : NSObject{
    
    var session = URLSession.shared
    
    func taskForGETMethod(urlString: String, headerFields: [String : String], client: String, _ completionHandlerForGETMethod: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let urlString = urlString
        let request = NSMutableURLRequest(url:URL(string:urlString)!)
        request.httpMethod = "GET"
        
        for (field, value) in headerFields {
            request.addValue(value, forHTTPHeaderField: field)
        }
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                
                completionHandlerForGETMethod(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            if client == "udacity" {
                let range = Range(uncheckedBounds: (5, data.count))
                let newData = data.subdata(in: range)
                
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGETMethod)
            } else {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGETMethod)
            }
        }
        
        task.resume()
        
        return task
    }
    
    func taskForPOSTMethod(urlString: String, headerFields:[String:String], jsonBody: String, completionHandlerForPOSTMethod: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let urlString = urlString
        let request = NSMutableURLRequest(url:URL(string:urlString)!)
        request.httpMethod = "POST"
        
        for (field, value) in headerFields {
            request.addValue(value, forHTTPHeaderField: field)
        }
        
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOSTMethod(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                
                if let data = data {
                    if urlString == UdacityClient.Constants.SessionURL {
                        let range = Range(uncheckedBounds: (5, data.count))
                        let newData = data.subdata(in: range)
                       
                        self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOSTMethod)
                    }
                } else {
                    sendError("Your request returned a status code other than 2xx!")
                }
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            if urlString == UdacityClient.Constants.SessionURL {
                let range = Range(uncheckedBounds: (5, data.count))
                let newData = data.subdata(in: range)
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOSTMethod)
            } else {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOSTMethod)
            }
            
        }
        
        task.resume()
        
        return task
        
    }
    
    func taskForDELETEMethod(_ request: URLRequest, completionHandlerForDELETEMethod: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDELETEMethod(nil, NSError(domain: "taskForDELETEMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let range = Range(uncheckedBounds: (5, data.count))
            let newData = data.subdata(in: range) 
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForDELETEMethod)
        }
        
        task.resume()
        
        return task
    }
    
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    func escapedParameters(_ parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                
                let stringValue = "\(value)"
                
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
                
            }
            
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
}
