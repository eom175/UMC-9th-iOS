import Foundation
import Security

//account가 아이디
//service가 보여주는 페이지


class KeychainService{
    
    static let shared  = KeychainService() //싱글톤으로 선언
    private init() {}
    
    //Token 인코딩
    func save<T: Codable>(item: T, service: String, account: String){
        do{
            let data = try JSONEncoder().encode(item)
            saveInfo(data: data, service: service, account: account) // 이 함수에 인코딩한 토큰 전달
        }catch {
            print("Keychain 저장 실패 (Encoding): \(error.localizedDescription)")
        }
        
    }
    
    //
    func read<T: Codable>(service: String, account: String, type: T.Type) -> T? {
        // Keychain에서 Token가져오기
        guard let data = readInfo(service: service, account: account) else {
            return nil
        }
        
        // Data를 Codable 객체로 디코딩
        do {
            let item = try JSONDecoder().decode(T.self, from: data)
            return item
        } catch {
            print("Keychain 읽기 실패 (Decoding): \(error.localizedDescription)")
            return nil
        }
    }
    
    // ⭐️ [추가] String을 위한 저장 함수
    func saveString(_ string: String, service: String, account: String) {
        // String을 Data로 변환
        guard let data = string.data(using: .utf8) else {
            print("Keychain String 저장 실패 (Data 변환)")
            return
        }
        // 기존의 Data 저장 함수 호출
        saveInfo(data: data, service: service, account: account)
    }
    
    // ⭐️ [추가] String을 위한 읽기 함수
    func readString(service: String, account: String) -> String? {
        // 기존의 Data 읽기 함수 호출
        guard let data = readInfo(service: service, account: account) else {
            return nil
        }
        // Data를 String으로 변환하여 반환
        return String(data: data, encoding: .utf8)
    }
    
    
    
    //인코딩된 상태로 전달
    func saveInfo(data: Data, service: String, account: String){
        
       deleteInfo(service: service, account: account)
        
       let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil) //KeyChain에다가 저장
        
        if status != errSecSuccess {
            print("Keychain 저장 실패 (Status: \(status))")
        }
    }
    
    
   func readInfo(service: String, account: String) -> Data?{
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
       if status == errSecSuccess{
           return result as? Data
       }else{
           // errSecItemNotFound는 실패가 아닌, '항목 없음'이므로 조용히 처리
           if status != errSecItemNotFound {
               print("Keychain 읽기 실패 (Status: \(status))")
           }
           return nil
       }
    }
    
   func deleteInfo(service: String, account:String){
        
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Keychain 삭제 실패 (Status: \(status))")
        }
    }
    
}
