import UIKit

class ResultViewController: UIViewController {

    var winnerName: String = ""
    var winnerScore: Int = 0
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var score_LBL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setWinner()
    }
    
    func setWinner() {
        switch winnerName {
        case "PC":
            resultLabel.text = "You Lost!\nPC is the winner!"
        case "Tie":
            resultLabel.text = "It's a Tie!"
        default:
            resultLabel.text = "Winner is:\n\(winnerName)"
        }
        score_LBL.text = "Score: \(winnerScore)"
    }
}
