import Foundation
import Combine
import SwiftUI

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
    private let dataService = MovieDataService()
    
    var selectedMovie: MovieCards? {
        movieCards.first { $0.id == selectedMovieID }
    }
    

    init() {
        // DataService를 통해 데이터 로드
        loadInitialData()
        
        // 구독 설정
        setupButtonStateSubscription()
        setupDateSelectionSubscription()
        setupTimeSelectionSubscription()
        setupSearchSubscription()
    }
    
    private func loadInitialData() {
        do {
            // JSON 데이터를 받아옴
            let (loadedMovies, loadedDTOs) = try dataService.loadDataFromJSON()
            
       
            self.movieCards = loadedMovies
            self.allMovieDTOs = loadedDTOs
            
        } catch {
        
            print("Failed to load movies: \(error)")
            self.errorMessage = "영화 목록을 불러오는 데 실패했습니다."
            if let movieError = error as? MovieLoadError {
                switch movieError {
                case .invalidData:
                    self.errorMessage = "영화 데이터가 유효하지 않음"
                case .decodingFailed:
                    self.errorMessage = "영화를 불러오는 데 실패했습니다."
                case .networkFailed(let specificError):
                    self.errorMessage = "네트워크 오류: \(specificError.localizedDescription)"
                case .fileNotFound:
                    self.errorMessage = "영화 파일을 찾을 수 없습니다."
                }
            }
        }
    }
    
    
    func selectMovie(id: String?) {
        DispatchQueue.main.async {
            withAnimation {
                self.selectedMovieID = id
                self.selectedDate = nil
                self.schedules = []
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

