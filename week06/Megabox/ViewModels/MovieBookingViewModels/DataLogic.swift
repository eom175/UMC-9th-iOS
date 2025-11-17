import Foundation

// ViewModel 안에서의 데이터 처리 로직
extension MovieBookingViewModel {
    
    func loadDatesForSelectedMovie() {
        // 1. 선택된 영화 ID로 DTO 찾기
        // [변경됨] MovieDTO의 id는 Int이므로 String 변환하여 비교
        guard let movieID = selectedMovieID,
              let _ = allMovieDTOs.first(where: { String($0.id) == movieID }) else {
            self.weekDates = []
            return
        }
    
        // [변경됨] API에 스케줄 정보가 없으므로, 오늘부터 7일간의 날짜를 자동으로 생성합니다.
        let calendar = Calendar.current
        let today = Date()
        var dates: [Date] = []
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                dates.append(date)
            }
        }
        
        self.weekDates = dates
    }
    

    func loadTimeData(movieID: String, theaters: [String], date: Date) {
        
        // [변경됨] MovieDTO id 타입 불일치 해결 (Int vs String)
        guard let _ = allMovieDTOs.first(where: { String($0.id) == movieID }) else {
            self.schedules = []
            return
        }
        
        // [변경됨] API에 스케줄 정보가 없으므로, 더미(가짜) 시간표 데이터를 생성하여 반환합니다.
        // 실제 앱에서는 별도의 상영 시간표 API를 호출해야 합니다.
        
        var loadedSchedules: [TheaterSchedule] = []
        
        for theaterName in theaters {
            // 임의의 시간표 생성 로직
            let dummyTimes = [
                Time(startTime: "10:00", endTime: "~12:00", remainingSeats: 120, totalSeats: 200),
                Time(startTime: "13:30", endTime: "~15:30", remainingSeats: 80, totalSeats: 200),
                Time(startTime: "16:00", endTime: "~18:00", remainingSeats: 0, totalSeats: 200), // 매진 예시
                Time(startTime: "19:30", endTime: "~21:30", remainingSeats: 150, totalSeats: 200)
            ]
            
            // 각 극장마다 2D, IMAX 등 임의 포맷 할당
            let screenFormat = (theaterName == "CGV 용산아이파크몰") ? "IMAX" : "2D"
            
            let screenSchedule = ScreenSchedule(screenName: "1관", format: screenFormat, times: dummyTimes)
            
            loadedSchedules.append(TheaterSchedule(theaterName: theaterName, screens: [screenSchedule]))
        }
        
        self.schedules = loadedSchedules
    }
}
