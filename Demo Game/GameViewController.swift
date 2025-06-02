import UIKit

enum Suit: String, CaseIterable {
    case hearts, diamonds, clubs, spades
}

struct Card {
    let suit: Suit
    let value: Int
    var imageName: String {
        return "\(suit.rawValue)_\(value)"
    }
}

struct GameResult {
    let winnerName: String
    let score: Int
}

class GameViewController: UIViewController {

    var playerName: String = ""
    var userIsLeftSide: Bool = false

    let ROUNDS = 5
    let ROUND_WINNER_TIME: TimeInterval = 2.0
    let COUNTDOWN_TIME = 3
    var countdownValue = 3
    var countdownTimer: Timer?
    var countdownIsRunning = false

    var currentRound = 0
    var player1Score = 0
    var player2Score = 0

    var playerDeck: [Card] = []
    var botDeck: [Card] = []

    var roundTransitionTimer: Timer?
    var roundTransitionRemainingTime: TimeInterval?

    @IBOutlet weak var player1Label: UILabel!
    @IBOutlet weak var player2Label: UILabel!
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var playerCardImageView: UIImageView!
    @IBOutlet weak var botCardImageView: UIImageView!
    @IBOutlet weak var roundResultLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        playerName = readPlayerName()
        prepareDecks()
        updateScoreLabels()
        SoundManager.instance.playBackgroundMusic()
        playNextRound()

        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsUpdateOfSupportedInterfaceOrientations()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    func readPlayerName() -> String {
        return UserDefaults.standard.string(forKey: MenuViewController.usernameKey) ?? "Player"
    }

    func generateFullDeck() -> [Card] {
        var deck: [Card] = []
        for suit in Suit.allCases {
            for value in 1...13 {
                deck.append(Card(suit: suit, value: value))
            }
        }
        return deck.shuffled()
    }

    func prepareDecks() {
        let deck = generateFullDeck()
        playerDeck = Array(deck.prefix(ROUNDS))
        botDeck = Array(deck.dropFirst(ROUNDS).prefix(ROUNDS))
    }

    func updateScoreLabels() {
        if userIsLeftSide {
            player1Label.text = "\(playerName): \(player1Score)"
            player2Label.text = "PC: \(player2Score)"
        } else {
            player1Label.text = "PC: \(player1Score)"
            player2Label.text = "\(playerName): \(player2Score)"
        }
        roundLabel.text = "\(currentRound + 1) / \(ROUNDS)"
    }

    func playNextRound() {
        guard currentRound < ROUNDS else {
            finishGame()
            return
        }

        countdownValue = COUNTDOWN_TIME
        roundResultLabel.text = ""
        updateScoreLabels()
        playerCardImageView.image = UIImage(named: userIsLeftSide ? "blue_back" : "red_back")
        botCardImageView.image = UIImage(named: userIsLeftSide ? "red_back" : "blue_back")
        countdownLabel.text = "\(countdownValue)"
        startCountdown()
    }

    func startCountdown() {
        countdownIsRunning = true
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }

    @objc func updateCountdown() {
        countdownValue -= 1
        if countdownValue > 0 {
            countdownLabel.text = "\(countdownValue)"
        } else {
            countdownTimer?.invalidate()
            countdownTimer = nil
            countdownIsRunning = false
            countdownLabel.text = "GO!"
            flipCardsAndEvaluate()
        }
    }

    func flipCardsAndEvaluate() {
        let playerCard = playerDeck[currentRound]
        let botCard = botDeck[currentRound]

        let leftImage = userIsLeftSide ? playerCard.imageName : botCard.imageName
        let rightImage = userIsLeftSide ? botCard.imageName : playerCard.imageName

        let leftCardImage = UIImage(named: leftImage)
        let rightCardImage = UIImage(named: rightImage)

        let flipDuration: TimeInterval = 0.5

        SoundManager.instance.playFlipSound()

        flipCard(imageView: playerCardImageView, to: leftCardImage, duration: flipDuration, flipFromLeft: true)
        flipCard(imageView: botCardImageView, to: rightCardImage, duration: flipDuration, flipFromLeft: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + flipDuration + 0.5) {
            let resultText: String

            if playerCard.value > botCard.value {
                if self.userIsLeftSide {
                    self.player1Score += 1
                } else {
                    self.player2Score += 1
                }
                resultText = "\(self.playerName) wins the round!"
                SoundManager.instance.playWinSound()
            } else if botCard.value > playerCard.value {
                if self.userIsLeftSide {
                    self.player2Score += 1
                } else {
                    self.player1Score += 1
                }
                resultText = "PC wins the round!"
                SoundManager.instance.playLostSound()
            } else {
                resultText = "It's a tie!"
                SoundManager.instance.playTieSound()
            }

            self.roundResultLabel.text = resultText
            self.currentRound += 1

            self.roundTransitionRemainingTime = self.ROUND_WINNER_TIME
            self.roundTransitionTimer = Timer.scheduledTimer(withTimeInterval: self.ROUND_WINNER_TIME, repeats: false) { _ in
                self.roundTransitionTimer = nil
                self.roundTransitionRemainingTime = nil
                self.playNextRound()
            }
        }
    }

    func flipCard(imageView: UIImageView,
                  to image: UIImage?,
                  duration: TimeInterval = 0.5,
                  flipFromLeft: Bool = true) {
        UIView.transition(with: imageView,
                          duration: duration,
                          options: flipFromLeft ? .transitionFlipFromLeft : .transitionFlipFromRight,
                          animations: {
            imageView.image = image
        })
    }

    func finishGame() {
        SoundManager.instance.stopBackgroundMusic()

        let winnerName: String
        let winnerScore: Int
        if player1Score > player2Score {
            winnerName = userIsLeftSide ? playerName : "PC"
            winnerScore = player1Score
        } else if player2Score > player1Score {
            winnerName = userIsLeftSide ? "PC" : playerName
            winnerScore = player2Score
        } else {
            winnerName = "Tie"
            winnerScore = player1Score
        }
        goToResult(winner: winnerName, winnerScore: winnerScore)
    }

    func goToResult(winner: String, winnerScore: Int) {
        let result = GameResult(winnerName: winner, score: winnerScore)
        performSegue(withIdentifier: "toResult", sender: result)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResult",
           let resultVC = segue.destination as? ResultViewController,
           let result = sender as? GameResult {
            resultVC.winnerName = result.winnerName
            resultVC.winnerScore = result.score
        }
    }

    @objc func appWillResignActive() {
        if countdownIsRunning {
            countdownTimer?.invalidate()
            countdownTimer = nil
            countdownIsRunning = false
        }

        if let timer = roundTransitionTimer, let remaining = roundTransitionRemainingTime {
            timer.invalidate()
            let fireDate = Date().addingTimeInterval(remaining)
            roundTransitionRemainingTime = fireDate.timeIntervalSinceNow
            roundTransitionTimer = nil
        }

        SoundManager.instance.pauseAllSounds()
    }

    @objc func appDidBecomeActive() {
        if countdownValue > 0 && !countdownIsRunning {
            countdownLabel.text = "\(countdownValue)"
            startCountdown()
        }

        if let remaining = roundTransitionRemainingTime {
            roundTransitionTimer = Timer.scheduledTimer(withTimeInterval: remaining, repeats: false) { _ in
                self.roundTransitionTimer = nil
                self.roundTransitionRemainingTime = nil
                self.playNextRound()
            }
        }

        SoundManager.instance.playBackgroundMusic()
    }
}
