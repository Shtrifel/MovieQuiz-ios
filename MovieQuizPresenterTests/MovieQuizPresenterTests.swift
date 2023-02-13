//
//  MovieQuizPresenterTests.swift
//  MovieQuizPresenterTests
//
//  Created by Иван Иванов on 13.02.2023.
//

import XCTest
@testable import MovieQuiz

class MovieQuizViewControllerMock: MovieQuizViewController {// через протокол не присваивалась переменная sut, добавил прямое наследование
    
    override func show(quiz step: QuizStepViewModel) {
    
    }
    
    override func show(quiz result: QuizResultsViewModel) {
    
    }
    
    override func highlightImageBorder(isCorrectAnswer: Bool) {
    
    }
    
    override func setEnabledButtons(isEnabled: Bool) {
        
    }
    
    override func showLoadingIndicator() {
    
    }
    
    override func hideLoadingIndicator() {
    
    }
    
    override func showNetworkError(message: String) {
    
    }
}

class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter (viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
