// MegaboxApp.swift (수정)

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct MegaboxApp: App {
    @State private var userViewModel = UserViewModel()
    
    init(){
        KakaoSDK.initSDK(appKey: "e795673090d362bc069f906c37141855")
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView() // 👈 이 뷰가 userViewModel을 물려받음
                .environment(userViewModel)
                // ✅ 2. [필수 추가] 카카오 로그인 콜백을 받기 위해 이 코드가 꼭 필요합니다.
                .onOpenURL { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
