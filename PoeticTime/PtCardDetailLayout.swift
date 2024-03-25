//
//  PtCardDetailLayout.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/23.
//

import UIKit
/// 为卡片定制的Layout   参考项目FSPagerView
class PtCardDetailLayout: UICollectionViewFlowLayout {
    private var contentSize: CGSize = .zero  // collectionView的真实size
    private var itemSpacing: CGFloat = 0    // 每一个item占用的间距
    private var topMarginSpacing: CGFloat = 0  // 卡片距离CollectionView上下边距
    private var leftMarginSpacing: CGFloat = 0  // 卡片距离CollectionView左右边距
    private var numberOfSections = 0    // 存在多少个Section,这里单指有多少组轮播的分组
    private var numberOfItems = 0       // 实际有多少个元素
    private var itemsCount = 0          // 计算出有多少个Item， numberOfSections * numberOfItems
    private let widthRatio: CGFloat = min(UIScreen.main.bounds.width, 428) / 390
    public var needReprepare = true  // 是否需要重新准备，当外部collectionView需要reloadData时需要将该属性置为true
    public var firstOffsetIndex: Int = 0   //首次偏移的index
    public var activeIndexPath: IndexPath? = nil { // 当前正在活跃的cell的index
        didSet {
            if let activeIndexPath = activeIndexPath, activeIndexPath != oldValue {
                activeIndexPathDidChangeBlock?(activeIndexPath)
            }
        }
    }
    
    public var activeIndexPathDidChangeBlock: ((IndexPath) -> Void)? = nil
    
    override init() {
        super.init()
        self.scrollDirection = .horizontal
        self.minimumInteritemSpacing = -110  // 两张卡片之间的距离，当前值是负数表示两张卡片是层叠的
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 移动到的indexPath
    public func offsetCollectionViewTo(indexPath: IndexPath) {
        guard let collectionView = self.collectionView else {
            return
        }
        let contentOffset = self.contentOffset(for: indexPath)
        let newBounds = CGRect(origin: contentOffset, size: collectionView.frame.size)
        collectionView.bounds = newBounds
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    // 准备：根据collectionView的信息初始化部分必要的参数
    override func prepare() {
        super.prepare()
        guard let collectionView = self.collectionView, needReprepare else {
            return
        }
        self.needReprepare = false
        self.numberOfItems = collectionView.numberOfItems(inSection: 0)
        self.numberOfSections = collectionView.numberOfSections
        self.itemsCount = numberOfItems * numberOfSections
        calculateItemSize(with: collectionView.frame.size)
        
        topMarginSpacing = (collectionView.frame.size.height - self.itemSize.height) / 2
        leftMarginSpacing = (collectionView.frame.size.width - self.itemSize.width) / 2
        itemSpacing = self.itemSize.width + self.minimumInteritemSpacing
        
        var contentSizeWidth: CGFloat = leftMarginSpacing * 2
        contentSizeWidth += CGFloat(itemsCount - 1) * self.minimumInteritemSpacing
        contentSizeWidth += CGFloat(itemsCount) * self.itemSize.width
        contentSize = CGSize(width: contentSizeWidth, height: collectionView.frame.height)
        adjustCollectionViewBounds()  // 调整CollectionView的Bounds，使得cell一开始就处在所有轮播组的中间
    }
    
    // 根据相对collectionView的展示区域，计算可能会展示的cell的LayoutAttributes
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        guard self.itemSpacing > 0, !rect.isEmpty else {
            return layoutAttributes
        }
        //将给定的rect与self.contentSize进行交集运算，得到rect和contentSize的重叠部分。这是为了确保计算的UICollectionViewLayoutAttributes在内容区域内
        let intersectionRect = rect.intersection(CGRect(origin: .zero, size: self.contentSize))
        guard !intersectionRect.isEmpty else {
            return layoutAttributes
        }
        
        let numberOfItemsBefore = max(Int((intersectionRect.minX - leftMarginSpacing) / self.itemSpacing), 0) // 需要开始计算的item的index
        let startPosition = leftMarginSpacing + CGFloat(numberOfItemsBefore) * self.itemSpacing
        let startIndex = numberOfItemsBefore
        var itemIndex = startIndex
        var origin = startPosition       // 需要开始计算LayoutAttributes 的开始位置
        let maxPosition = min(intersectionRect.maxX, self.contentSize.width - self.itemSize.width - self.sectionInset.left) // 需要计算LayoutAttributes 的最大的位置
        while origin <= maxPosition && itemIndex <= self.itemsCount {
            let indexPath = IndexPath(item: itemIndex % self.numberOfItems, section: itemIndex / self.numberOfItems)
            let attributes = self.applyTransformLayoutAttributes(with: indexPath)
            layoutAttributes.append(attributes)
            itemIndex += 1
            origin += self.itemSpacing
        }
        return layoutAttributes
    }

    // 根据滚动的参考目标Point 和 滚动速度，计算出一个真正的目标位置
    // 滚动时调用
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else {
            return proposedContentOffset
        }
        let contentOffsetX = collectionView.contentOffset.x
        let decelerationRatio: CGFloat = 0.1  // 减速系数
        let targetContentOffsetX = contentOffsetX + (proposedContentOffset.x - contentOffsetX) * decelerationRatio
        
        var targetContentOffset = CGPoint(x: targetContentOffsetX, y: proposedContentOffset.y)
        let boundedOffset = collectionView.contentSize.width - self.itemSpacing
        var targetOffset: CGFloat = 0
        if abs(velocity.x) >= 0.3 {  // 速度大于0.3则会切换到另一张，否则回到原来的位置
            let vector: CGFloat = velocity.x >= 0 ? 1 : -1
            targetOffset = round(targetContentOffset.x / self.itemSpacing + 0.15 * vector) * self.itemSpacing
        } else {
            targetOffset = round(targetContentOffset.x / self.itemSpacing) * self.itemSpacing
        }
        targetOffset = min(boundedOffset, max(0, targetOffset))
        targetContentOffset = CGPoint(x: targetOffset, y: targetContentOffset.y)
        return targetContentOffset
    }
    
