import UIKit
import Kingfisher

class GameCell: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var releasedLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var gameImage: UIImageView!
    
    var id = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    override var isSelected: Bool {
       didSet{
           if self.isSelected {
               UIView.animate(withDuration: 0.3) {
                   self.backgroundColor = UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 0.5)
               }
           } else {
               UIView.animate(withDuration: 0.3) {
                    self.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
               }
           }
       }
   }
    
    func configure(model: Game) {
        self.nameLabel.text = model.name
        self.releasedLabel.text = model.released
        self.ratingLabel.text = String(model.rating)
        self.id = String(model.id)
        
        // Set placeholder image
        self.gameImage.image = UIImage(named: "placeholderImage")
        
        // Load image with Kingfisher
        if let imageUrl = URL(string: model.background_image) {
            self.gameImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholderImage"))
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset the image when the cell is reused
        self.gameImage.image = UIImage(named: "placeholderImage")
    }
}
