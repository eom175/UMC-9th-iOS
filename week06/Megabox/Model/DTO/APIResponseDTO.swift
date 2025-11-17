import Foundation
import SwiftUI

// MARK: - 최상위 응답
struct APIResponseDTO: Codable {
    // 기존 구조: status, message, data
    // 변경 구조: dates, page, results(영화목록)
    
    let dates: DateRange? // dates 객체는 없을 수도 있으므로 Optional
    let page: Int
    let results: [MovieDTO] // 기존의 MovieData.movies 역할
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case dates, page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// dates 객체 처리를 위한 구조체 추가
struct DateRange: Codable {
    let maximum: String
    let minimum: String
}

// MARK: - 영화 상세 정보 (스크린샷 기반)
struct MovieDTO: Codable {
    // 기존: id(String), title, age_rating, schedules
    // 변경: id(Int), title, overview, poster_path 등등...
    
    let id: Int             // API에서는 Int로 옴
    let title: String
    let originalTitle: String
    let overview: String    // 줄거리 (기존의 로컬 설명 대체 가능)
    let posterPath: String? // 포스터 이미지 경로
    let releaseDate: String
    let voteAverage: Double
    let voteCount: Int // 👈 [추가] "vote_count"를 받기 위해 추가
    let adult: Bool
    
    // ⚠️ 주의: 스크린샷의 API에는 '상영 시간표(schedules)' 정보가 없습니다.
    // 따라서 아래 구조체들은 이 API에서 파싱되지 않습니다.
    // let schedules: [MovieInfoDTO]
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, adult
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count" // 👈 [추가] JSON 키 매핑
    }
}

// -----------------------------------------------------------
// ⚠️ 중요: 아래 구조체들(스케줄 관련)은 현재 스크린샷의 JSON에 포함되어 있지 않습니다.
// 다른 API(예: 예매 상세 API)를 호출할 때 사용하거나, 더미 데이터로 남겨두어야 합니다.
// 일단 에러 방지를 위해 코드는 남겨두지만, 위 APIResponseDTO에서 연결은 끊겨 있습니다.
// -----------------------------------------------------------

struct MovieInfoDTO: Codable {
    let date: String
    let areas: [MovieAreaDTO]
}

struct MovieAreaDTO: Codable {
    let area: String
    let items: [MovieItemsDTO]
}

struct MovieItemsDTO: Codable {
    let auditorium: String
    let format: String
    let showtimes: [ShowTimesDTO]
}

struct ShowTimesDTO: Codable {
    let start: String
    let end: String
    let available: Int
    let total: Int
}

// MARK: - Extensions (Domain Mapping)

extension MovieDTO {
    // MovieDTO(DTO) -> MovieCards(Domain)
    func toDomainCard() -> MovieCards {
        
        // 포스터 이미지 URL 처리
        let imageBaseURL = "https://image.tmdb.org/t/p/w500"
        var fullPosterURL: URL? = nil
        if let posterPath = self.posterPath {
            fullPosterURL = URL(string: imageBaseURL + posterPath)
        }
        
        // DTO의 id는 Int, Domain은 String일 경우 형변환 필요
        return MovieCards(
            id: String(self.id),
            // image: Image(systemName: "film"), // 👈 [삭제]
            posterURL: fullPosterURL, // 👈 [수정] 생성된 URL을 전달
            booking: true, // API에 없으므로 하드코딩
            movieName: self.title,
            watchedStatus: "\(self.voteCount)명", // 👈 [수정] voteCount를 사용
            movieNameEn: self.originalTitle,
            movieDescription: MovieDescription(details: [self.overview])
        )
    }
}

// 아래 Extension들은 현재 API 응답에 데이터가 없으므로 실제로는 호출되지 않지만,
// 기존 코드 호환성을 위해 남겨둡니다.

extension ShowTimesDTO {
    func toDomain() -> Time {
        return Time(
            startTime: self.start,
            endTime: "~\(self.end)",
            remainingSeats: self.available,
            totalSeats: self.total
        )
    }
}

extension MovieItemsDTO {
    func toDomain() -> ScreenSchedule {
        return ScreenSchedule(
            screenName: self.auditorium,
            format: self.format,
            times: self.showtimes.map { $0.toDomain() }
        )
    }
}

extension MovieAreaDTO {
    func toDomain() -> TheaterSchedule {
        return TheaterSchedule(
            theaterName: self.area,
            screens: self.items.map { $0.toDomain() }
        )
    }
}
