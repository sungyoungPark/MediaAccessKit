//
//  File.swift
//  MediaAccessKit
//
//  Created by 박성영 on 11/22/25.
//

import UIKit
import Photos
import PhotosUI


class LimitedLibraryPickerViewController: UIViewController {

    private var collectionView: UICollectionView!
    private var assets: [PHAsset] = []

    var selectedAssets: [String] = []
    
    // 전달받는 클로저
    var onComplete: (([MediaItem]) -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "사진 선택"
        PHPhotoLibrary.shared().register(self)
        setupCollectionView()
        loadLimitedPhotos()
    }


    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        let size = (view.bounds.width - 3) / 4
        layout.itemSize = CGSize(width: size, height: size)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.allowsMultipleSelection = true
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
    
    // MARK: - 제한된 접근일 때 허용된 사진만 표시
    private func loadLimitedPhotos() {
        let selectMoreButton = UIBarButtonItem(
            title: "사진 더 선택",
            style: .plain,
            target: self,
            action: #selector(openLimitedLibraryPicker)
        )

        let doneButton = UIBarButtonItem(
            title: "완료",
            style: .done,
            target: self,
            action: #selector(didTapDone)
        )
        
        // 오른쪽 버튼 여러 개 추가
        navigationItem.rightBarButtonItems = [doneButton, selectMoreButton]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didTapCancel)
        )
        
        reloadAssets()
        self.collectionView.reloadData()
    }
    
    func reloadAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d OR mediaType == %d",
                                        PHAssetMediaType.image.rawValue,
                                        PHAssetMediaType.video.rawValue)
        
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        var temp: [PHAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in
            temp.append(asset)
        }
        self.assets = temp
        
        //선택된 이미지 배열에서 선택 취소된 이미지 배열삭제
        self.selectedAssets = selectedAssets.filter { id in
            assets.contains { $0.localIdentifier == id }
        }
        
        print("현재 접근 가능한 이미지 수: \(assets.count)")
    }
    
    // MARK: - 제한 접근 시 “사진 더 선택하기” 버튼
    @objc private func openLimitedLibraryPicker() {
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
        PHPhotoLibrary.shared().register(self)
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc func didTapDone() {
        // 선택 완료 처리
        print("selected ---", selectedAssets.count)
        let selected = assets.filter { selectedAssets.contains($0.localIdentifier) }
        print("selected ---", selected.count)
    
        convertAssetsToMediaItems(selected) { [weak self] mediaItems in
            self?.onComplete?(mediaItems)
        }

        
        dismiss(animated: true)
    }
    
    // MARK: - 깜빡임 없는 순서 업데이트
    private func updateVisibleOrderBadges() {
        for cell in collectionView.visibleCells {
            if let indexPath = collectionView.indexPath(for: cell),
               let photoCell = cell as? PhotoCell {
                
                let asset = assets[indexPath.item]
                
                if let order = selectedAssets.firstIndex(of: asset.localIdentifier) {
                    photoCell.setOrder(order + 1)
                } else {
                    photoCell.setOrder(nil)
                }
            }
        }
    }
    
    
    func convertAssetsToMediaItems(_ assets: [PHAsset], completion: @escaping ([MediaItem]) -> Void) {
        var items: [MediaItem] = []
        let group = DispatchGroup()
        
        let resourceManager = PHAssetResourceManager.default()

        for asset in assets {
            group.enter()
            
            let resources = PHAssetResource.assetResources(for: asset)
            
            // 원본 파일 우선 선택
            guard let resource = resources.first else {
                group.leave()
                continue
            }
            
            let fileName = resource.originalFilename
            let mimeType = if asset.mediaType == .image { "image/jpeg" } else { "video/quicktime" }

            // Data 저장 버퍼
            let data = NSMutableData()
            
            let options = PHAssetResourceRequestOptions()
            options.isNetworkAccessAllowed = true
            
            resourceManager.requestData(for: resource, options: options) { chunk in
                data.append(chunk)
            } completionHandler: { error in
                if error == nil {
                    let item = MediaItem(
                        data: data as Data,
                        mimeType: mimeType,
                        fileName: fileName
                    )
                    items.append(item)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(items)
        }
    }
}


extension LimitedLibraryPickerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let asset = assets[indexPath.item]
        
        let itemsPerRow: CGFloat = 3
        let spacing: CGFloat = 2
        let totalSpacing = (itemsPerRow - 1) * spacing
        let width = (collectionView.bounds.width - totalSpacing) / itemsPerRow
        
        // 화면 배율 고려 (레티나)
        let targetSize = CGSize(width: width * UIScreen.main.scale,
                                height: width * UIScreen.main.scale)
        
        let manager = PHImageManager.default()
        manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { image, _ in
            cell.imageView.image = image
            if asset.mediaType == .video {
                print("이거는 비디오!!!", asset.duration)
                let sec = Int(asset.duration)
                let duration = String(format: "%02d:%02d", sec / 60, sec % 60)
                print("VIDEO - duration: \(duration)")
                cell.durationLabel.text = duration
                cell.durationLabel.isHidden = false
            }
            else {
                cell.durationLabel.isHidden = true
            }
        }
        
        // 선택 순서 업데이트
        if let order = selectedAssets.firstIndex(of: asset.localIdentifier) {
            cell.setOrder(order + 1)
        } else {
            cell.setOrder(nil)
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let asset = assets[indexPath.item]
        print("선택된 asset: \(asset.localIdentifier)")
    
        selectedAssets.append(asset.localIdentifier)
        updateVisibleOrderBadges()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let asset = assets[indexPath.item]
        selectedAssets.removeAll { $0 == asset.localIdentifier }
        
        updateVisibleOrderBadges()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let spacing: CGFloat = 2    // 셀 간격
        let itemsPerRow: CGFloat = 3
        
        let totalSpacing = (itemsPerRow - 1) * spacing
        let width = (collectionView.bounds.width - totalSpacing) / itemsPerRow
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}

extension LimitedLibraryPickerViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            print("권한 변경 감지됨 — 새로 fetch")
            self.reloadAssets()
            self.collectionView.reloadData()
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
        }
    }
}
