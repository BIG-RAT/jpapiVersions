//
//  Alert.swift
//  jpapiVersions
//
//  Created by Leslie Helou on 7/7/23.
//

import Cocoa

class Alert: NSObject {
    func display(type: String = "default", header: String, message: String, secondButton: String) -> String {
        var selected = ""
//        var remotePassword = ""
        let remotePassword_TextField = NSSecureTextField(frame: NSRect(x: 0, y: 24, width: 250, height: 24))
        let passViewer = NSStackView(frame: NSRect(x: 0, y: 0, width: 250, height: 50))
        passViewer.addSubview(remotePassword_TextField)
        
        let dialog: NSAlert = NSAlert()
        dialog.messageText = header
        dialog.informativeText = message
        dialog.alertStyle = NSAlert.Style.warning
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        if type == "password" {
            dialog.accessoryView = passViewer
            dialog.window.initialFirstResponder = remotePassword_TextField
        }
        
        
        let okButton = dialog.addButton(withTitle: "OK")
        if secondButton != "" {
            let otherButton = dialog.addButton(withTitle: secondButton)
//            otherButton.keyEquivalent = "c"
            okButton.keyEquivalent = "\r"
        }
        
        let theButton = dialog.runModal()
        switch theButton {
        case .alertFirstButtonReturn:
//            selected = "OK"
            selected = "\(remotePassword_TextField.stringValue)"
//            print("remotePassword: \(remotePassword_TextField.stringValue)")
        default:
            selected = secondButton
//            selected = ""
        }
        if selected == "Quit" { NSApplication.shared.terminate(self) }
        return selected
    }   // func alert_dialog - end
}
