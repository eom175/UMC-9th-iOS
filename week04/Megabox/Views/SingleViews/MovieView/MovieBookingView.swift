import SwiftUI

struct MovieBookingView: View {
    
    @StateObject private var viewModel = MovieBookingViewModel()
    
    @State private var isShowingMovieSheet = false
    
    private var timeGridColumns: [GridItem] = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
   
    
    // MARK: - Main Body
    var body: some View {
        NavigationStack {
            
            VStack(spacing: 0) {
               
                HStack {
                    Text("영화별 예매")
                        .font(.bold22)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 31)
                .padding(.bottom, 10)
                .background(.purple03)
                ScrollView
                {
                    
                    VStack(alignment: .leading, spacing: 23) {
                        
                        movieSelectionHeader
                        moviePostersList
                        theaterSelectionButtons
                        
                        dateSelectionView
                        timeSelectionView
                            
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                
                
            }
            
        }
    }
 
    // MARK: - UI Components (분리된 서브 뷰)
    
    /// 1. 선택된 영화 정보를 보여주는 헤더 뷰
    private var movieSelectionHeader: some View {
        HStack {
            Text("15")
                .font(.bold18)
                .foregroundColor(.white)
                .frame(width: 26, height: 24)
                .background(.orange) // 순서 수정
                .cornerRadius(4)
                .overlay(
                       RoundedRectangle(cornerRadius: 4)
                           .stroke(Color.black, lineWidth: 1) // 100% 검은색 외곽선
                   )
                   .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)
            
             Spacer()
            
            Text(viewModel.selectedMovie?.movieName ?? "영화를 선택하세요")
                .font(.semiBold18)
                .frame(width: 238, height: 24, alignment: .leading)
            
            
            Button(action: {
                
                isShowingMovieSheet = true
                
                
            }, label: {
                Text("전체영화")
                    .font(.semiBold14)
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .frame(width: 69, height: 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.grey02, lineWidth: 1)
                    )
            })
            .sheet(isPresented: $isShowingMovieSheet){
                
                MovieSheetView(viewModel: self.viewModel)
                    .presentationDragIndicator(.visible)
                
                
            }
            
            
            
        }
        
    }
    
    /// 2. 영화 포스터들을 보여주는 가로 스크롤 뷰
    private var moviePostersList: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(viewModel.movieCards) { movie in
                    movie.image
                        .resizable()
                        .frame(width: 62, height: 89)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(viewModel.selectedMovieID == movie.id ? .purple03 : Color.clear, lineWidth: 4)
                        )
                        .onTapGesture {
                            withAnimation {
                                viewModel.selectMovie(id: movie.id)
                            }
                        }
                }
            }
        }
     
    }
    
    /// 3. 극장 선택 버튼들을 보여주는 뷰
    private var theaterSelectionButtons: some View {
        HStack(spacing: 10) {
            ForEach(["강남", "홍대", "신촌"], id: \.self) { theaterName in
                theaterButton(place: theaterName)
            }
        }
        
    }
    
