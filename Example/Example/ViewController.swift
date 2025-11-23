//
//  ViewController.swift
//  Example
//
//  Created by 박성영 on 11/22/25.
//

import UIKit
import MediaAccessKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let button = UIButton(type: .system)
        button.setTitle("MediaAccess", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // 버튼에 동작 연결
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        view.addSubview(button)
        
        // 버튼 위치 설정 (AutoLayout)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 120),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
        
    }

    @objc func buttonTapped() {
        MediaAccessManager.shared.presentMediaOptions(from: self, alertMessage: "파일 첨부") { [weak self] alert in
            alert.addAction(UIAlertAction(title: "첨부 안함", style: .default) { _ in
                
            })
        } completion: { [weak self] item in
            print("외부 completion ---", item.count)
            
            DispatchQueue.main.async {
                let galleryVC = MediaGalleryViewController(mediaItems: item)
                self?.navigationController?.pushViewController(galleryVC, animated: true)
            }
          
        }
    }
    
}

