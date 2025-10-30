import SwiftUI

struct MovieDetailView: View {
    
    
    @State private var selectedInfo: InfoType = .details
    @Environment(\.dismiss) private var dismiss
    
    let movie: MovieCards
   
    var body: some View {
        
        ScrollView{
            VStack(spacing:0){
                
                toolbar
                
                movieDescription
                    
                infoSelectionSection
                    .padding(.top, 24) // 위쪽 여백
                
                if selectedInfo == .details{
                    detailsView
                        .padding(.horizontal)
                        
                }else{
                    reviewsView
                        
                }
                
                
                
                
                
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden(true)
        
    }
    
    
    
    private var toolbar: some View {
        ZStack {
         
            Text(movie.movieName)
                .font(.semiBold18)
                .foregroundColor(.black)

            
            HStack {
                Button(action: {
                    
                    dismiss()
                }) {
                    Image(systemName: "arrow.backward")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                
            
             Spacer()
            }
            .padding(.horizontal)
            
        }
        .padding()
        .frame(height: 44)
        .background(Color.white)
    }
    private var movieDescription: some View{
        
        VStack{
            
            Image("sony")
                .resizable()
                .frame(width: 441, height: 248)
            
            Text(movie.movieName)
                .font(.bold24)
                .foregroundColor(.black)
            Text(movie.movieNameEn)
                .font(.semiBold14)
                .foregroundColor(.grey03)
            Group{
                ForEach(movie.movieDescription.details, id: \.self) { detailLine in
                    text(text: detailLine)
                }
               
            }
            .padding(.horizontal)
        }
        
        
        
    }

    private var infoSelectionSection: some View {
        HStack {
            InfoButton(title: "상세 정보", type: .details, selectedInfo: $selectedInfo)
            InfoButton(title: "실관람평", type: .reviews, selectedInfo: $selectedInfo)
        }
        .padding(.horizontal)
        .background(Color.white)
    }
    
    
    private var detailsView: some View {
        HStack(alignment:.top, spacing: 16) {
            movie.image// 상세 정보 포스터 이미지 이름
                .resizable()
                .frame(width: 100, height: 120)
                
            VStack(alignment: .leading, spacing: 8) {
                Text("12세 이상 관람가")
                    .font(.footnote)
                Text("2025.06.25 개봉")
                    .font(.footnote)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }

    private var reviewsView: some View {
        VStack {
            Text("등록된 관람평이 없어요 🤔")
                .font(.headline)
                .foregroundColor(.black)
                
        }
        .frame(width: 380, height: 141)
        .background(Color.white)
        .overlay(
            // 모서리 둥글기(cornerRadius)가 15인 사각형을 만듭니다.
            RoundedRectangle(cornerRadius: 10)
            // 해당 사각형의 외곽선(stroke)을 그립니다.
                .stroke(.purple02, lineWidth: 1)
        )
    }
    
    
    
    private func text(text: String) -> some View{
        
        Text(text)
            .font(.semiBold16)
            .foregroundColor(.grey03)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        
        
    }
    
    
}

