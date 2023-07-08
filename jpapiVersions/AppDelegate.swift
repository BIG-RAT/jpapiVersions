//
//  AppDelegate.swift
//  jpapiVersions
//
//  Created by Leslie Helou on 7/7/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    // quit the app if the window is closed
    func applicationShouldTerminateAfterLastWindowClosed(_ app: NSApplication) -> Bool {
        NSApplication.shared.terminate(self)
        return false
    }

}

