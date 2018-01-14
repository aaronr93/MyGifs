//
//  GifCollectionViewCell.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 11/5/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import AsyncDisplayKit
import AVFoundation
import MyGifsKit

class GifCollectionNode: ASCellNode {
    
    let gifNode: ASVideoNode = {
        let videoNode = ASVideoNode()
        videoNode.contentMode = .scaleAspectFill
        videoNode.shouldAutorepeat = true
        videoNode.shouldAutoplay = true
        return videoNode
    }()
    
    let imageNode: ASNetworkImageNode = {
        let node = ASNetworkImageNode()
        node.contentMode = .scaleAspectFill
        return node
    }()
    
    let textNode = ASTextNode()
    
    init(gif: Gfy) {
        super.init()
        DispatchQueue.main.async {
            self.gifNode.asset = gif.thumbnailAsset
        }
        self.gifNode.style.maxWidth = ASDimension(unit: ASDimensionUnit.points, value: CGFloat(gif.width / 4))
        self.gifNode.style.maxHeight = ASDimension(unit: ASDimensionUnit.points, value: CGFloat(gif.height / 4))
        self.automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        return ASRatioLayoutSpec(ratio: 9/16, child: gifNode)
        
        
//        var cellChildren: [ASLayoutElement] = []
        
//        let headerStack = ASStackLayoutSpec.horizontal()
//        headerStack.alignItems = .center
//        avatarImageNode.style.preferredSize = CGSize(width: Constants.CellLayout.UserImageHeight, height: Constants.CellLayout.UserImageHeight)
//        cellChildren.append(ASInsetLayoutSpec(insets: Constants.CellLayout.InsetForAvatar, child: avatarImageNode))
//        usernameLabel.style.flexShrink = 1.0
//        cellChildren.append(usernameLabel)
//
//        let spacer = ASLayoutSpec()
//        spacer.style.flexGrow = 1.0
//        cellChildren.append(spacer)
//
//        timeIntervalLabel.style.spacingBefore = Constants.CellLayout.HorizontalBuffer
//        cellChildren.append(timeIntervalLabel)
//
//        let footerStack = ASStackLayoutSpec.vertical()
//        footerStack.spacing = Constants.CellLayout.VerticalBuffer
//        footerStack.children = [photoLikesLabel, photoDescriptionLabel]
//        headerStack.children = cellChildren
//
//        let verticalStack = ASStackLayoutSpec.vertical()
//
//        verticalStack.children = [ASInsetLayoutSpec(insets: Constants.CellLayout.InsetForHeader, child: headerStack), ASRatioLayoutSpec(ratio: 1.0, child: videoNode), ASInsetLayoutSpec(insets: Constants.CellLayout.InsetForFooter, child: footerStack)]
//
//        return verticalStack
    }
    
}
