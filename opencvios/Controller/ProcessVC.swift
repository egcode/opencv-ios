//
//  ViewController.swift
//  opencvios
//
//  Created by Eugene Golovanov on 4/27/19.
//  Copyright © 2019 Eugene Golovanov. All rights reserved.
//

import UIKit

class ProcessVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    public var frameExtractor: FrameExtractor?
    public var openCVWrapper:OpenCVWrapper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let fe = self.frameExtractor {
            fe.stopSession()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("Failed Function: \(#function)")
    }
    
}

extension ProcessVC: FrameExtractorDelegate {
    func captured(image: UIImage) {
        
        //OpenCV
        if let wrapper = self.openCVWrapper {
            self.imageView.image = wrapper.processImage(withType: image)
        } else {
            print("\n⛔️⛔️⛔️ NO WRAPPER\n")
        }
    }
}
