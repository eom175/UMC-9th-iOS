import SwiftUI

struct MovieCardView: View {
    
    let movie: MovieCards // 이제 'movie.posterURL'을 사용합니다.
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // 1. 영화 포스터 이미지 (AsyncImage로 수정)
            AsyncImage(url: movie.posterURL) { image in
                // 로드 성공 시
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill) // 원본 비율 유지하며 프레임 채우기
                
            } placeholder: {
                // 로드 중이거나 URL이 nil일 때
                ZStack {
                    Color.gray.opacity(0.1) // 배경색
                    Image(systemName: "film") // 기본 아이콘
                        .font(.largeTitle)
                        .foregroundStyle(.gray.opacity(0.5))
                }
            }
            .frame(width: 148, height: 212) // 프레임 고정
            .clipShape(RoundedRectangle(cornerRadius: 8)) // 모서리 살짝 둥글게
            .overlay(
                RoundedRectangle(cornerRadius: 8) // 테두리 추가
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )

            // 2. 예매 버튼
            bookingButton
                
            // 3. 영화 정보 텍스트
            VStack(alignment: .leading, spacing: 2) {
                Text(movie.movieName)
                    .font(.bold22)
                    .foregroundColor(.black)
                    .lineLimit(1) // 한 줄로 제한
                
                Text("누적관객수 \(movie.watchedStatus)")
                    .font(.medium18)
                    .foregroundColor(.black)
            }
        }
        .frame(width: 148, height:318) // 카드 전체의 너비 고정
    }
    
    // 예매 버튼 UI
    private var bookingButton: some View {
        Button(action: {
            print("\(movie.movieName) 예매하기")
        }) {
            Text("바로 예매")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(.purple03)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.purple03).opacity(0.5), lineWidth: 1)
                )
        }
    }
}
