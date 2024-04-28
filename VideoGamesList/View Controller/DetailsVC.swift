//
//  DetailsVC.swift
//  VideoGamesList
//
//  Created by Umut on 24.04.2024.
//

import UIKit
import CoreData

class DetailsVC: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var releasedLabel: UILabel!
    @IBOutlet weak var metacriticLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var gameDetailsImage: UIImageView!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var navigator: UINavigationItem!
    
    static var id = " "
    static var selectedGame = [Game]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateFavoriteButtonAppearance()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData(gameId: DetailsVC.id)

    }
        
    @IBAction func favBtnClicked(_ sender: Any) {
        // AppDelegate'e erişim
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext

        // Seçilen oyunun Core Data'da daha önce kaydedilip kaydedilmediğini kontrol et
        let gameId = Int32(DetailsVC.id)!
        let fetchRequest: NSFetchRequest<GameEntity> = GameEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", NSNumber(value: gameId))

        do {
            let existingGames = try context.fetch(fetchRequest)
            if existingGames.isEmpty {
                // Oyun verisini oluştur
                let selectedGame = DetailsVC.selectedGame[0]
                let gameEntity = GameEntity(context: context)
                gameEntity.id = Int32(selectedGame.id)
                gameEntity.name = selectedGame.name
                gameEntity.released = selectedGame.released
                gameEntity.rating = selectedGame.rating
                gameEntity.background_image = selectedGame.background_image

                // Veriyi kaydet
                try context.save()
                print("Game data saved successfully.")
            } else {
                // Veri zaten kayıtlı, bu yüzden sil
                context.delete(existingGames.first!)
                try context.save()
                print("Selected game is removed from Core Data.")
            }
            
            // Favori butonunun görünümünü güncelle
            updateFavoriteButtonAppearance()

        } catch {
            print("Error fetching existing games: \(error.localizedDescription)")
        }
    }

    // Favori butonunun görünümünü güncellemek için yardımcı fonksiyon
    func updateFavoriteButtonAppearance() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        let gameId = Int32(DetailsVC.id)!
        let fetchRequest: NSFetchRequest<GameEntity> = GameEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", NSNumber(value: gameId))
        
        do {
            let existingGames = try context.fetch(fetchRequest)
            if existingGames.isEmpty {
                favBtn.setImage(UIImage(systemName: "heart"), for: .normal)
            } else {
                favBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }
        } catch {
            print("Error fetching existing games: \(error.localizedDescription)")
        }
    }


    func getData(gameId : String){
        let urlStr = "https://api.rawg.io/api/games/\(gameId)?key=095b135847544fb481fa5083f7858961"
        guard let gameURL = URL(string: urlStr) else { return }
        
        let session = URLSession.shared
        let task = session.dataTask(with: gameURL) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching game details: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received for game details")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let gameDetails = try decoder.decode(GameDetails.self, from: data)
                
                DispatchQueue.main.async {
                    self.updateUI(with: gameDetails)
                }
            } catch {
                print("Error decoding game details: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    func updateUI(with gameDetails: GameDetails) {
        nameLabel.text = gameDetails.name
        releasedLabel.text = gameDetails.released
        metacriticLabel.text = "Rating: \(String(gameDetails.metacritic)) / 100"
        ratingLabel.text = "Metacritic: \(String(gameDetails.rating)) / 5"
        descriptionText.text = gameDetails.description_raw
        
        if let imageUrl = URL(string: gameDetails.background_image) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: imageUrl),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.gameDetailsImage.image = image
                    }
                }
            }
        }
        
        DetailsVC.selectedGame.insert(Game(id: Int(DetailsVC.id)!, name: gameDetails.name, released: gameDetails.released, rating: gameDetails.rating, background_image: gameDetails.background_image), at: 0)
    }
}
