//
//  ImagePreviewViewController.swift
//  Example
//
//  Created by 박성영 on 11/23/25.
//

import UIKit

class ImagePreviewViewController: UIViewController {
    
    private let imageView = UIImageView()

    init(image: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.frame = UIScreen.main.bounds
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(imageView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        view.addGestureRecognizer(tap)
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}
