import Foundation

// ViewModel 안에서의 데이터 처리 로직
extension MovieBookingViewModel {
    
    
    func loadDatesForSelectedMovie() {
        // 1. 선택된 영화 ID로 DTO 찾기
        guard let movieID = selectedMovieID,
              let movieDTO = allMovieDTOs.first(where: { $0.id == movieID })else {
            self.weekDates = []
            return
        }
    
        let dateStrings = movieDTO.schedules.map { $0.date }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR") // 한국 시간대 보장
        
        self.weekDates = dateStrings.compactMap { formatter.date(from: $0) }
    }
    

    func loadTimeData(movieID: String, theaters: [String], date: Date) {
        
        guard let movieDTO = allMovieDTOs.first(where: { $0.id == movieID })else {
            self.schedules = []
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        let selectedDateString = formatter.string(from: date)
        
        guard let scheduleForDate = movieDTO.schedules.first(where: { $0.date == selectedDateString }) else {
            // 해당 날짜에 상영 정보가 없는 경우
            self.schedules = theaters.map { TheaterSchedule(theaterName: $0, screens: []) }
            return
        }
        
        var loadedSchedules: [TheaterSchedule] = []
        
        for theaterName in selectedTheaters {
            if let areaDTO = scheduleForDate.areas.first(where: { $0.area == theaterName }) {
                loadedSchedules.append(areaDTO.toDomain())
            } else {
                // DTO에 해당 극장 정보가 없으면 빈 스케줄 추가
                loadedSchedules.append(TheaterSchedule(theaterName: theaterName, screens: []))
            }
        }
        
        self.schedules = loadedSchedules
    }
}
