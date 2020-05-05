//
//  MaintTVC+FPS.swift
//  opencvios
//
//  Created by Eugene Golovanov on 5/2/19.
//  Copyright © 2019 Eugene Golovanov. All rights reserved.
//

import UIKit

extension MaintTVC {
    
    // MARK: - FPS
    
    func initFpsButton() {
        let b = UIBarButtonItem(
            title: "FPS",
            style: .plain,
            target: self,
            action: #selector(changeFPSClicked(sender:))
        )
        self.navigationItem.rightBarButtonItem = b
    }
        
    // MARK: - Change FPS

    @objc func changeFPSClicked(sender: UIBarButtonItem) {
        showInputDialog(title: "Enter the new number below",
                        subtitle: "Here you can change number of frames per second.",
                        actionTitle: "Change",
                        cancelTitle: "Cancel",
                        inputPlaceholder: "New number",
                        inputKeyboardType: .numberPad)
        { (input:String?) in
            print("The new number is \(input ?? "")")
            if let str = input, let fpsInteger = Int(str) {
                if fpsInteger == 0 {
                    self.showAlert(title: "Should not be zero", message: "")
                } else if fpsInteger > 60 {
                    self.showAlert(title: "Too large", message: "")
                } else {
                    self.setTitle(cam: self.cam, fps: fpsInteger)
                }
            } else {
                self.showAlert(title: "Wrong Input", message: "")
            }
        }
        
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true)
    }

    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Change",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .destructive, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }


    
}
