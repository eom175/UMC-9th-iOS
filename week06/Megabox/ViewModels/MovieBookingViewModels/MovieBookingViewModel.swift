import Combine
import SwiftUI
import Moya
import _Concurrency
let imageBaseURL = "https://image.tmdb.org/t/p/w500"
@MainActor
class MovieBookingViewModel: ObservableObject {
    
    @Published var errorMessage: String? = nil
    
    @Published var movieCards: [MovieCards] = []
    @Published var selectedMovieID: String?
    
    @Published var isTheaterButtonEnabled: Bool = false
    @Published var selectedTheaters: [String] = []
    
    @Published var weekDates: [Date] = []
    @Published var selectedDate: Date? = nil
    @Published var isDateSelectionEnabled: Bool = false
    
    @Published var schedules: [TheaterSchedule] = []
    
    @Published var searchText = ""
    @Published var filteredMovies: [MovieCards] = []
    @Published var isSearching: Bool = false
    
    @Published var allMovieDTOs: [MovieDTO] = []
    
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    
    // Moya Provider 선언
    private let provider = MoyaProvider<MovieInfoAPI>()
    
    var selectedMovie: MovieCards? {
        movieCards.first { $0.id == selectedMovieID }
    }
 
    init() {
     // 비동기 데이터 로드 시작
     _Concurrency.Task {
         await self.loadInitialData()
     }
        // 구독 설정
        setupButtonStateSubscription()
        setupDateSelectionSubscription()
        setupTimeSelectionSubscription()
        setupSearchSubscription()
    }
    
    @MainActor
    private func loadInitialData() async {
        do {
            // 1. Moya asyncRequest 호출
            let response = try await provider.asyncRequest(.nowPlaying(page: 1))
            
            // 2. 디코딩
            let decodedData = try JSONDecoder().decode(APIResponseDTO.self, from: response.data)
            
            // 3. 원본 DTO 저장 (로직 처리를 위해)
            self.allMovieDTOs = decodedData.results
            
            self.movieCards = decodedData.results.map { dto in
                
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
            print("Failed to load movies: \(error)")
            
            // 에러 처리
            if let moyaError = error as? MoyaError {
                self.errorMessage = "네트워크 오류: \(moyaError.localizedDescription)"
            } else {
                self.errorMessage = "알 수 없는 오류가 발생했습니다."
            }
        }
    }
    
    // MARK: - User Actions
    
    func selectMovie(id: String?) {
        DispatchQueue.main.async {
            withAnimation {
                self.selectedMovieID = id
                self.selectedDate = nil
                self.schedules = []
                // 날짜 로드 로직 호출 (이전 단계에서 수정한 DataLogic의 함수 사용)
                self.loadDatesForSelectedMovie()
            }
        }
    }
    
    func selectTheater(name: String) {
        if let index = selectedTheaters.firstIndex(of: name) {
            selectedTheaters.remove(at: index)
        } else {
            selectedTheaters.append(name)
        }
    }
    
    func selectDate(_ date: Date) {
        if selectedDate == date {
            selectedDate = nil
        } else {
            selectedDate = date
        }
    }
}
