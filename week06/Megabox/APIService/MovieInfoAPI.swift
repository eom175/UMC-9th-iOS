import Moya
import Foundation

enum MovieInfoAPI {
    // page는 기본 1, region은 옵션
    case nowPlaying(page: Int = 1, region: String? = nil)
}

extension MovieInfoAPI: BaseTarget {

    var path: String {
        switch self {
        case .nowPlaying:
            return "/now_playing"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case let .nowPlaying(page, region):
            var params: [String: Any] = [
                "language": "ko-KR",
                "page": page,
                "region": region ?? "KR" // 👈 이 부분 수정
            ]


         return .requestParameters(
                parameters: params,
                encoding: URLEncoding.queryString
            )
        }
    }

    var headers: [String : String]? {
      [
        "Accept": "application/json",
        "Authorization": "Bearer \(APIKey.tmdb)"
      ]
    }
}
