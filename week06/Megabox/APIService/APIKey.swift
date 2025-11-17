import Foundation

enum APIKey {
    static var tmdb: String {
        Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String ?? ""
    }
}
