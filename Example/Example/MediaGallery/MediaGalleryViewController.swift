//
//  MediaGalleryViewController.swift
//  Example
//
//  Created by 박성영 on 11/23/25.
//

import UIKit
import AVKit
import MediaAccessKit

class MediaGalleryViewController: UIViewController {

    var mediaItems: [MediaItem] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.dataSource = self
        cv.delegate = self
        cv.register(MediaCell.self, forCellWithReuseIdentifier: MediaCell.identifier)
        return cv
    }()

    init(mediaItems: [MediaItem]) {
        self.mediaItems = mediaItems
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension MediaGalleryViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaCell.identifier, for: indexPath) as! MediaCell

        let item = mediaItems[indexPath.item]

        if item.mimeType.starts(with: "image") {
            cell.configure(image: UIImage(data: item.data), isVideo: false)
        } else if item.mimeType.starts(with: "video") {
            cell.configure(image: thumbnailFromVideoData(item.data), isVideo: true)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = mediaItems[indexPath.item]
        print("select ---",item.mimeType)
        // -------------------------------
        // 📌 이미지 → 전체 화면 미리보기
        // -------------------------------
        if item.mimeType.starts(with: "image"),
           let image = UIImage(data: item.data) {

            let vc = ImagePreviewViewController(image: image)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            return
        }
        // -------------------------------
        // 📌 동영상 → AVPlayerViewController로 재생
        // -------------------------------
        if item.mimeType.starts(with: "video") {
            playVideo(from: item.data)
        }
    }
}


extension MediaGalleryViewController {
    func thumbnailFromVideoData(_ data: Data) -> UIImage? {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".mp4")

        do { try data.write(to: tempURL) }
        catch { return nil }

        let asset = AVAsset(url: tempURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        if let cgImage = try? generator.copyCGImage(at: .zero, actualTime: nil) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    func playVideo(from data: Data) {
        // 1. 임시 파일 생성
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".mp4")

        do {
            try data.write(to: tempURL)
        } catch {
            print("Failed to write video data to temp file: \(error)")
            return
        }

        // 2. AVPlayer 생성
        let player = AVPlayer(url: tempURL)
        let playerVC = AVPlayerViewController()
        playerVC.player = player

        // 3. 메인 스레드에서 present + play
        DispatchQueue.main.async {
            self.present(playerVC, animated: true) {
                player.play()
            }
        }
    }
}
