import Foundation
import Combine
import SwiftUI


class MovieBookingViewModel: ObservableObject {
    
    // UI와 관련된 데이터들
    @Published var movieCards: [MovieCards] = []
    @Published var selectedMovieID: String?
    
    @Published var isTheaterButtonEnabled: Bool = false
    @Published var selectedTheaters: [String] = []
    
    @Published var weekDates: [Date] = []
    @Published var selectedDate: Date? = nil
    @Published var isDateSelectionEnabled: Bool = false
    
    @Published var isAllSelected: Bool = false
    @Published var schedules: [TheaterSchedule] = []
    
    @Published var searchText = ""
    @Published var filteredMovies: [MovieCards] = []
    @Published var isSearching: Bool = false
    
    @Published var allMovieDTOs: [MovieDTO] = []
    
    
    private var cancellables = Set<AnyCancellable>()
    
    var selectedMovie: MovieCards? {
        movieCards.first { $0.id == selectedMovieID }
    }
    
    init() {
     
      
        loadDataFromJSON()
        setupButtonStateSubscription()
        setupDateSelectionSubscription()
        
        setupTimeSelectionSubscription()
    
        setupSearchSubscription()
        
    }
    
    // MovieBookingViewModel.swift
    private func loadDataFromJSON() {
        
        // 1. ⭐️ 모든 영화를 담을 임시 배열을 만듭니다.
        var allLoadedMovies: [MovieCards] = []
        
        // 2. JSON 데이터 로드 및 디코딩
        if let url = Bundle.main.url(forResource: "MovieSchedule", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            
            
            do {
                let response = try JSONDecoder().decode(APIResponseDTO.self, from: data)
                self.allMovieDTOs = response.data.movies
                
                // 3. ⭐️ JSON 영화 3개를 매핑하여 임시 배열에 추가
                let jsonMovies = self.allMovieDTOs.map { $0.toDomainCard() }
                allLoadedMovies.append(contentsOf: jsonMovies)
                
            } catch {
                print("JSON Decoding error: \(error)")
                // 디코딩에 실패해도 4번의 하드코딩 데이터는 로드됩니다.
            }
        }
        
        // 4. ⭐️ JSON에 없는 5개의 하드코딩 영화를 정의합니다.
        // (기존 loadMovieData에서 복사해 온 코드)
        let faceDesc = MovieDescription(details: [])
        let himeDesc = MovieDescription(details: [])
        let bossDesc = MovieDescription(details: [])
        let yadangDesc = MovieDescription(details: [])
        let rosesDesc = MovieDescription(details: [])

        let face = MovieCards(id: "m-004", image: Image("m-004"), booking: true, movieName: "얼굴", watchedStatus: "20만", movieNameEn: "Face", movieDescription: faceDesc)
        let hime = MovieCards(id: "m-005", image: Image("m-005"), booking: true, movieName: "모노노케히메", watchedStatus: "20만", movieNameEn: "Princess Mononoke", movieDescription: himeDesc)
        let boss = MovieCards(id: "m-006", image: Image("m-006"), booking: true, movieName: "보스", watchedStatus: "20만", movieNameEn: "The boss", movieDescription: bossDesc)
        let yadang = MovieCards(id: "m-007", image: Image("m-007"), booking: true, movieName: "야당", watchedStatus: "20만", movieNameEn: "Yadang", movieDescription: yadangDesc)
        let roses = MovieCards(id: "m-008", image: Image("m-008"), booking: true, movieName: "The Roses", watchedStatus: "20만", movieNameEn: "The roses", movieDescription: rosesDesc)
        
        // 5. ⭐️ 하드코딩 영화 5개를 임시 배열에 "추가"합니다.
        allLoadedMovies.append(contentsOf: [face, hime, boss, yadang, roses])
        
        // 6. ⭐️ JSON 3개 + 하드코딩 5개 = 총 8개의 영화를 @Published 프로퍼티에 할당합니다.
        self.movieCards = allLoadedMovies
    }
    
    private func setupButtonStateSubscription() {
        $selectedMovieID
            .map { movieID in
                return movieID != nil
            }            .assign(to: &$isTheaterButtonEnabled) //이걸 true로 변경
    }
    
