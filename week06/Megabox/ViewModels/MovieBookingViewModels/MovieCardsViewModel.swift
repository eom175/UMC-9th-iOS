import SwiftUI
import Moya
import _Concurrency

@MainActor
@Observable
class MovieCardsViewModel {
    var movieCards: [MovieCards] = []
    let imageBaseURL = "https://image.tmdb.org/t/p/w500"
    
    // Moya Provider 생성, 에러확인용 플러그인
    private let provider = MoyaProvider<MovieInfoAPI>(plugins: [NetworkLoggerPlugin()])
    
    init() {
        // 초기화 시 비동기로 데이터 로드 시작
        _Concurrency.Task {
            await loadMovies()
        }
    }
    
    @MainActor
    func loadMovies() async {
        do {
            // 1. async/await를 사용하여 API 요청
            let response = try await provider.asyncRequest(.nowPlaying(page: 1))
            
            // 2. JSON 디코딩
            let decodedResponse = try JSONDecoder().decode(APIResponseDTO.self, from: response.data)
            
            self.movieCards = decodedResponse.results.map { dto in
                
                // 3. posterPath가 nil일 수도 있으므로 옵셔널 처리
                var fullURL: URL? = nil
                if let posterPath = dto.posterPath {
                    fullURL = URL(string: imageBaseURL + posterPath)
                }
                
                return MovieCards(
                    id: String(dto.id),
                    // image: Image(systemName: "play.rectangle.fill"), // 👈 기존
                    posterURL: fullURL, // 👈 [수정] 조립된 URL 전달
                    booking: true,
                    movieName: dto.title,
                    watchedStatus: "\(Int(dto.voteCount))명", // 관람객 수
                    movieNameEn: dto.originalTitle,
                    movieDescription: MovieDescription(details: [dto.overview])
                )
            }
            
        } catch {
            print("영화 목록 로드 실패: \(error)")
            // 에러 발생 시 빈 배열 혹은 에러 상태 처리
            self.movieCards = []
        }
    }
}
