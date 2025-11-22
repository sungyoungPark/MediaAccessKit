//
//  File.swift
//  MediaAccessKit
//
//  Created by 박성영 on 11/22/25.
//

import UIKit
import PhotosUI

final class MediaAccessDelegate: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {
    
    var completion: (([MediaItem]) -> Void)?
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if results.isEmpty { return }
        
        let group = DispatchGroup()
        var attachments: [MediaItem] = []
        
        for result in results {
            let provider = result.itemProvider
            
            // 이미지 처리
            if provider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                provider.loadObject(ofClass: UIImage.self) { (object, error) in
                    defer { group.leave() }
                    if let image = object as? UIImage,
                       let imageData = image.jpegData(compressionQuality: 0.9) {
                        let media = MediaItem(data: imageData, mimeType: "image/jpeg", fileName: "photo\(attachments.count).jpg")
                        attachments.append(media)
                    }
                }
            }
            
            // 동영상 처리
            else if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                group.enter()
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { (url, error) in
                    defer { group.leave() }
                    guard let url = url else { return }
                    
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
                    do {
                        try FileManager.default.copyItem(at: url, to: tempURL)
                        if let videoData = try? Data(contentsOf: tempURL) {
                            let media = MediaItem(data: videoData, mimeType: "video/quicktime", fileName: "video\(attachments.count).mov")
                            attachments.append(media)
                        }
                    } catch {
                        print("동영상 복사 실패:", error)
                    }
                }
            }
        }
        
        //모든 파일 로드 완료 시점
        group.notify(queue: .main) {
            self.completion?(attachments)
            self.completion = nil // 메모리 해제 방지
        }
    }
    
    // MARK: - 촬영 완료 시 호출
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        print("촬영 완료 ---", image)
        let mediaItem = MediaItem(data: image.pngData()!, mimeType: "image/jpeg", fileName: "test.png")
        completion?([mediaItem])
        
    }
    
    // MARK: - 촬영 취소 시
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        print("취소!!")
    }
    
}