    private func setupDateSelectionSubscription() {
          $selectedTheaters 
              // selectedTheaters 에 변화가 생겼을 시
              .map { !$0.isEmpty }
              // isDateSelectionEnable의 상태를 변경
              .assign(to: &$isDateSelectionEnabled)
      }

    private func setupTimeSelectionSubscription(){
           Publishers.CombineLatest3($selectedMovieID, $selectedTheaters, $selectedDate)
               .map{ (movieID, theaters, date) in
                   
                   return movieID != nil && !theaters.isEmpty && date != nil
                   
                   
               }
               //하나의 sink 블록 안에서
               .sink { [weak self] allSelected in
                   self?.isAllSelected = allSelected //1. 뷰에서 날짜를 보이게 하는 Published변수인 isAllselected를 true로 변화
                   
                   // 2. 그거와 별개로 allSelected를 가지고 외부 데이터를 호출하는 코드
                   if allSelected {
                   
                       self?.loadTimeData()
                   } else {
                       // 하나라도 선택이 풀리면 시간 데이터를 비웁니다.
                       self?.schedules = []
                   }
               }
               .store(in: &cancellables)
       }
       
    private func setupSearchSubscription() { // ⬅️ 12. 검색 로직 함수 추가
            $searchText
                .removeDuplicates() // 중복된 입력 무시
                .handleEvents(receiveOutput: { text in
                    // 딜레이가 시작되기 직전, 텍스트가 비어있지 않으면 "검색중" 상태로 변경
                    if !text.isEmpty {
                        self.isSearching = true
                    }
                })
                .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main) // 400ms 딜레이
                .sink { [weak self] (text) in
                    guard let self = self else { return }
                    
                    // 딜레이가 끝나면 "검색중" 상태 해제
                    self.isSearching = false
                    
                    if text.isEmpty {
                        self.filteredMovies = [] // 검색어가 비면 필터 결과 비우기
                    } else {
                        // 검색어(text)를 포함하는 영화를 `movieCards`에서 찾기 (대소문자 무시)
                        self.filteredMovies = self.movieCards.filter { movie in
                            movie.movieName.localizedCaseInsensitiveContains(text)
                        }
                    }
                }
                .store(in: &cancellables) // 구독 저장
        }

    
    
    // 뷰에서 호출할 메서드 (로직을 뷰에서 분리)
    func selectMovie(id: String?) {
        // 애니메이션 효과를 위해 main thread에서 실행
        DispatchQueue.main.async {
            withAnimation {
                self.selectedMovieID = id
                
                self.selectedDate = nil
                self.schedules = []
                
                self.loadDatesForSelectedMovie()
            }
        }
    }
    
    //극장을 선택(또는 해제)하는 메서드 추가
    func selectTheater(name: String) {
        // 배열에 이미 선택한 극장 이름이 있는지 확인
        if let index = selectedTheaters.firstIndex(of: name) {
            // 있으면 배열에서 제거 (다시선택 해서 해제하는 역할)
            selectedTheaters.remove(at: index)
        } else {
            // 없으면 배열에 추가 (선택)
            selectedTheaters.append(name)
        }
    }
    
    //날짜를 선택/해제하는 메서드 추가
        func selectDate(_ date: Date) {
            // 이미 선택된 날짜를 다시 누르면 선택 해제
            if selectedDate == date {
                selectedDate = nil
            } else {
                // 다른 날짜를 누르면 그 날짜로 선택 변경
                selectedDate = date
            }
        }
    
    
   
    //오늘부터 7일간의 날짜를 생성하는 메서드
    private func generateDatesForWeek() {
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
    
    
    
    private func loadDatesForSelectedMovie() {
            // 1. 선택된 영화 ID로 DTO 찾기
            guard let movieID = selectedMovieID,
                  let movieDTO = allMovieDTOs.first(where: { $0.id == movieID }) else {
                self.weekDates = [] // 선택된 영화 없으면 날짜 비우기
                return
            }
            
            // 2. DTO의 schedules에서 날짜 문자열 목록 추출
            // (예: ["2025-09-22", "2025-09-23", "2025-09-24"])
            let dateStrings = movieDTO.schedules.map { $0.date }
            
            // 3. ⭐️ 날짜 문자열을 [Date] 객체 배열로 변환 (사용자가 말한 Formatter)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "ko_KR") // 한국 시간대 보장
            
            self.weekDates = dateStrings.compactMap { formatter.date(from: $0) }
        }
    
    // MovieBookingViewModel.swift

    private func loadTimeData() {
        
        print("--- 1. loadTimeData()가 호출되었습니다. ---")
        
        // 1. 필요한 모든 ID/날짜가 있는지 확인
        guard let movieID = selectedMovieID,
              let movieDTO = allMovieDTOs.first(where: { $0.id == movieID }),
              let selectedDate = selectedDate else {
            
            print("🚨 오류: movieID, movieDTO, 또는 selectedDate가 nil입니다.")
            print("movieID: \(selectedMovieID ?? "nil")")
            print("selectedDate: \(selectedDate?.description ?? "nil")")
            self.schedules = []
            return
        }
        
        print("✅ 선택된 영화 ID: \(movieID)")
        
        // 2. ⭐️ 선택된 날짜(Date)를 JSON의 날짜 문자열(String)로 변환
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        // ⭐️ 1번 문제점 해결: Locale을 설정해야만 날짜 비교가 정확히 됩니다.
        formatter.locale = Locale(identifier: "ko_KR")
        let selectedDateString = formatter.string(from: selectedDate)
        
        print("✅ 선택된 날짜 (String 변환): '\(selectedDateString)'")

        // 3. ⭐️ 선택한 날짜에 해당하는 스케줄 DTO 찾기
        
        // ❗️ 여기서 nil이 되는지 확인하기 위해 JSON의 모든 날짜를 출력합니다.
        let allAvailableDates = movieDTO.schedules.map { $0.date }
        print("ℹ️ JSON에 있는 날짜 목록: \(allAvailableDates)")
        
        
        guard let scheduleForDate = movieDTO.schedules.first(where: { $0.date == selectedDateString }) else {
            // 해당 날짜에 상영 정보가 없는 경우 (JSON에 날짜는 있지만 area가 없을 수 있음)
            // -> 빈 스케줄 로드
            
            print("🚨 오류: '\(selectedDateString)' 날짜에 해당하는 스케줄(scheduleForDate)을 JSON에서 찾지 못했습니다.")
            
            self.schedules = selectedTheaters.map { TheaterSchedule(theaterName: $0, screens: []) }
            return
        }
        
        print("✅ 날짜 매칭 성공: '\(selectedDateString)'의 스케줄을 찾았습니다.")
        
        // 4. ⭐️ 선택된 각 극장별로 시간표 DTO를 -> 도메인 모델로 변환
        var loadedSchedules: [TheaterSchedule] = []
        
        // ❗️ 여기서 nil이 되는지 확인하기 위해 JSON의 모든 극장 이름을 출력합니다.
        let allAvailableAreas = scheduleForDate.areas.map { $0.area }
        print("ℹ️ 해당 날짜의 JSON에 있는 극장 목록: \(allAvailableAreas)")
        
        
        for theaterName in selectedTheaters {
            
            print("--- 🔄 '\(theaterName)' 극장 처리 시작 ---")
            
            // ⭐️ 2번 문제점: View의 "강남"과 JSON의 "강남점"이 다르면 매칭 실패
            if let areaDTO = scheduleForDate.areas.first(where: { $0.area == theaterName }) {
                // "강남", "홍대"처럼 DTO 데이터가 있으면 ⭐️매퍼(toDomain)⭐️ 호출
                print("✅ '\(theaterName)' 극장 매칭 성공. toDomain()을 호출합니다.")
                loadedSchedules.append(areaDTO.toDomain())
            } else {
                // "신촌"처럼 DTO 데이터가 아예 없으면
                // screens가 비어있는 도메인 모델 추가
                
                print("🚨 오류: '\(theaterName)' 극장을 JSON에서 찾지 못했습니다. (View 이름: '\(theaterName)' vs JSON 목록: \(allAvailableAreas))")
                
                loadedSchedules.append(TheaterSchedule(theaterName: theaterName, screens: []))
            }
        }
        
        // 5. 변환된 도메인 모델을 할당하여 View 업데이트
        print("--- ✅ 5. loadTimeData() 완료. schedules에 \(loadedSchedules.count)개의 극장 정보를 할당합니다. ---")
        self.schedules = loadedSchedules
    }
    
    
}
