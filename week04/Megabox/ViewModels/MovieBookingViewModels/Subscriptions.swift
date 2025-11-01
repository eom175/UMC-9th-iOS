import Foundation
import Combine

// ViewModel의 내부 Combine 구독 객체
extension MovieBookingViewModel {
    
    //이 두개 함수는 단순히 값 할당만하면 되니 assign 사용
    func setupButtonStateSubscription() {
        $selectedMovieID
            .map { $0 != nil }
            .assign(to: &$isTheaterButtonEnabled)
    }
    
    func setupDateSelectionSubscription() {
          $selectedTheaters
              .map { !$0.isEmpty }
              .assign(to: &$isDateSelectionEnabled)
      }
    
    
    // 얘는 정보 받아서 더 복잡한 코드를 수행해야하니 .sink사용
    func setupTimeSelectionSubscription() {
        Publishers.CombineLatest3($selectedMovieID, $selectedTheaters, $selectedDate)
                //실제로 값이 바뀌었을 때만 동작하도록 보장
                .removeDuplicates { (prev, current) in
                    return prev.0 == current.0 && prev.1 == current.1 && prev.2 == current.2
                }
                .sink { [weak self] (movieID, theaters, date) in
                    if let movieID = movieID, !theaters.isEmpty, let date = date {
                        //sink안에서 값을 전달한 후 UI를 업데이트 해야됨
                        //파라미터로 sink안에서 업데이트된 값을 전달
                        //이렇게 안하고 직접 뷰모델에 접근해서 데이터를 사용하면 레이스 컨디션 발생
                        self?.loadTimeData(movieID: movieID, theaters: theaters, date: date)
                    } else {
                        self?.schedules = []
                    }
                }
                .store(in: &cancellables)
       }
       
    
    func setupSearchSubscription() {
            $searchText
                .removeDuplicates()
                .handleEvents(receiveOutput: { text in
                    if !text.isEmpty {
                        self.isSearching = true
                    }
                })
                .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
                .sink { [weak self] (text) in
                    guard let self = self else { return }
                    
                    self.isSearching = false
                    
                    if text.isEmpty {
                        self.filteredMovies = []
                    } else {
                        self.filteredMovies = self.movieCards.filter { movie in
                            movie.movieName.localizedCaseInsensitiveContains(text)
                        }
                    }
                }
                .store(in: &cancellables)
        }
}
