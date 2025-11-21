//
//  File.swift
//  MediaAccessKit
//
//  Created by 박성영 on 11/22/25.
//

import UIKit

extension UIAlertController {
    func displayAlert(with title:String = "", msg:String, style:UIAlertController.Style = .alert, actions:[UIAlertAction]) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: style)
        actions.forEach({ alert.addAction($0) })
        
        DispatchQueue.main.async {
            if let controller = UIApplication.topViewController() {
                controller.present(alert, animated: true)
            }
        }
    }
}
