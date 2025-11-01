import Foundation

// 이미지 레이아웃에 필요한 모든 정보를 담도록 모델을 변경합니다.
struct Time: Identifiable {
    let id = UUID()
    let startTime: String       // 예: "11:30"
    let endTime: String         // 예: "~13:58"
    let remainingSeats: Int   // 예: 109
    let totalSeats: Int       // 예: 116
}

/// "크리클라이너 1관" 처럼 상영관 하나의 정보를 담는 모델
struct ScreenSchedule: Identifiable {
    let id = UUID()
    let screenName: String  // "크리클라이너 1관"
    let format: String      // "2D"
    let times: [Time]       // 이 상영관의 시간표 목록
}

/// "강남" 극장처럼, 여러 상영관을 보유하는 모델
struct TheaterSchedule: Identifiable {
    let id = UUID()
    let theaterName: String // "강남"
    let screens: [ScreenSchedule] // 이 극장의 상영관 목록
}
