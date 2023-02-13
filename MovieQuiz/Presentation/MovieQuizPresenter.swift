//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Иван Иванов on 13.02.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticService!
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = 0
    
    init(viewController: MovieQuizViewController) {
         self.viewController = viewController
        
         statisticService = StatisticServiceImplementation()
         questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
         questionFactory?.loadData()
         viewController.showLoadingIndicator()
     }
     
     // MARK: - QuestionFactoryDelegate
     
     func didLoadDataFromServer() {
         viewController?.hideLoadingIndicator()
         questionFactory?.requestNextQuestion()
     }
     
     func didFailToLoadData(with error: Error) {
         let message = error.localizedDescription
         viewController?.showNetworkError(message: message)
     }
     
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)" // ОШИБКА: `currentQuestionIndex` и `questionsAmount` неопределены
        )
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let bestGameRes = "\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)"
            let text = """
            Ваш результат: \(correctAnswers) из \(questionsAmount)
            Количество сыгранных квизов:\(statisticService.gamesCount)
            Рекорд: \(bestGameRes) (\(statisticService.bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy) + "%")
            """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            viewController?.setEnabledButtons(isEnabled: true)
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if (isCorrectAnswer) {
            correctAnswers += 1 }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
