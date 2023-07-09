//
//  ViewController.swift
//  jpapiVersions
//
//  Created by Leslie Helou on 7/7/23.
//

import AppKit
import Cocoa

class ViewController: NSViewController {
    
    
    @IBOutlet weak var spinner_ProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var endpoint_PopUpButton: NSPopUpButton!
    @IBOutlet weak var version_PopUpButton: NSPopUpButton!
    
    @IBOutlet weak var serverUrl_TextField: NSTextField!
    @IBOutlet weak var endpointPath_TextField: NSTextField!
    @IBOutlet var privileges_TextView: NSTextView!
    
    @IBOutlet weak var privileges_ScrollView: NSScrollView!
    
    
    @IBOutlet weak var developerPortalMethod_PopUpButton: NSPopUpButton!
    @IBOutlet weak var Lookup_Button: NSButton!
    
    var endpointInfo    = [EndpointInfo]()
    var portalLinksDict = [String:String]()
    
    @IBAction func selectEndpoint_Action(_ sender: NSPopUpButton) {
        print("selected item: \(String(describing: endpoint_PopUpButton.titleOfSelectedItem!))")
        let whichEndpoint = "\(endpoint_PopUpButton.titleOfSelectedItem ?? "")"
        setVersionButton(whichEndpoint: whichEndpoint)
    }
    @IBAction func selectVersion_Action(_ sender: Any) {
        setPath()
    }
    
    
    @IBAction func Lookup_Action(_ sender: Any) {
        if serverUrl_TextField.stringValue != "" {
            spinner_ProgressIndicator.startAnimation(self)
            SchemaDelegate().getSchema(serverUrl: serverUrl_TextField.stringValue) { [self]
                (result: [EndpointInfo]) in
                endpointInfo = result
                if endpointInfo.isEmpty {
                    print("nothing found")
                    spinner_ProgressIndicator.stopAnimation(self)
                    return
                }
                endpoint_PopUpButton.removeAllItems()
                for theEndpoint in endpointInfo {
                    endpoint_PopUpButton.addItem(withTitle: theEndpoint.name)
                    print("\(theEndpoint.name)")
                    for versionDetails in theEndpoint.versionInfo {
                        print("    \(String(describing: versionDetails.version))    details: \(versionDetails.details)\n")
                    }
                }
                setVersionButton(whichEndpoint: "\(endpoint_PopUpButton.itemTitle(at: 0))")
                spinner_ProgressIndicator.stopAnimation(self)
            }
        }
    }
    
    @IBAction func openDeveloperPortal(_ sender: NSPopUpButton) {
        guard let portalLink = URL(string: portalLinksDict[sender.titleOfSelectedItem!]!) else {
            print("URL error for portal: \(portalLinksDict[sender.titleOfSelectedItem!]!)")
            return
        }
        NSWorkspace.shared.open(portalLink)
    }
    
    
    func setVersionButton(whichEndpoint: String) {
        print("[setVersionButton] endpoint: \(whichEndpoint)")
        version_PopUpButton.removeAllItems()
        if let indexOfEndpoint = endpointInfo.firstIndex(where: { $0.name == whichEndpoint }) {
            let endpoingDetailsArray = endpointInfo[indexOfEndpoint].versionInfo
            var versionsArray = [String]()
            for theVersion in endpoingDetailsArray {
                if theVersion.version != "v0" {
                    versionsArray.append(theVersion.version)
                } else {
                    versionsArray.append("-")
                }
            }
            let sortedVersioArray = versionsArray.sorted()
            if sortedVersioArray.last != "-" {
                version_PopUpButton.isEnabled = true
            } else {
                version_PopUpButton.isEnabled = false
            }
            version_PopUpButton.addItems(withTitles: sortedVersioArray)
            version_PopUpButton.selectItem(at: 0)
            print("[setVersionButton] title of selected version: \(String(describing: version_PopUpButton.titleOfSelectedItem))")
            setPath()
        }
    }
    