// 4. 날짜 버튼들을 보여주는 뷰
    private var dateSelectionView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(viewModel.weekDates, id: \.self) { date in
                    dateButton(for: date)
                }
            }
        }  // 극장이 선택되지 않았다면 전체적으로 반투명하게 처리
        .opacity(viewModel.isDateSelectionEnabled ? 1.0 : 0.4)
        // 극장이 선택되지 않았다면 터치 불가
        .disabled(!viewModel.isDateSelectionEnabled)
       
    }
    
    
    private var timeSelectionView: some View {
        
   
        // VStack으로 감싸서 여러 극장 정보를 세로로 나열합니다.
        VStack(alignment: .leading, spacing: 25) {
            
            // ViewModel의 schedules 배열을 순회합니다. (예: "강남", "홍대"가 순서대로 들어옴)
            ForEach(viewModel.schedules) { schedule in
                
                // --- 1. 극장 이름 (예: "강남") ---
                Text(schedule.theaterName)
                    .font(.bold18)
                    .foregroundColor(.black)
                
                // --- 2. 상영관 목록 또는 "시간대 없음" ---
                
                // Check 1: "홍대", "신촌" (screens empty)
                if schedule.screens.isEmpty {
                    // "홍대", "신촌" 등 screens 배열이 비어있는 경우
                    Text("해당 영화관에는 시간대가 없습니다.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Check 2: "강남" (screens not empty)
                } else {
                    
    
                        VStack(spacing: 15) {
                            
                            // 이 극장의 모든 상영관(예: 1관, 2관...)을 순회
                            ForEach(schedule.screens) { screen in
                                
                                // --- 상영관 이름 (예: "크리클라이너 1관") ---
                                HStack {
                                    Text(screen.screenName)
                                        .font(.bold18)
                                    Spacer()
                                    Text(screen.format)
                                        .font(.semiBold14)
                                        .foregroundColor(.black)
                                }
                                
                                // --- 시간표 그리드 ---
                                LazyVGrid(columns: timeGridColumns, spacing: 19) {
                                    ForEach(screen.times) { time in
                                        timeCell(for: time) //
                                    }
                                }
                            }
                        }
                }
            }
        }
        // 'schedules 배열이 채워져있을때만 보이도록 
        .opacity(!viewModel.schedules.isEmpty ? 1.0 : 0.0)
        .animation(.easeInOut, value: !viewModel.schedules.isEmpty)
        .disabled(viewModel.schedules.isEmpty)
    }
    
    //------------------------------------
    
    private func theaterButton(place: String) -> some View {
        
        
        Button(action: {
            
            viewModel.selectTheater(name: place)
            
            
        }, label: {
            Text(place)
                .font(.semiBold16)
                .foregroundColor(viewModel.selectedTheaters.contains(place) ? .white : (viewModel.isTheaterButtonEnabled ? .grey05 : .gray))
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .frame(width:55, height: 35)
                .background(viewModel.selectedTheaters.contains(place) ? .purple03 : Color.grey01)
                .cornerRadius(15)
                
            
            
        }).disabled(!viewModel.isTheaterButtonEnabled)
            .animation(.easeInOut(duration: 0.2), value: viewModel.selectedTheaters.contains(place))
            .animation(.easeInOut(duration: 0.2), value: viewModel.isTheaterButtonEnabled)
        
    }
    
   
    // MovieBookingView.swift

    private func dateButton(for date: Date) -> some View {
        
       
        Button(action: {
            
            viewModel.selectDate(date)
        }) {
            // 3. 기존 VStack은 Button의 Label(콘텐츠)이 됩니다.
            VStack(spacing: 4){
                Text(date.formatted(.dateTime.day()))
                            .font(.bold18)
                
                Text(formatWeekday(date))
                    .font(.semiBold14)
                    
            }
            .padding(.vertical,12)
            .padding(.horizontal, 10)
            .frame(width: 55, height: 60)
            .foregroundColor(viewModel.selectedDate == date ? .white : getWeekdayColor(for: date))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(viewModel.selectedDate == date ? .purple03: Color.clear)
            )
          
            
        }
       
        .buttonStyle(.plain)
    }

       private func getWeekdayColor(for date: Date) -> Color {
           let calendar = Calendar.current
           if calendar.isDateInWeekend(date) {
               let weekday = calendar.component(.weekday, from: date)
               return weekday == 1 ? .red : .tag // 일요일: 빨강, 토요일: 파랑
           }
           return .black // 평일: 검정
       }
    
       private func formatWeekday(_ date: Date) -> String {
           let calendar = Calendar.current
           if calendar.isDateInToday(date) {
               return "오늘"
           } else if calendar.isDateInTomorrow(date) {
               return "내일"
           } else {
             
               let formatter = DateFormatter()
               formatter.locale = Locale(identifier: "ko_KR")
               formatter.dateFormat = "E"
               return formatter.string(from: date)
           }
       }
    
    private func timeCell(for time: Time) -> some View {
            VStack(spacing: 4) {
                Spacer()
                Text(time.startTime)
                    .foregroundColor(.black)
                    .font(.bold18)
                    .frame(width: 55, height: 24)
                    
                
                Text(time.endTime)
                    .font(.regular12)
                    .foregroundColor(.grey03)
                    .frame(width: 55, height: 24)
                    
                
                HStack(spacing: 4){
                    
                    Text("\(time.remainingSeats)")
                        .foregroundColor(.purple03)
                        .font(.semiBold14)
                    
                    Text("/")
                    
                    Text("\(time.totalSeats)")
                        .foregroundColor(.grey03)
                        .font(.semiBold14)
                    
                    
                }
                .frame(width:59, height: 20)
                .padding(10)
            }
            .padding(10)
            .frame(width: 75, height: 86)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.grey02, lineWidth: 1)
            )
        }

}
    

#Preview {
    MovieBookingView()
}

