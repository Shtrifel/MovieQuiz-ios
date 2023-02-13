//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Иван Иванов on 13.02.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func setEnabledButtons(isEnabled: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
} 
