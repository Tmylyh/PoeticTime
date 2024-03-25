//
//  PtDynastyLayout.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/24.
//

import UIKit

class PtDynastyLayout: UICollectionViewFlowLayout {
    
    // 整体往右偏移
    let offset = 4
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    private func setupLayout() {
        minimumLineSpacing = 4
        minimumInteritemSpacing = 4
        scrollDirection = .horizontal
    }
    
    override var itemSize: CGSize {
        set {}
        get {
            guard let collectionView = collectionView else { return CGSize.zero }
            let availableWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right - minimumInteritemSpacing * CGFloat(9 - 1)
            let itemWidth = availableWidth / CGFloat(9) - 6
            let itemHeight = collectionView.bounds.height - sectionInset.top - sectionInset.bottom - 24
            return CGSize(width: itemWidth, height: itemHeight)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        attributes?.forEach({ (attribute) in
            if attribute.representedElementCategory == .cell {
                let indexPath = attribute.indexPath
                attribute.frame.origin.x = sectionInset.left + CGFloat(indexPath.item) * (itemSize.width + minimumInteritemSpacing + 6) + 4
            }
        })
        return attributes
    }
}
