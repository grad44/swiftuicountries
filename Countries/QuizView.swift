import Foundation
import SwiftUI

struct QuizView: View {
    @ObservedObject var quizModel = QuizViewModel()
    
    var body: some View {
        VStack {
            if (!quizModel.hasStarted) {
                Text("Ready to guess 5 flags?")
                    .font(.title)
                Button("Start", action: {
                    Task {
                        await quizModel.start()
                    }
                })
            } else {
                if quizModel.isLoading {
                    ProgressView()
                } else if !quizModel.hasFinished {
                    VStack {
                        if let url = URL(string: quizModel.currentQuestion.imageUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .scaledToFit()
                            .frame(width: 200)
                            .padding([.bottom], 20)
                        }
                        Text("That is the flag of which country?")
                            .font(.title2)
                            .padding(.bottom, 20)
                        
                        VStack {
                            ForEach(0..<4, id: \.self) { index in
                                Button(action: {
                                    quizModel.guess(idx: index)
                                }) {
                                    let bgColor = getCorrectBgColor(showResult: quizModel.showSingleQuestionResult, correctIdx: quizModel.currentQuestion.correctChoice, buttonIdx: index)
                                    Text(quizModel.currentQuestion.choices[index])
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(bgColor)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                        .padding(.bottom, 5)
                                }
                            }
                        }
                        
                        if quizModel.showSingleQuestionResult {
                            Button("Next question") {
                                quizModel.nextQuestion()
                            }
                        }
                    }
                } else {
                    VStack {
                        Text("You got \(quizModel.correctAnswers) out of \(quizModel.numberOfQuestions) right!")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.bottom, 20)
                        Button("Restart") {
                            quizModel.restart()
                        }
                    }
                }
            }
        }
    }
}

class QuizViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasStarted = false
    @Published var questions: [CountryQuizQuestion] = []
    private var allCountries: [Country] = []
    private var apiService = ApiService()
    @Published var currentQuestionIdx = 0
    @Published var showSingleQuestionResult = false
    @Published var hasFinished = false
    @Published var correctAnswers = 0
    @Published var numberOfQuestions = 5
    var currentQuestion: CountryQuizQuestion {
        get {
            return questions[currentQuestionIdx]
        }
    }
    
    @MainActor
    func start() async {
        hasStarted = true
        isLoading = true
        do {
            if allCountries.isEmpty {
                allCountries = try await loadCountries()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        questions = createNRandomQuestion(countries: allCountries, n: numberOfQuestions)
        isLoading = false
    }
    
    func guess(idx: Int) {
        if (idx == currentQuestion.correctChoice && !showSingleQuestionResult) {
            correctAnswers += 1
        }
        showSingleQuestionResult = true
    }
    
    func nextQuestion() {
        showSingleQuestionResult = false
        if currentQuestionIdx + 1 < numberOfQuestions {
            currentQuestionIdx += 1
        } else {
            hasFinished = true
        }
    }
    
    @MainActor
    func loadCountries() async throws -> [Country] {
        let countries = try await apiService.fetchCountriesAsync()
        return countries
    }
    
    func restart() {
        hasFinished = false
        hasStarted = false
        correctAnswers = 0
        currentQuestionIdx = 0
    }
}
