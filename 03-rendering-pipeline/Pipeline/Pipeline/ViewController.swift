//
//  ViewController.swift
//  Pipeline
//
//  Created by zyyk on 2019/12/10.
//  Copyright © 2019 zyyk. All rights reserved.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    
    var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let metalView = view as? MTKView else {
            fatalError("metal view not set up in storyboard");
        }
        renderer = Renderer(metalView: metalView)
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