    // 根据indexPath创建一个LayoutAttributes，并根据它的位置计算出它的位置、角度、放大系数、透明度、和图层位置等
    private func applyTransformLayoutAttributes(with indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.indexPath = indexPath
        let frame = self.frame(for: indexPath)
        let center = CGPoint(x: frame.midX, y: frame.midY)
        attributes.center = center
        attributes.size = self.itemSize
        guard let collectionView = self.collectionView else {
            return attributes
        }
        let ruler = collectionView.bounds.midX
        let position = (attributes.center.x - ruler) / self.itemSpacing  // 相对中心的position，值是-X ... X 之间， 0表示在正中心
        var zIndex = 0
        var transform = CGAffineTransform.identity
        let alphaRatio: CGFloat = max(0, min(1, 1 - abs(position) * 0.5))
        let scale = max(0, min(1, 1 - 0.2 * abs(position)))  // 放大比例，距离中心越远，比例越小
        if position <= 5 && position >= -5 {
            let calculus: CGFloat = 20   // 圆的边缘个数，当数值越大cell斜度越小
            let circle: CGFloat = .pi * 2.0
            let radius = itemSpacing * calculus / circle
            let rotation = position * circle / calculus
            transform = transform.scaledBy(x: scale, y: scale)
            transform = transform.translatedBy(x: -position * itemSpacing, y: radius)
            transform = transform.rotated(by: rotation)
            transform = transform.translatedBy(x: 0, y: -radius)
            zIndex = Int((4.0 - abs(position) * 10))
        }
        attributes.alpha = abs(position) < 0.5 ? 1 : alphaRatio
        attributes.transform = transform
        attributes.zIndex = zIndex  // 只有最中心的zIndex最大，依次向两边递减
        if attributes.alpha == 1 {   // alpha为1的那个index是活跃度
            activeIndexPath = indexPath
        }
        return attributes
    }
    
    // 通过indexPath计算出item的frame
    private func frame(for indexPath: IndexPath) -> CGRect {
        let numberOfItems = self.numberOfItems * indexPath.section + indexPath.item
        let originX: CGFloat = leftMarginSpacing + CGFloat(numberOfItems) * self.itemSpacing
        let origin = CGPoint(x: originX, y: topMarginSpacing)
        let frame = CGRect(origin: origin, size: self.itemSize)
        return frame
    }
    
    // 通过indexPath计算出item的实际的中心点的frame
    public func contentOffset(for indexPath: IndexPath) -> CGPoint {
        let origin = self.frame(for: indexPath).origin
        guard let collectionView = self.collectionView else {
            return origin
        }
        let contentOffsetX: CGFloat = origin.x - (collectionView.frame.width * 0.5 - self.itemSize.width * 0.5)
        return CGPoint(x: contentOffsetX, y: 0)
    }
    
    // 调整CollectionView的Bounds，使得cell一开始就处在所有轮播组的中间
    private func adjustCollectionViewBounds() {
        guard let collectionView = self.collectionView else {
            return
        }
        let midNumber = self.itemsCount / 2 // 算出最中间cell是第几个
        let midSection = midNumber / numberOfItems // 得到中心的section
        let midIndex = midNumber % numberOfItems // 得到中心的index
        let newIndexPath = IndexPath(item: Int(midIndex) + firstOffsetIndex, section: Int(midSection))
        let contentOffset = self.contentOffset(for: newIndexPath)
        let newBounds = CGRect(origin: contentOffset, size: collectionView.frame.size)
        collectionView.bounds = newBounds
        firstOffsetIndex = 0
    }
    
    //计算ItemSize，它是根据collectionView的宽高计算的来的
    private func calculateItemSize(with superViewSize: CGSize) {
        let itemPadding: CGFloat = 3  //item的内边距
        // 卡片的宽高比是刨去内边距的比例是 3 : 4
        let itemLeftOffset = 39 * widthRatio  //item距离左边的偏移
        let itemTopOffset: CGFloat = 28
        var itemCardWidth = superViewSize.width - itemLeftOffset * 2 - itemPadding * 2
        var itemCardHeight = itemCardWidth / 3 * 4
        let itemCardMaxHeight = superViewSize.height - itemTopOffset * 2 - itemPadding * 2
        if itemCardHeight > itemCardMaxHeight {
            // 当容器的高度不足以满足计算出来的高度时，需按照最大高度重新计算
            itemCardHeight = itemCardMaxHeight
            itemCardWidth = itemCardHeight / 4 * 3
        }
        let itemWidth = itemCardWidth + itemPadding * 2
        let itemHeight = itemCardHeight + itemPadding * 2 + 40
        self.itemSize = CGSize(width: itemWidth, height: itemHeight)
    }
}