    func setPath() {
        print("[setPath]")
        var endPointPathString = "\(serverUrl_TextField.stringValue)/api/\(String(describing: version_PopUpButton.titleOfSelectedItem!))/\(String(describing: endpoint_PopUpButton.titleOfSelectedItem!))"
        endPointPathString = endPointPathString.replacingOccurrences(of: "//api", with: "/api")
        endPointPathString = endPointPathString.replacingOccurrences(of: "/-", with: "")
        endpointPath_TextField.stringValue = endPointPathString
        listPrivileges()
    }
    
    func listPrivileges() {
        let paragraphStyle       = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: NSColor.controlTextColor, NSAttributedString.Key.font: NSFont(name: "Helvetica Neue", size: 16)!, NSAttributedString.Key.paragraphStyle: paragraphStyle] as [NSAttributedString.Key : Any]
        
        
        print("[listPrivileges] endpoint: \(endpoint_PopUpButton.titleOfSelectedItem!)")
        var privilegesString = ""
        if let indexOfEndpoint = endpointInfo.firstIndex(where: { $0.name == endpoint_PopUpButton.titleOfSelectedItem! }) {
            print("[listPrivileges] endpoint index: \(indexOfEndpoint)")
            let endpointDetailsArray = endpointInfo[indexOfEndpoint].versionInfo
            let whichversion = ( version_PopUpButton.titleOfSelectedItem! == "-" ) ? "v0":version_PopUpButton.titleOfSelectedItem!
            if let theVersionIndex = endpointDetailsArray.firstIndex(where: { $0.version == whichversion }) {
                print("[listPrivileges] endpoint version: \(theVersionIndex)")
                let versionDetails = endpointDetailsArray[theVersionIndex].details
                var methodArray = [String]()
                for (theMethod, _) in versionDetails {
                    methodArray.append(theMethod)
                }
                methodArray = methodArray.sorted()
                for theMethod in methodArray {
                    let theDetailsDict = (versionDetails[theMethod] ?? [:]) as [String:String]
                    
                    let isdeprecated = ( theDetailsDict["deprecated"] == "true" ) ? "(deprecated)":""
                    privilegesString = privilegesString.appending("\(theMethod) \(isdeprecated)\n")
                    
                    if let privilegesArray = theDetailsDict["privileges"]?.components(separatedBy: ", ") {
                        for thePrivilege in privilegesArray {
                            privilegesString = privilegesString.appending("    " + thePrivilege + "\n")
                        }
                    }
                    privilegesString = privilegesString.appending("\n")
                }
//                privileges_TextView.string = "\(privilegesString)"
                let attributedPrivilegeString = NSMutableAttributedString(string: privilegesString, attributes: textAttributes)
                privileges_TextView.textStorage?.setAttributedString(attributedPrivilegeString)

                generatePortalLink(methods: methodArray)
            }
        }
    }
    
    func generatePortalLink(methods: [String]) {
        portalLinksDict.removeAll()
        developerPortalMethod_PopUpButton.removeAllItems()
//        for method in methods.sorted() {
//            developerPortalMethod_PopUpButton.addItem(withTitle: " "+method+" ")
//        }
        
        var whichEndpoint = endpoint_PopUpButton.titleOfSelectedItem!.replacingOccurrences(of: "/", with: "-")
        whichEndpoint = whichEndpoint.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "")
        let whichVersion  = version_PopUpButton.titleOfSelectedItem!
        let theLinkBase   = "https://developer.jamf.com/jamf-pro/reference"
        var theLink       = ""
        
        print("whichVersion: \(whichVersion)")
        
        for theMethod in methods.sorted() {
            developerPortalMethod_PopUpButton.addItem(withTitle: " "+theMethod+" ")
            switch whichVersion {
            case "-":
                theLink = "\(theLinkBase)/\(theMethod)_\(String(describing: whichEndpoint))"
            default:
                theLink = "\(theLinkBase)/\(theMethod)_\(String(describing: whichVersion))-\(String(describing: whichEndpoint))"
            }
            portalLinksDict[" "+theMethod+" "] = theLink
        }
        print("link dict: \(portalLinksDict)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

