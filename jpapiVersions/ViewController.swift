//
//  ViewController.swift
//  jpapiVersions
//
//  Created by Leslie Helou on 7/7/23.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var endpoint_PopUpButton: NSPopUpButton!
    @IBOutlet weak var version_PopUpButton: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SchemaDelegate().getSchema(serverUrl: "https://lhelou.jamfcloud.com") {
            (result: [EndpointInfo]) in
            for theEndpoint in result {
//                if theEndpoint.name == "computer-prestages" {
                    print("\(theEndpoint.name)  \(String(describing: theEndpoint.version))")
//                }
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

