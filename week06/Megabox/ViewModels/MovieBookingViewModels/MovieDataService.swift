import Foundation
import SwiftUI
enum MovieLoadError: Error, LocalizedError{
    
     case invalidData
     case decodingFailed(Error)
     case networkFailed(Error)
     case fileNotFound
    
    
}
class MovieDataService {
    
 
    func loadDataFromJSON() throws -> (movies: [MovieCards], dtos: [MovieDTO]) {
        
        var allLoadedMovies: [MovieCards] = []
        var allLoadedDTOs: [MovieDTO] = []
        
        // JSON 데이터 로드 및 디코딩
        if let url = Bundle.main.url(forResource: "MovieSchedule", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            
            do {
                let response = try JSONDecoder().decode(APIResponseDTO.self, from: data)
                allLoadedDTOs = response.data.movies // DTO 저장
                
                let jsonMovies = allLoadedDTOs.map { $0.toDomainCard() }
                allLoadedMovies.append(contentsOf: jsonMovies)
                
            } catch {
                throw MovieLoadError.decodingFailed(error)
            }
        } else {
            throw MovieLoadError.fileNotFound
        }
  
        // JSON파일에는 없는 데이터 추가
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
     
        allLoadedMovies.append(contentsOf: [face, hime, boss, yadang, roses])
        
        return (movies: allLoadedMovies, dtos: allLoadedDTOs)
    }
}
