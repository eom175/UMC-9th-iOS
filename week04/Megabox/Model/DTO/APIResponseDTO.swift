import Foundation
import SwiftUI
struct APIResponseDTO: Codable{
    
    let status: String
    let message: String
    let data: MovieData
    
    
}

struct MovieData: Codable{
    
    let movies: [MovieDTO]
    
    
    
}

struct MovieDTO: Codable{
    
    let id: String
    let title: String
    let age_rating: String
    let schedules: [MovieInfoDTO]
    
    
    
}
struct MovieInfoDTO: Codable{
    
    
    let date: String
    let areas: [MovieAreaDTO]
    
    
    
}
struct MovieAreaDTO: Codable{
    let area: String
    let items: [MovieItemsDTO]
    
}

struct MovieItemsDTO: Codable{
    
    let auditorium: String
    let format: String
    let showtimes: [ShowTimesDTO]
    
    
}
struct ShowTimesDTO: Codable{
    
    let start: String
    let end: String
    let available: Int
    let total: Int
    
  
    
}
//-----------------

extension ShowTimesDTO {
    // ShowTimesDTO(DTO) -> Time(Domain)
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
    // MovieItemsDTO(DTO) -> ScreenSchedule(Domain)
    func toDomain() -> ScreenSchedule {
        return ScreenSchedule(
            // id는 ScreenSchedule 모델이 자동으로 생성
            screenName: self.auditorium, // DTO의 auditorium -> Domain의 screenName
            format: self.format,
            //(1번 함수 재사용)
            times: self.showtimes.map { $0.toDomain() }
        )
    }
}
extension MovieAreaDTO {
    // MovieAreaDTO(DTO) -> TheaterSchedule(Domain)
    func toDomain() -> TheaterSchedule {
        return TheaterSchedule(
           
            theaterName: self.area,
            screens: self.items.map { $0.toDomain() }
        )
    }
}


extension MovieDTO {
    private func fetchLocalDescription(for movieID: String) -> MovieDescription {
            
            // 원래는 뷰모델에서 관리했는데 이 설명이 jSON에는 없는 데이터이므로 여기에서 관리

            let localData: [String: MovieDescription] = [
                
                "m-001": MovieDescription(details: [
                    "어쩔 수 없는 상황에 처한",
                    "그들의 이야기"
                ]),
                "m-002": MovieDescription(details: [
                    "귀멸의 칼날, 새로운 이야기",
                    "무한성에서의 최종 결전"
                ]),
                "m-003": MovieDescription(details: [
                    "최고가 되지 못한 전설 VS 최고가 되고 싶은 루키",
                    "한때 주목받는 유망주였지만 끔찍한 사고로 F1에서 우승하지 못하고",
                    "한순간에 추락한 드라이버 ‘손; 헤이스'(브래드 피트).",
                    "그의 오랜 동료인 ‘루벤 세르반테스'(하비에르 바르뎀)에게",
                    "레이싱 복귀를 제안받으며 최하위 팀인 APGXP에 합류한다."
                ]),
                "m-004": MovieDescription(details: [
                    "얼굴"
                ]),
                "m-005": MovieDescription(details: [
                    "히메"
                ]),
                "m-006": MovieDescription(details: [
                   "보스"
                ]),
                "m-007": MovieDescription(details: [
                  "야당"
                ]),
                "m-008": MovieDescription(details: [
                   "장미"
                ]),
                
            ]
            
            // movieID에 해당하는 설명을 반환하고, 없으면 빈 설명을 반환
            return localData[movieID] ?? MovieDescription(details: [])
        }
    // MovieDTO(DTO) -> MovieCards(Domain)
    func toDomainCard() -> MovieCards {
        let description = fetchLocalDescription(for: self.id)
        return MovieCards(
            id: self.id,
            image: Image(self.id),
            booking: true,
            movieName: self.title,
            watchedStatus: "01",
            movieNameEn: "나중에",
            movieDescription: description // 별도 정의한 description 사용
        )
    }
    
   
}
