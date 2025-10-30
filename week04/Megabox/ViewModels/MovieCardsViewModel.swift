import SwiftUI

import Foundation

@Observable
class MovieCardsViewModel{
    // 모델안에 모델을 넣는식
    // 
    var movieCards: [MovieCards] = []
    
    init() {
        let azzulDesc = MovieDescription(details: [])
        let guikalDesc = MovieDescription(details: [])
        let f1Desc = MovieDescription(details: [
            "최고가 되지 못한 전설 VS 최고가 싶은 루키",
            "한때 주목받는 유망주였지만 끔찍한 사고로 F1에서 우승하지 못하고",
            "한순간에 추락한 드라이버 ‘손; 헤이스'(브래드 피트).",
            "그의 오랜 동료인 ‘루벤 세르반테스'(하비에르 바르뎀)에게",
            "레이싱 복귀를 제안받으며 최하위 팀인 APXGP에 합류한다."
        ])
        let faceDesc = MovieDescription(details: [])
        let himeDesc = MovieDescription(details: [])
        let bossDesc = MovieDescription(details: [])
        let yadangDesc = MovieDescription(details: [])
        let rosesDesc = MovieDescription(details: [])
    
    

        
        let azzul = MovieCards(id: "m-001", image: Image("m-001"), booking: true, movieName: "어쩔수가없다",watchedStatus: "20만", movieNameEn: "Can't Help It", movieDescription: azzulDesc)
        let f1 = MovieCards(id: "m-002", image: Image("m-002"),booking: true,movieName: "F1 더 무비", watchedStatus: "1", movieNameEn: "F1: The Movie", movieDescription: f1Desc)
        let guikal = MovieCards(id: "m-003", image: Image("m-003"),booking: true, movieName: "극장판 귀멸의칼날",watchedStatus: "1", movieNameEn: "Demon Slayer", movieDescription: guikalDesc)
        let face = MovieCards(id: "m-004", image: Image("m-004"),booking: true, movieName: "얼굴", watchedStatus: "20만", movieNameEn: "Face", movieDescription: faceDesc)
        let hime = MovieCards(id: "m-005", image: Image("m-005"), booking: true, movieName: "모노노케히메", watchedStatus: "20만", movieNameEn: "Princess Mononoke", movieDescription: himeDesc)
        let boss = MovieCards(id:"m-006", image: Image("m-006"), booking: true, movieName: "보스", watchedStatus: "20만", movieNameEn: "The boss", movieDescription: bossDesc)
        let yadang = MovieCards(id:"m-007", image: Image("m-007"),booking: true, movieName: "야당", watchedStatus: "20만", movieNameEn: "Yadang", movieDescription: yadangDesc)
        let roses = MovieCards(id:"m-008", image: Image("m-008"), booking: true, movieName: "The Roses", watchedStatus: "20만", movieNameEn: "The roses", movieDescription: rosesDesc)
    
        self.movieCards = [azzul, guikal, f1, face, hime, boss, yadang, roses]
        
    }
    
    
    
}
