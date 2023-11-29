import Foundation
import SwiftUI

struct CountryQuiz {
    let questions: [CountryQuizQuestion]
    let correctAnswers = 0
}

struct CountryQuizQuestion {
    let imageUrl: String
    let choices: [String]
    let correctChoice: Int
}

func createNRandomQuestion(countries: [Country], n: Int) -> [CountryQuizQuestion] {
        let selectedCorrectCountries = countries.shuffled().prefix(n)
        var quizQuestions: [CountryQuizQuestion] = []
        
        for countryToGuess in selectedCorrectCountries {
            let options = countries.filter { $0.id != countryToGuess.id }.shuffled()
            let incorrectOptions = options.prefix(3).map { $0.names.common }
            
            let correctAnswerIndex = Int.random(in: 0..<4)
            
            var choices = Array(incorrectOptions)
            choices.insert(countryToGuess.names.common, at: correctAnswerIndex)
            
            quizQuestions.append(CountryQuizQuestion(
                imageUrl: countryToGuess.flag.png,
                choices: choices,
                correctChoice: correctAnswerIndex
            ))
        }
        
        return quizQuestions
}

func getCorrectBgColor(showResult: Bool, correctIdx: Int, buttonIdx: Int) -> Color {
    var bgColor = Color.blue
    if showResult {
        bgColor = correctIdx == buttonIdx ? Color.green : Color.red
    }
    return bgColor
}
