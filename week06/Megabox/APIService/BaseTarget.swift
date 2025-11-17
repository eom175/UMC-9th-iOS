import Moya
import Foundation

protocol BaseTarget: TargetType {}

extension BaseTarget {

    // TMDB v3 movie base URL
    var baseURL: URL {
        URL(string: "https://api.themoviedb.org/3/movie")!
    }

    // 샘플 데이터 (안 쓰면 빈 Data 반환)
    var sampleData: Data {
        Data()
    }

    // 공통 헤더 (필요 없으면 nil)
    var headers: [String : String]? {
       nil
    }
}
