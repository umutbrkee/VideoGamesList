//
//  FavoritesVC.swift
//  VideoGamesList
//
//  Created by Umut on 26.04.2024.
//

import UIKit
import CoreData

class FavoritesVC: UIViewController {
    
    @IBOutlet weak var favoritesCollectionView: UICollectionView!
    @IBOutlet weak var navigator: UINavigationItem!
    
    // GameEntity türünden favori oyunları saklamak için kullanacağımız bir dizi
    var favGames = [GameEntity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Arka plan görünümünü ayarla
        setupBackgroundView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Core Data'dan favori oyunları yükle
        loadFavoriteGames()
        
        // Koleksiyon görünümünü yenile
        self.favoritesCollectionView.reloadData()
        
        // Favori oyunlar listesi boşsa arka plan görünümünü göster, değilse gizle
        favoritesCollectionView.backgroundView?.isHidden = !favGames.isEmpty
    }
    
    // Core Data'dan favori oyunları yükleyen fonksiyon
    func loadFavoriteGames() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            // GameEntity türünden favori oyunları yükle
            favGames = try context.fetch(GameEntity.fetchRequest())
        } catch {
            print("Error fetching favorite games: \(error.localizedDescription)")
        }
    }
    
    // Arka plan görünümünü ayarlayan fonksiyon
    func setupBackgroundView() {
        // Blurlu arka plan eklemek için bir blur efekti oluştur
        let blurEffect = UIBlurEffect(style: .regular)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = view.bounds
        
        // "Favorilere henüz oyun eklenmedi" yazısını eklemek için bir label oluştur
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        messageLabel.center = view.center
        messageLabel.textAlignment = .center
        messageLabel.text = "Favorilere henüz oyun eklenmedi"
        messageLabel.textColor = UIColor.white
        messageLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        messageLabel.numberOfLines = 0
        
        // Blurlu arka plan görünümüne ve mesaj label'ına ekleyerek arka plan görünümünü ayarla
        blurredEffectView.contentView.addSubview(messageLabel)
        favoritesCollectionView.backgroundView = blurredEffectView
        favoritesCollectionView.backgroundView?.isHidden = true
    }
}

extension FavoritesVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoritesCell", for: indexPath) as! FavoritesCell
        cell.configure(model: favGames[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favGames.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let selectedItem = collectionView.cellForItem(at: indexPath) as! FavoritesCell
        DetailsVC.id = selectedItem.id
        
        
    }
}

