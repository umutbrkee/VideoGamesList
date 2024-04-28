//
//  TopGameCell.swift
//  VideoGamesList
//
//  Created by Umut on 24.04.2024.
//

import UIKit

class TopGameCell: UICollectionViewCell {
    @IBOutlet weak var topImageView: UIImageView!
    
    var id = ""
    var currentPage = 0
    override func awakeFromNib() {
      super.awakeFromNib()

    }
    
    func configure(model: Game) {
        self.id = String(model.id)
        
        let gameImageUrl = model.background_image
        if let imageUrl = URL(string: gameImageUrl) {
            let session = URLSession.shared
            let task = session.dataTask(with: imageUrl) { [weak self] (data, response, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    print("Invalid image data")
                    return
                }
                
                DispatchQueue.main.async {
                    self.topImageView.image = image
                }
            }
            
            task.resume()
        }
    }
}
