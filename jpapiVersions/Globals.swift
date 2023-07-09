//
//  Globals.swift
//  jpapiVersions
//
//  Created by Leslie Helou on 12/22/19.
//  Copyright © 2019 Leslie Helou. All rights reserved.
//

import Foundation

struct AppInfo {
    static let dict    = Bundle.main.infoDictionary!
    static let version = dict["CFBundleShortVersionString"] as! String
    static let name    = dict["CFBundleExecutable"] as! String

    static let userAgentHeader = "\(String(describing: name.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!))/\(AppInfo.version)"
}

struct EndpointInfo: Codable {
    var name: String
    var versionInfo: [VersionInfo]    // [version: [method: [method_details]]]
}

struct VersionInfo: Codable {
    var version: String
    var details: [String:[String:String]]    // [method: [method_details]]
}
