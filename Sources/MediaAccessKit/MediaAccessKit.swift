// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import Foundation
import PhotosUI

// MARK: - 데이터 모델, 메일에 첨부할 파일 정보
public struct MediaItem {
    let data: Data          // 파일 데이터
    let mimeType: String    // MIME 타입 (예: image/jpeg, video/mp4)
    let fileName: String    // 파일 이름
}

@MainActor
@available(iOS 14, *)
public final class MediaAccessManager: NSObject {
    public static let shared = MediaAccessManager()
    
    private weak var presentingVC: UIViewController?
    
    // 결과를 전달할 클로저
    private var completion: (([MediaItem]) -> Void)?
    private let delegate = MediaAccessDelegate()
    
    public func presentMediaOptions(from vc: UIViewController,
                                    allowsMultipleSelection: Bool = true,
                                    alertMessage: String? = nil,
                                    configure: (UIAlertController) -> Void,
                                    completion: (([MediaItem]) -> Void)? = nil) {
        
        let alert = UIAlertController(title: nil, message: alertMessage, preferredStyle: .actionSheet)
        self.presentingVC = vc
        
        configure(alert)
        self.completion = completion
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = vc.view                // Alert를 붙일 기준 뷰
            popover.sourceRect = CGRect(
                x: vc.view.bounds.midX,
                y: vc.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []        // 화살표 제거
        }
        
        let albumBtn = UIAlertAction(title: "앨범", style: .default) { [weak self] action in
            print("사진 첨부하기")
            self?.permissionPhotoLibrary()
        }
        
        let cameraBtn = UIAlertAction(title: "카메라", style: .default) { [weak self] action in
            print("카메라 첨부하기")
            self?.permissionCamera()
        }
        
        alert.addAction(albumBtn)
        alert.addAction(cameraBtn)
        
        DispatchQueue.main.async {
            vc.present(alert, animated: true)
        }
        
    }
    
    private func AuthSettingOpen(AuthString: String) {
        
        let message = "앱 설정에서 \(AuthString)에 대한 액세스 권한을 허용으로 변경해주세요."
        let alert = UIAlertController(title: "앱 문의메일 기능을 위해 \(AuthString)에 대한 권한을 부여해야합니다.", message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "허용 안 함", style: .default) { [weak self] (UIAlertAction) in  //취소 클릭했을때 처리해야하는 함수 추가 할것
            print("\(String(describing: UIAlertAction.title)) 클릭")
        }
        
        let confirm = UIAlertAction(title: "확인", style: .default) { (UIAlertAction) in
            
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:]) { flag in
                print("flag ====", flag)
                print("셋팅 끝")
            }
            print("alert 창")
        }
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        
        presentingVC?.present(alert, animated: true, completion: nil)
    }
    
    
    //ios 14버전 이상에서만 뜨는 문구
    private func AuthPhotoSettingOpen(){
        let message = "앱 설정에서 사진에 대한 액세스 권한을\n '모든 사진' 또는 '선택한 사진'으로\n 변경해주세요."
        let alert = UIAlertController(title: "앨범에서 사진을 첨부하려면 액세스 권한을 부여해야합니다.", message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "허용 안 함", style: .default) { [weak self] (UIAlertAction) in  //취소 클릭했을때 처리해야하는 함수 추가 할것
            print("\(String(describing: UIAlertAction.title)) 클릭")
            
        }
        
        let confirm = UIAlertAction(title: "확인", style: .default) { (UIAlertAction) in
            //                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:]) { flag in
                print("flag ====", flag)
                print("셋팅 끝")
            }
            print("alert 창")
        }
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        
        presentingVC?.present(alert, animated: true, completion: nil)
    }
    
}

// 앨범
@MainActor
@available(iOS 14, *)
extension MediaAccessManager {
    
