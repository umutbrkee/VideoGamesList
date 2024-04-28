//
//  HomeVC.swift
//  VideoGamesList
//
//  Created by Umut on 24.04.2024.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var bottomCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var navigator: UINavigationItem!
    
    var topGames = [Game]()
    var games = [Game]()
    var filteredGames = [Game]()
    var isFiltering: Bool = false
    
    var scrollWidth = CGFloat()
    var scrollHeight = CGFloat()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
                await fetchData()
            }
    }
    
    override func viewDidLayoutSubviews() {
        scrollWidth = topCollectionView.frame.size.width
        scrollHeight = topCollectionView.frame.size.height
    }
    
    func fetchData() async {
        let urlString = "https://api.rawg.io/api/games?key=095b135847544fb481fa5083f7858961"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            DispatchQueue.main.async {
                self.parse(json: data)
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    @IBAction func pageChanged(_ sender: Any) {
        topCollectionView.scrollRectToVisible(CGRect(x: scrollWidth * CGFloat ((pageControl?.currentPage)!), y: 0, width: scrollWidth, height: scrollHeight), animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        if let jsonGames = try? decoder.decode(Games.self, from: json) {
            games += jsonGames.results
            for i in 0..<3 {
                topGames.append(jsonGames.results[i])
                games.removeAll(where: {$0 == topGames[i]})
            }
            bottomCollectionView.reloadData()
            topCollectionView.reloadData()
        }
    }
}

extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == topCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topGameCell", for: indexPath as IndexPath) as! TopGameCell
            let topGame = topGames[indexPath.row]
            cell.configure(model: topGame)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gameCell", for: indexPath as IndexPath) as! GameCell
            let game: Game
            if isFiltering {
                if indexPath.row < filteredGames.count {
                    game = filteredGames[indexPath.row]
                } else {
                    return cell // Bu durumda geçici bir hücre döndür
                }
            } else {
                game = games[indexPath.row]
            }
            cell.configure(model: game)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topCollectionView {
            return topGames.count
        } else {
            if isFiltering {
                return filteredGames.count
            }
            return games.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if collectionView == topCollectionView {
            if let selectedItem = collectionView.cellForItem(at: indexPath) as? TopGameCell {
                DetailsVC.id = selectedItem.id
            }
        } else {
            if let selectedItem = collectionView.cellForItem(at: indexPath) as? GameCell {
                DetailsVC.id = selectedItem.id
            }
        }
    }
}

extension HomeVC : UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = (topCollectionView.contentOffset.x)/scrollWidth
        pageControl.currentPage = Int(page)
    }
}

extension HomeVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 3 {
            filteredGames = games.filter({ (game:Game) -> Bool in
                return game.name.lowercased().contains(searchText.lowercased())
            })
            if filteredGames.count == 0 {
                showNoGamesFoundMessage()
                topConstraint.constant = 20
                topCollectionView.isHidden = true
                bottomCollectionView.isHidden = true
                isFiltering = true
                pageControl.isHidden = true
            } else {
                hideNoGamesFoundMessage()
                topConstraint.constant = 20
                topCollectionView.isHidden = true
                bottomCollectionView.isHidden = false
                isFiltering = true
                pageControl.isHidden = true
                bottomCollectionView.reloadData()
            }
        } else if searchText.isEmpty {
            hideNoGamesFoundMessage()
            topConstraint.constant = 266
            isFiltering = false
            topCollectionView.isHidden = false
            bottomCollectionView.isHidden = false
            pageControl.isHidden = false
            bottomCollectionView.reloadData()
        }
        
    }
    
    func showNoGamesFoundMessage() {
        // "Oyun bulunamadı" mesajını içeren bir label oluştur
        let messageLabel = UILabel()
        messageLabel.text = "Oyun bulunamadı"
        messageLabel.textAlignment = .center
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.sizeToFit()
        
        // Label'ı ekranın ortasına yerleştir
        messageLabel.center = view.center
        
        // Label'ı ana view'e ekle
        view.addSubview(messageLabel)
    }
    
    func hideNoGamesFoundMessage() {
        for subview in view.subviews {
            if let messageLabel = subview as? UILabel, messageLabel.text == "Oyun bulunamadı" {
                messageLabel.removeFromSuperview()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Arama iptal edildiğinde, HomeVC'yi yeniden yükle
        searchBar.text = ""
        searchBar.resignFirstResponder() // Klavyeyi gizle
        isFiltering = false
        topConstraint.constant = 266
        topCollectionView.isHidden = false
        bottomCollectionView.isHidden = false
        pageControl.isHidden = false
        bottomCollectionView.reloadData()
        
        // Arama iptal edildiğinde, "Oyun bulunamadı" mesajını gizle
        hideNoGamesFoundMessage()
    }
}
