//
//  MaintTVC.swift
//  opencvios
//
//  Created by Eugene Golovanov on 4/29/19.
//  Copyright © 2019 Eugene Golovanov. All rights reserved.
//

import UIKit

class MaintTVC: UITableViewController {
    
    
    var fps:Int = 15 // Default FPS
    var cam: Cam = .front
    
    struct Segment {
        var title: String
        var processTypes = [String]()
    }
    var sect = [Segment]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initFpsButton()
        self.initCamButton()
        self.setTitle(cam: self.cam, fps: self.fps)
        self.sect.append(Segment(title: "Face Detection", processTypes: ["MTCNN",
                                                                         "DNN",
                                                                         "Haar"
                                                                             ]))
        self.sect.append(Segment(title: "Filters", processTypes: ["Canny",
                                                                  "Threshold"
                                                                      ]))
    }
    
    func setTitle(cam:Cam, fps:Int) {
        self.fps = fps
        self.cam = cam
        self.title = "CAMERA: \(cam.rawValue),  FPS: \(self.fps)"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sect.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sect[section].title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sect[section].processTypes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = self.sect[indexPath.section].processTypes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "image_process_vc") as? ProcessVC else {
            print("🚫 Could not present view controller")
            return
        }
        
        if indexPath.section == 0 {
            switch indexPath.row {
                case 0:
                    print("MTCNN Selected")
                    vc.openCVWrapper = OpenCVWrapper(type: ImageProcessType.MTCNN)
                    break
                case 1:
                    print("DNN Selected")
                    vc.openCVWrapper = OpenCVWrapper(type: ImageProcessType.DNN)
                    break
                case 2:
                    print("Haar Selected")
                    vc.openCVWrapper = OpenCVWrapper(type: ImageProcessType.haar)
                    break
                default:
                    print("Nothing Selected")
                    break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                print("Canny Selected")
                vc.openCVWrapper = OpenCVWrapper(type: ImageProcessType.canny)
                break
            case 1:
                print("Threshold Selected")
                vc.openCVWrapper = OpenCVWrapper(type: ImageProcessType.threshold)
                break
            default:
                print("Nothing Selected")
                break
            }
        }
        if vc.openCVWrapper != nil {
            vc.frameExtractor = FrameExtractor(cam: self.cam, fps: self.fps)
            vc.frameExtractor?.delegate = vc
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
