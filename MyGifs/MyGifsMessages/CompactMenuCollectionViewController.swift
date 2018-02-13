//
//  CompactMenuCollectionViewController.swift
//  MyGifsMessages
//
//  Created by Aaron Rosenberger on 2/11/18.
//  Copyright © 2018 Aaron Rosenberger. All rights reserved.
//

import UIKit

protocol CompactMenuDelegate: class {
    func didTap(_ menuItem: MenuItem)
}

enum MenuItem: String {
    case Imgur = "Imgur"
    case Gfycat = "Gfycat"
    case Settings = "Settings"
}

class CompactMenuCollectionViewController: UICollectionViewController {
    
    var items: [MenuItem] = []
    weak var delegate: CompactMenuDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        self.collectionView!.register(CompactMenuItemCollectionViewCell.self, forCellWithReuseIdentifier: CompactMenuItemCollectionViewCell.reuseIdentifier)

        // Do any additional setup after loading the view.
        items.append(.Gfycat)
        items.append(.Imgur)
        items.append(.Settings)
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CompactMenuItemCollectionViewCell.reuseIdentifier, for: indexPath) as? CompactMenuItemCollectionViewCell else { return UICollectionViewCell() }
        let index = indexPath.row
        
        if let parentFrame = self.collectionView?.frame {
            let numItems = self.collectionView?.numberOfItems(inSection: 0) ?? 2
            let width = Int(parentFrame.width) / numItems
            cell.frame = CGRect(x: index * width, y: 0, width: width, height: Int(parentFrame.height))
        }
        
        // Configure the cell
        cell.menuItem = items[index]
        cell.label = UILabel()
        cell.label.attributedText = NSAttributedString(string: items[index].rawValue)
        cell.label.adjustsFontSizeToFitWidth = true
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard delegate != nil else { return }
        if let cell = self.collectionView?.cellForItem(at: indexPath) as? CompactMenuItemCollectionViewCell {
            delegate!.didTap(cell.menuItem)
        }
    }

}
