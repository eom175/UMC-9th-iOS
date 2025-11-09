// LoginViewModel.swift (수정)

import Foundation
import SwiftUI

import Alamofire
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

@Observable
class LoginViewModel {
   
    private var userViewModel: UserViewModel
    private var loginAPIURL = " ff" //여기다가 실제 서버 API주소 연결
 
        init(userViewModel: UserViewModel) {
            self.userViewModel = userViewModel
        }
    
    // 로그인 시도 함수
    func login(username: String, password: String) {
       
        //서버에 전달한 파라미터
        let parameters:[String : String] = [
            "username" : username,
            "password" : password
        ]
        
        AF.request(loginAPIURL, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: TokenInfo.self){
                response in
                switch response.result{
                case .success(let tokenInfo):
                    print("로그인 성공")
                    DispatchQueue.main.sync{
                        self.userViewModel.loginSuccess(username: username, tokens: tokenInfo)
                        
                
                    }
                case .failure(let error):
                    print("로그인 실패: \(error.localizedDescription)")
                }
            }
    }
    
    // --- 카카오 로그인 함수 (이 함수가 fetchKakaoUserInfo를 호출) ---
        func loginWithKakao() {
            if (UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                    if let error = error {
                        print("카카오톡 로그인 실패: \(error)")
                    } else if let oauthToken = oauthToken {
                        print("카카오톡 로그인 성공!")
                        // 👇 [성공 시] 이 함수를 호출합니다.
                        self.fetchKakaoUserInfo(oauthToken: oauthToken)
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                    if let error = error {
                        print("카카오 계정 로그인 실패: \(error)")
                    } else if let oauthToken = oauthToken {
                        print("카카오 계정 로그인 성공!")
                        // 👇 [성공 시] 이 함수를 호출합니다.
                        self.fetchKakaoUserInfo(oauthToken: oauthToken)
                    }
                }
            }
        }
        

        // --- 👇 [요청하신] fetchKakaoUserInfo 전체 코드 ---
        /**
         카카오 SDK에서 성공적으로 토큰을 받은 후,
         해당 사용자의 정보를 가져오기 위해 호출됩니다.
         - Parameter oauthToken: 카카오 SDK가 전달해준 인증 토큰
         */
        private func fetchKakaoUserInfo(oauthToken: OAuthToken) {
            
            // 1. 카카오 서버에 '방금 로그인한 사용자가 누구인지' 물어봅니다.
            UserApi.shared.me() { (user, error) in
                if let error = error {
                    print("카카오 사용자 정보 가져오기 실패: \(error)")
                }
                else if let user = user {
                    print("카카오 사용자 정보 가져오기 성공")
                    
                    // 2. [필수] 카카오에서 받은 사용자 고유 ID
                    guard let kakaoID = user.id else {
                        print("카카오 사용자 ID가 없습니다.")
                        return
                    }
                    
                    // 3. 카카오에서 받은 토큰을 -> 우리가 만든 TokenInfo 모델로 변환
                    // (자체 서버가 없으므로 카카오 토큰을 그대로 키체인에 저장)
                    let ourTokenInfo = TokenInfo(
                        accessToken: oauthToken.accessToken,
                        refreshToken: oauthToken.refreshToken
                    )
                    
                    // 4. [핵심] UserViewModel의 loginSuccess 함수를 호출합니다.
                    // (UI 업데이트이므로 메인 스레드에서 실행)
                    DispatchQueue.main.async {
                        self.userViewModel.loginSuccess(
                            username: String(kakaoID), // 카카오 ID(숫자)를 String으로 변환
                            tokens: ourTokenInfo
                        )
                    }
                    
                }
            }
        }
    }