    private func permissionCamera() {
        
        let camera_Authorized = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch camera_Authorized {
        case .notDetermined: //카메라 권한을 처음 물어봤을때
            print("카메라 권한 처음 물어봄")
            
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async { [weak self] in
                    if granted {
                        print("카메라 권한 Y 상태")
                        self?.openCamera()
                    }
                    else {
                        print("카메라 권한 N 상태")
                        self?.AuthSettingOpen(AuthString: "카메라")
                    }
                }
            }
            
        case .restricted, .denied:
            print("카메라 권한 물어본 적 있고, 카메라 권한 N 상태일때")
            DispatchQueue.main.async { [weak self] in
                self?.AuthSettingOpen(AuthString: "카메라")
            }
        case .authorized :
            print("카메라 권한 상태 이미 Y")
            openCamera()
        @unknown default:
            
            break
        }
        
    }
    
    
    private func permissionPhotoLibrary() {
        let photo_Authorized = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        //사진 권한이 허용일때만 true 처리
        switch photo_Authorized {
        case .notDetermined:
            print("포토 권한 미결정 상태 (처음 권한을 물어봤을때)")
            
            //photo 권한
            let requiredAccessLevel: PHAccessLevel = .readWrite
            PHPhotoLibrary.requestAuthorization(for: requiredAccessLevel) { [weak self] authorizationStatus in
                DispatchQueue.main.async { [weak self] in
                    print("확인 ===", authorizationStatus)
                    switch authorizationStatus {
                    case .denied, .notDetermined, .restricted:
                        print("포토 권한 N 상태")
                        self?.AuthPhotoSettingOpen()
                        break
                        
                    case .limited:
                        print("포토 권한 limited 상태")
                        let pickerVC = LimitedLibraryPickerViewController()
                        pickerVC.onComplete = { [weak self] mediaitems in
                            print("넘어온 이미지", mediaitems)
                            self?.completion?(mediaitems)
                        }
                        
                        let nav = UINavigationController(rootViewController: pickerVC)
                        nav.modalPresentationStyle = .fullScreen // or .pageSheet
                        self?.presentingVC?.present(nav, animated: true)
                        break
                        
                    case .authorized:
                        print("포토 권한 Y 상태")
                        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: (self?.presentingVC)!)
                        self?.openAlbum()
                        break
                    default:
                        print("포토 권한 Unimplemented")
                    }
                }
            }
            
        case .restricted, .denied:
            print("포토 권한을 물어본 적이 있고, 포토 권한 N 상태 (설정 창으로 이동)")
            
            DispatchQueue.main.async { [weak self] in
                if #available(iOS 14, *) {
                    self?.AuthPhotoSettingOpen()
                }
                else{
                    self?.AuthSettingOpen(AuthString: "사진")
                }
            }
            
        case .limited:
            DispatchQueue.main.async {
                let pickerVC = LimitedLibraryPickerViewController()
                
                pickerVC.onComplete = { [weak self] mediaitems in
                    print("넘어온 이미지", mediaitems)
                    self?.completion?(mediaitems)
                }
                
                let nav = UINavigationController(rootViewController: pickerVC)
                nav.modalPresentationStyle = .fullScreen // or .pageSheet
                self.presentingVC?.present(nav, animated: true)
            }
            break
            
        case .authorized:
            print("포토 권한을 물어본 적이 있고, 포토 권한 Y 상태")
            openAlbum()
        @unknown default:
            break
        }
    }
    
    private func openAlbum() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 0 // 0 = 여러 개 선택 허용
        configuration.filter = .any(of: [.images, .videos]) // 사진 + 동영상
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = delegate
        delegate.completion = completion
        
        if let popover = picker.popoverPresentationController {
            guard let presentingVC = presentingVC else { return }
            popover.sourceView = presentingVC.view
            popover.sourceRect = CGRect(x: presentingVC.view.bounds.midX,
                                        y: presentingVC.view.bounds.midY,
                                        width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        presentingVC?.present(picker, animated: true)
    }
    
}

extension MediaAccessManager {
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            UIAlertController().displayAlert(msg: "카메라를 사용할 수 없습니다.", actions: [])
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = delegate
        delegate.completion = completion
        
        picker.sourceType = .camera
        presentingVC?.present(picker, animated: true)
    }
    
}
