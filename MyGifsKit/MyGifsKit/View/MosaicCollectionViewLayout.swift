//
//  MosaicCollectionViewLayout
//  Sample
//
//  Copyright (c) 2014-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree. An additional grant
//  of patent rights can be found in the PATENTS file in the same directory.
//  Modifications to this file made after 4/13/2017 are: Copyright (c) 2017-present,
//  Pinterest, Inc.  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import UIKit
import AsyncDisplayKit

protocol MosaicCollectionViewLayoutDelegate: ASCollectionDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, originalItemSizeAt indexPath: IndexPath) -> CGSize
}

class MosaicCollectionViewLayout: UICollectionViewFlowLayout {
    var numberOfColumns: Int
    private var columnSpacing: CGFloat
    private var interItemSpacing: UIEdgeInsets
    private var columnHeights: [CGFloat] = []
    private var allAttributes = [UICollectionViewLayoutAttributes]()
    
    required override init() {
        self.numberOfColumns = 2
        self.columnSpacing = 10.0
        self.interItemSpacing = UIEdgeInsetsMake(10.0, 0, 10.0, 0)
        super.init()
        self.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
        self.scrollDirection = .vertical
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var delegate: MosaicCollectionViewLayoutDelegate?
    
    override func prepare() {
        super.prepare()
        guard let collectionView = self.collectionView else { return }
        guard collectionView.numberOfSections > 0 else { return }
        
        allAttributes = []
        columnHeights = []
        var top: CGFloat = self.sectionInset.top
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        for _ in 0 ..< self.numberOfColumns {
            self.columnHeights.append(top)
        }
        
        let columnWidth = self.columnWidth()
        for idx in 0 ..< numberOfItems {
            let columnIndex: Int = self.shortestColumnIndex()
            let indexPath = IndexPath(item: idx, section: 0)
            
            let itemSize = self.itemSizeAtIndexPath(indexPath: indexPath)
            let xOffset = sectionInset.left + (columnWidth + columnSpacing) * CGFloat(columnIndex)
            let yOffset = columnHeights[columnIndex]
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height)
            
            columnHeights[columnIndex] = attributes.frame.maxY + interItemSpacing.bottom
            
            allAttributes.append(attributes)
        }
        
        let columnIndex: Int = self.tallestColumnIndex()
        top = columnHeights[columnIndex] - interItemSpacing.bottom + sectionInset.bottom
        
        for idx in 0 ..< columnHeights.count {
            columnHeights[idx] = top
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var includedAttributes: [UICollectionViewLayoutAttributes] = []
        // Slow search for small batches
        for attribute in allAttributes {
            if (attribute.frame.intersects(rect)) {
                includedAttributes.append(attribute)
            }
        }
        return includedAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item < allAttributes.count else { return nil }
        return allAttributes[indexPath.item]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if (!(self.collectionView?.bounds.size.equalTo(newBounds.size))!) {
            return true
        }
        return false
    }
    
    func itemSizeAtIndexPath(indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: self.columnWidth(), height: 0)
        let originalSize = self.delegate!.collectionView(self.collectionView!, layout: self, originalItemSizeAt: indexPath)
        if originalSize.height > 0 && originalSize.width > 0 {
            size.height = originalSize.height / originalSize.width * size.width
        }
        return size
    }
    
    override var collectionViewContentSize: CGSize {
        var height: CGFloat = 0
        if columnHeights.count > 0 {
            height = columnHeights[0]
        }
        return CGSize(width: self.collectionView!.bounds.size.width, height: height)
    }
    
    func columnWidth() -> CGFloat {
        return ((self.collectionView!.bounds.size.width - sectionInset.left - sectionInset.right) - ((CGFloat(numberOfColumns - 1)) * columnSpacing)) / CGFloat(numberOfColumns)
    }
    
    func tallestColumnIndex() -> Int {
        var index: Int = 0
        var tallestHeight: CGFloat = 0
        _ = columnHeights.enumerated().map { (idx, height) in
            if (height > tallestHeight) {
                index = idx
                tallestHeight = height
            }
        }
        return index
    }
    
    func shortestColumnIndex() -> Int {
        var index: Int = 0
        var shortestHeight = CGFloat.greatestFiniteMagnitude
        _ = columnHeights.enumerated().map { (idx, height) in
            if (height < shortestHeight) {
                index = idx
                shortestHeight = height
            }
        }
        return index
    }
    
}

class MosaicCollectionViewLayoutInspector: NSObject, ASCollectionViewLayoutInspecting {
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        let layout = collectionView.collectionViewLayout as! MosaicCollectionViewLayout
        return ASSizeRangeMake(CGSize.zero, layout.itemSizeAtIndexPath(indexPath: indexPath))
    }
    
    func scrollableDirections() -> ASScrollDirection {
        return ASScrollDirectionVerticalDirections
    }
}

