import SwiftUI

struct MovieSheetView: View {
    
//    @StateObject private var viewModel = MovieBookingViewModel()
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: MovieBookingViewModel
    
    private var movieGridColumns: [GridItem] = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    
    init(viewModel: MovieBookingViewModel)
    {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack{
            Spacer()
            
            Text("영화 선택")
                .font(.regular20)
                .foregroundColor(.black)
            
           searchMovieView
                .padding(.horizontal, 16)
            

            
            ScrollView{
                
                if viewModel.isSearching{
                    Text("검색중...")
                        .font(.semiBold14)
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                }
                else if viewModel.searchText.isEmpty{
                    movieSheetView(for:self.viewModel.movieCards)
                }
                else if viewModel.filteredMovies.isEmpty{
                    Text("검색 결과가 없습니다.")
                        .font(.semiBold14)
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                }
                else {
                    // ViewModel의 'filteredMovies' 목록을 그림
                    movieSheetView(for: viewModel.filteredMovies)
                }
                
            }
            
            
            
        }
        .padding(.top, 16)
    }
    
    private var searchMovieView: some View {
        
        
        HStack{
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.grey04)
                    
                    TextField("Search", text: $viewModel.searchText)
                        .autocorrectionDisabled() // 자동 수정 비활성화
                        .textInputAutocapitalization(.never) // 첫 글자 대문자 비활성화
                    
                    Image(systemName: "mic.fill")
                        .foregroundColor(.grey04)
                }
                .padding(.horizontal, 10)
                .frame(height: 36)
                .background(.grey01)
                .cornerRadius(10)
        
        
                
        
                
                
        
        
        
        
    }
    
    private func movieSheetView(for movies:[MovieCards]) -> some View{
 
            LazyVGrid(columns:movieGridColumns, spacing: 36){
                ForEach(movies) { movie in
                    VStack{
                        // [수정] AsyncImage로 교체
                        AsyncImage(url: movie.posterURL) { image in
                            image
                                .resizable() // 👈 기존 UI 수정자 유지
                                .frame(width: 95, height: 135) // 👈 기존 UI 수정자 유지
                        } placeholder: {
                            // 원본 프레임과 동일한 크기의 플레이스홀더
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 95, height: 135)
                        }
                        .cornerRadius(10) // 👈 플레이스홀더에도 적용하기 위해 밖으로 이동
                        .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(viewModel.selectedMovieID == movie.id ? .purple03 : Color.clear, lineWidth: 4)
                            )
                            .onTapGesture {
                                withAnimation {
                                    viewModel.selectMovie(id: movie.id)
                                }
                            }
                        
                        Text(movie.movieName)
                            .font(.semiBold14)
                            .foregroundColor(.black)
                        
                    }
                }
            }
            
        }
    
    
}
#Preview {
    MovieSheetView(viewModel: MovieBookingViewModel())
}
