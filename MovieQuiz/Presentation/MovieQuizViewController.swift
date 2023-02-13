import UIKit

class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol, AlertPresenterDelegate {
    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(delegate: self)
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
    }
    
    func show(quiz step: QuizStepViewModel) {
        self.imageView.layer.borderColor = UIColor.ypBlack.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        // здесь мы заполняем нашу картинку, текст и счётчик данными
    }

    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title, text: result.text, buttonText: result.buttonText, completion: { [weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
            self.setEnabledButtons(isEnabled: true)
            
        })
        self.alertPresenter?.showAlert(model: alertModel)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        setEnabledButtons(isEnabled: false)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    func setEnabledButtons(isEnabled: Bool)  {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true // говорим, что индикатор загрузки не скрыт
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               text: message,
                               buttonText: "Попробовать еще раз",
                               completion:{ [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            self.presenter.questionFactory?.loadData()//при нажатии на "Попробовать еще раз" запускается загрузка данных
        })
        self.alertPresenter?.showAlert(model: model)
    }
}
