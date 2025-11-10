// UserViewModel.swift (전체 수정)
import Foundation
import SwiftUI

@Observable
class UserViewModel {
    var username: String = ""
    var isLoggedIn: Bool = false
    
    private var tokenInfo: TokenInfo?
    
    private let tokenService = ".com"
    private let tokenAccount = "userTokens"     // 토큰 저장을 위한 키
    private let usernameAccount = "username" // ⭐️ 아이디 저장을 위한 키 (추가)
    
    // private let usernameKey = "username" // ⬅️ UserDefaults 키 삭제
   
    init() {
        // 1. ⭐️ Keychain에서 '아이디' 불러오기
        let loadedUsername = KeychainService.shared.readString(
            service: tokenService,
            account: usernameAccount
        )
        
        // 2. Keychain에서 '토큰' 불러오기
        let loadedTokens = KeychainService.shared.read(
            service: tokenService,
            account: tokenAccount,
            type: TokenInfo.self
        )
        
        // 3. ⭐️ 아이디와 토큰이 '둘 다' 존재해야 자동 로그인
        if let username = loadedUsername, let tokens = loadedTokens {
            self.username = username
            self.tokenInfo = tokens
            self.isLoggedIn = true // ⬅️ 자동 로그인 성공!
            print("Keychain에서 아이디/토큰 로드 성공. 자동 로그인합니다.")
        } else {
            self.isLoggedIn = false
            print("저장된 아이디 또는 토큰 없음. 로그인 화면으로 이동합니다.")
        }
    }
    
    func loginSuccess(username: String, tokens: TokenInfo) {
        // 1. 토큰 정보를 Keychain에 (Codable로) 저장
        KeychainService.shared.save(item: tokens, service: tokenService, account: tokenAccount)
        
        // 2. 사용자 아이디를 Keychain에 (String으로) 저장
        KeychainService.shared.saveString(username, service: tokenService, account: usernameAccount)
        
        // 3. ViewModel 상태 업데이트 (UI 변경 트리거)
        self.tokenInfo = tokens
        self.username = username
        self.isLoggedIn = true
        
        print("로그인 성공 및 토큰/아이디 저장 완료.")
    }
    
    func logout() {
        // 1. ⭐️ Keychain에서 토큰 삭제
        KeychainService.shared.deleteInfo(service: tokenService, account: tokenAccount)
        
        // 2. ⭐️ Keychain에서 아이디 삭제
        KeychainService.shared.deleteInfo(service: tokenService, account: usernameAccount)
        
        // 3. ViewModel 상태 초기화
        self.tokenInfo = nil
        self.username = "" // 아이디도 초기화
        self.isLoggedIn = false
        
        print("로그아웃 및 토큰/아이디 삭제 완료.")
    }
        
    func getAccessToken() -> String? {
        // TODO: 실제로는 토큰 만료 여부 확인 및 갱신 로직 필요
        return tokenInfo?.accessToken
    }
    
    func saveNewUserName(newUsername: String){
        
        self.username = newUsername
        
    }
}
