//
//  UdacityClient.swift
//  On The Map
//
//  Created by Shehana Aljaloud on 09/06/2019.
//  Copyright © 2019 Shehana Aljaloud. All rights reserved.
//

import Foundation
import UIKit

class UdacityClient : ClientAPI{
    
    
    struct Constants {
        static let SessionURL = "https://onthemap-api.udacity.com/v1/session"
        static let UserURL = "https://www.udacity.com/api/users"
    }

    struct ParameterKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    struct JSONResponseKeys {
        
   
        static let User = "user"
        static let firstName = "first_name"
        static let lastName = "last_name"

        static let Account = "account"
        static let Session = "session"
        static let AccountKey = "key"
        static let Expiration = "expiration"
    }
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
    
    func authenticateUser(username: String, password: String, _ completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        /* Build the URL */
        let urlString = Constants.SessionURL
        let headerFields = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
       
        let _ = taskForPOSTMethod(urlString: urlString, headerFields: headerFields, jsonBody: jsonBody) { (results, error) in
            
            if let error = error {
                
                completionHandlerForAuth(false, error.localizedDescription)
            } else {
                if let account = results?[JSONResponseKeys.Account] as? NSDictionary {
                    if let accountKey = account[JSONResponseKeys.AccountKey] as? String{
                      Storage.uniqueKey = accountKey
                        completionHandlerForAuth(true, nil)
                    }
                    
                } else {
                    print("Could not find \(JSONResponseKeys.AccountKey) in \(String(describing: results))")
                    completionHandlerForAuth(false, "Invalid Credentials")
                    
                }
            }
        }
    }
    
    func getUserData(_ completionHandlerForUserData: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let urlString = Constants.UserURL + "/\(Storage.uniqueKey)"
        let headerFields = [String:String]()
        
        let _ = taskForGETMethod(urlString: urlString, headerFields: headerFields, client: "udacity") { (results, error) in
            
            if let error = error {
                print(error.localizedDescription)
                completionHandlerForUserData(false, "There was an error getting user data.")
            } else {
                if let user = results?[JSONResponseKeys.User] as? NSDictionary {
                    if let userFirstName = user[JSONResponseKeys.firstName] as? String, let userLastName = user[JSONResponseKeys.lastName] as? String {
                        Storage.firstName = userFirstName
                        Storage.lastName = userLastName
                        completionHandlerForUserData(true, nil)
                    }
                } else {
                    print("Could not find \(JSONResponseKeys.User) in \(String(describing: results))")
                    completionHandlerForUserData(false,"Could not get the user data.")
                }
            }
        }
    }
    
    func logoutUser(_ completionHandlerForLogoutUser: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let urlString = Constants.SessionURL
        let request = NSMutableURLRequest(url:URL(string:urlString)!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let _ = taskForDELETEMethod(request as URLRequest) { (results, error) in
            
            if let error = error {
                print(error.localizedDescription)
                completionHandlerForLogoutUser(false, "There was an error with logout.")
            } else {
                if let session = results?[JSONResponseKeys.Session] as? NSDictionary {
                    if let expiration = session[JSONResponseKeys.Expiration] as? String{
                        print("logged out: \(expiration)")
                        completionHandlerForLogoutUser(true, nil)
                    }
                    
                } else {
                    print("Could not find \(JSONResponseKeys.Session) in \(String(describing: results))")
                    completionHandlerForLogoutUser(false, "Could not logout.")
                }
            }
        }
    }
    
    
}
