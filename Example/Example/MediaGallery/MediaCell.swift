//
//  MediaCell.swift
//  Example
//
//  Created by 박성영 on 11/23/25.
//

import UIKit

class MediaCell: UICollectionViewCell {
    static let identifier = "MediaCell"

    private let thumbnailView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private let videoIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "play.circle.fill")
        iv.tintColor = .white
        iv.isHidden = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(thumbnailView)
        contentView.addSubview(videoIcon)

        thumbnailView.frame = contentView.bounds
        videoIcon.frame = CGRect(x: contentView.bounds.width - 34,
                                 y: contentView.bounds.height - 34,
                                 width: 30, height: 30)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(image: UIImage?, isVideo: Bool) {
        thumbnailView.image = image
        videoIcon.isHidden = !isVideo   // 동영상이면 아이콘 표시
    }
}
