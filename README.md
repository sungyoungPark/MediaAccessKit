# 아이폰에 카메라 및 앨범(사진, 동영상)에 권한 및 접근을 쉽게 사용할 수 있게 구현한 라이브러리


## 환경 요구사항
+ 언어: Swift
+ Deployment Target: iOS 14.0

## 요약
+ 앱에서 카메라와 앨범에서 이미지 혹은 동영상을 가져올때 뜨는 권한 창을 매번 구현하고,
  ios14 이후에 나온 "선택 사진" 옵션에 대응하여 선택된 이미지를 collectionView로 보여준다.
  카메라나 앨범을 사용하게 될때, MediaAccessManager.shared.presentMediaOptions 함수를 사용해주면 된다.

## 사용법
+ Xcode에서 Swift Package Manager(SPM) 추가

1. Xcode 프로젝트를 엽니다.
2. 메뉴에서 **File > Add Packages…** 를 선택합니다.
3. GitHub에서 추가하려는 라이브러리의 URL을 입력합니다.
4. 원하는 버전을 선택합니다.
5. 프로젝트에 추가할 타겟을 선택하고 **Add Package** 버튼을 클릭합니다.

## ■ 샘플 앱 화면

![Image](https://github.com/user-attachments/assets/88b4717b-555f-4948-a10e-47efb9c9f50d)

![Image](https://github.com/user-attachments/assets/f1c4be32-b492-45f5-8dae-92c87f8b5762)


## ■ 사용 예시

![Image](https://github.com/user-attachments/assets/0348b262-1577-436b-bb44-6d4552fdd79d)
