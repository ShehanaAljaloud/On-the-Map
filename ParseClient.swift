//
//  ParseClient.swift
//  On The Map
//
//  Created by Shehana Aljaloud on 06/06/2019.
//  Copyright © 2019 Shehana Aljaloud. All rights reserved.
//
import UIKit
import Foundation

class ParseClient: ClientAPI {
    
    
    let parseAppID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    let apiKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    
    struct Constants {
        static let StudentLocationURL = "https://onthemap-api.udacity.com/v1/StudentLocation"
    }
    
    struct ParameterKeys {
        static let Where = "where"
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
    }
    
    struct JSONResponseKeys {
        static let Results = "results"
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
    
    func getStudentLocation(_ completionHandlerForGETStudentLocation: @escaping (_ result: [ParseStudent]?, _ error: NSError?) -> Void) {
        
       
        let methodParameters = [
            ParameterKeys.Limit : 100,
            ParameterKeys.Order : "-updatedAt"
            ] as [String : Any]
        
        
        let urlString = Constants.StudentLocationURL + escapedParameters(methodParameters as [String:AnyObject])
        let headerFields = [
            "X-Parse-Application-Id": parseAppID,
            "X-Parse-REST-API-Key": apiKey
        ]
        
        let _ = taskForGETMethod(urlString:urlString, headerFields:headerFields, client:"parse") { (results, error) in
            
            
            if let error = error {
                completionHandlerForGETStudentLocation(nil, error)
            } else {
                if let results = results?[JSONResponseKeys.Results] as? [[String:AnyObject]] {
               
                    let studentInfo = ParseStudent.studentsFromResults(results)
                    completionHandlerForGETStudentLocation(studentInfo, nil)
                } else {
                    completionHandlerForGETStudentLocation(nil, NSError(domain: "getStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocation"]))
                }
            }
        }
    }
    
    
    func postStudentLocation(_ completionHandlerForPostStudentLocation: @escaping (_ result: String?, _ error: NSError?) -> Void) {
      
        let urlString = Constants.StudentLocationURL
        let headerFields = [
            "X-Parse-Application-Id": parseAppID,
            "X-Parse-REST-API-Key": apiKey,
            "Content-Type": "application/json"
        ]
        
        
        let jsonBody = "{\"uniqueKey\": \"\(Storage.uniqueKey)\", \"firstName\": \"\(Storage.firstName)\", \"lastName\": \"\(Storage.lastName)\",\"mapString\": \"\(Storage.mapString)\", \"mediaURL\": \"\(Storage.mediaURL)\",\"latitude\":\(Storage.latitude), \"longitude\": \(Storage.longitude)}"
        print(jsonBody)
        
       
        let _ = taskForPOSTMethod(urlString: urlString, headerFields: headerFields, jsonBody: jsonBody) { (results, error) in
            
            if let error = error {
                completionHandlerForPostStudentLocation(nil, error)
            } else {
                if let objectId = results?[JSONResponseKeys.ObjectId] as? String {
                    completionHandlerForPostStudentLocation(objectId, nil)
                } else {
                    completionHandlerForPostStudentLocation(nil, NSError(domain: "postNewStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postStudentLocation"]))
                }
            }
        }
    }
}
