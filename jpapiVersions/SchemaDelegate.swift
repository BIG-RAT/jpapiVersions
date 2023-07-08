//
//  SchemaDelegate.swift
//  jpapiVersions
//
//  Created by Leslie Helou on 07/08/24
//  Copyright © 2023 Leslie Helou. All rights reserved.
//

import Foundation



class SchemaDelegate: NSObject, URLSessionDelegate {
    
    var theUapiQ = OperationQueue() // create operation queue for API calls
    
    func getSchema(serverUrl: String, completion: @escaping (_ returnedToken: [EndpointInfo]) -> Void) {
        
        var arrayOfPaths = [String]()
        var methods      = [String:Any]()
        
        var endpointsArray = [EndpointInfo]()
        var currentEndpoint: EndpointInfo?
        
        
//        print("\(serverUrl.prefix(4))")
        if serverUrl.prefix(4) != "http" {
            completion([])
            return
        }
        URLCache.shared.removeAllCachedResponses()
                
        var schemaUrlString = "\(serverUrl)/api/schema/"
        schemaUrlString     = schemaUrlString.replacingOccurrences(of: "//api", with: "/api")
    //        print("\(tokenUrlString)")
        
        let schemaUrl       = URL(string: "\(schemaUrlString)")
        let configuration  = URLSessionConfiguration.ephemeral
        var request        = URLRequest(url: schemaUrl!)
        request.httpMethod = "GET"
        
        print("[SchemaDelegate.getSchema] Attempting to retrieve schema from \(String(describing: schemaUrl!)).")
        
        configuration.httpAdditionalHeaders = ["Content-Type" : "application/json", "Accept" : "application/json", "User-Agent" : AppInfo.userAgentHeader]
        let session = Foundation.URLSession(configuration: configuration, delegate: self as URLSessionDelegate, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            session.finishTasksAndInvalidate()
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    if let fullSchema = json! as? [String: Any] {
                        if let pathInfo = fullSchema["paths"] as? [String:Any] {
                            for (thePath, _) in pathInfo {
                                let tmp = "\(thePath.dropFirst())"
                                let objectInfoArray = tmp.components(separatedBy: "/")
                                let theVersion = ( objectInfoArray[0].prefix(1) == "v" ) ? "\(objectInfoArray[0].dropFirst())":"0"
                                let theEndpointPath = ( theVersion == "0" ) ? "\(tmp)":"\(tmp.dropFirst(objectInfoArray[0].count+1))"
                                methods = pathInfo["\(thePath)"] as! [String : Any]
                                
                                
                                var methodDetails = [String:[String:[String:String]]]()
//                                if theEndpointPath == "computer-prestages" {
//                                    currentEndpoint.name = theEndpointPath
                                    for (method, details) in methods {
                                        let currentMethodDetails = details as! [String:Any]
                                        let deprecated = ( currentMethodDetails["deprecated"] == nil ) ? false:true
                                        let deprecatedDate = ( deprecated ) ? currentMethodDetails["x-deprecation-date"] as! String:""
                                        let privileges = currentMethodDetails["x-required-privileges"] as? [String] ?? []
                                        // convert array to a string
                                        var requiredPrivileges = ""
                                        if privileges.count > 0 {
                                            for i in 0..<privileges.count-1 {
                                                requiredPrivileges.append(privileges[i])
                                            }
                                            requiredPrivileges.append(privileges[privileges.count-1])
                                        }
                                        
                                        methodDetails["v\(theVersion)"] = ["\(method)":["privileges":"\(requiredPrivileges)", "deprecated": "\(deprecated)", "deprecatedDate":deprecatedDate]]
                                        
                                    }
                                    currentEndpoint = EndpointInfo(name: theEndpointPath, version: methodDetails)
                                    endpointsArray.append(currentEndpoint!)
//                                }
                                
//                                arrayOfPaths.append(theEndpointPath)
                            }
//                            arrayOfPaths = arrayOfPaths.sorted()
                            
                        }
                        
                    } else {    // if let endpointJSON error
                        print("[SchemaDelegate.getSchema] JSON error.\n\(String(describing: json))")
                        completion([])
                        return
                    }
                    endpointsArray = endpointsArray.sorted(by: { $0.name < $1.name })
                    completion(endpointsArray)
                } else {    // if httpResponse.statusCode <200 or >299
                    print("[SchemaDelegate.getSchema] response error: \(httpResponse.statusCode).")
                    completion([])
                    return
                }
            } else {
                print("[SchemaDelegate.getSchema] token response error.  Verify url and port.")
                completion([])
                return
            }
        })
        task.resume()
    }
}
