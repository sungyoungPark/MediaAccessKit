//
//  File.swift
//  MediaAccessKit
//
//  Created by 박성영 on 11/22/25.
//

import UIKit

// MARK: - 셀
final class PhotoCell: UICollectionViewCell {
    let imageView = UIImageView()
    let durationLabel = UILabel() //동영상이면 플레이타임 보이도록 설정
    
    let overlayView = UIView()
    let orderLabel = UILabel()
    
    override var isSelected: Bool {
        didSet {
            print("didset!!!")
            updateSelectionAppearance()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 이미지
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.frame = contentView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // duration label 설정
        durationLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        durationLabel.textColor = .white
        durationLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        durationLabel.textAlignment = .center
        durationLabel.layer.cornerRadius = 4
        durationLabel.clipsToBounds = true
        durationLabel.isHidden = true  // 기본은 숨김
        
        contentView.addSubview(durationLabel)
        
        // 어둡게 처리
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.frame = contentView.bounds
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.isHidden = true
        contentView.addSubview(overlayView)
        
        // 순서 라벨
        orderLabel.font = UIFont.boldSystemFont(ofSize: 16)
        orderLabel.textColor = .white
        orderLabel.textAlignment = .center
        orderLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.85)
        orderLabel.layer.cornerRadius = 15
        orderLabel.clipsToBounds = true
        orderLabel.isHidden = true
        
        contentView.addSubview(orderLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 오른쪽 하단 위치 설정
        let labelHeight: CGFloat = 18
        let labelWidth: CGFloat = 50
        durationLabel.frame = CGRect(
            x: contentView.bounds.width - labelWidth - 4,
            y: contentView.bounds.height - labelHeight - 4,
            width: labelWidth,
            height: labelHeight
        )
        
        // 순서 번호 라벨 → 오른쪽 위 작은 원
        orderLabel.frame = CGRect(
            x: contentView.bounds.width - 32,
            y: 4,
            width: 28,
            height: 28
        )
    }
    
    func setOrder(_ number: Int?) {
        if let number = number {
            orderLabel.text = "\(number)"
            orderLabel.isHidden = false
            contentView.layer.borderWidth = 3
            contentView.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            orderLabel.isHidden = true
        }
    }
    
    private func updateSelectionAppearance() {
        contentView.layer.borderWidth = isSelected ? 3 : 0
        contentView.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
