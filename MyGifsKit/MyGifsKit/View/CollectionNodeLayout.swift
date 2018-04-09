//
//  CollectionNodeLayout.swift
//  MyGifsKit
//
//  Created by Aaron Rosenberger on 4/8/18.
//  Copyright © 2018 Aaron Rosenberger. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol CollectionNodeLayoutDelegate: ASCollectionDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeForNodeAtIndexPath indexPath: IndexPath) -> CGSize
}

class CollectionNodeLayout: UICollectionViewLayout {
    weak var delegate: CollectionNodeLayoutDelegate!
    
    public var numberOfColumns: Int
    fileprivate var cellPadding: CGFloat
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    fileprivate var contentHeight: CGFloat
    
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    required override init() {
        self.numberOfColumns = 2
        self.cellPadding = 10.0
        self.contentHeight = 0
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        // 2. Pre-Calculates the X Offset for every column and adds an array to increment the currently max Y Offset for each column
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        // 3. Iterates through the list of items in the first section
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            // 4. Asks the delegate for the height of the picture and the annotation and calculates the cell frame.
            let nodeHeight = delegate.collectionView(self.collectionView!, sizeForNodeAtIndexPath: indexPath).height
            let height = cellPadding * 2 + nodeHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            // 5. Creates an UICollectionViewLayoutItem with the frame and add it to the cache
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            // 6. Updates the collection view content height
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    func itemSizeAtIndexPath(indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: self.contentWidth, height: 0)
        let originalSize = self.delegate!.collectionView(self.collectionView!, sizeForNodeAtIndexPath: indexPath)
        if originalSize.height > 0 && originalSize.width > 0 {
            size.height = originalSize.height / originalSize.width * size.width
        }
        return size
    }
}

class CollectionNodeLayoutInspector: NSObject, ASCollectionViewLayoutInspecting {
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        let layout = collectionView.collectionViewLayout as! CollectionNodeLayout
        return ASSizeRangeMake(CGSize.zero, layout.itemSizeAtIndexPath(indexPath: indexPath))
    }
    
    func scrollableDirections() -> ASScrollDirection {
        return ASScrollDirectionVerticalDirections
    }
}
