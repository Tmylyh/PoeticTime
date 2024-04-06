//
//  UserVC-CollectionView.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/5.
//

import UIKit

extension UserVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return starPoemData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPtPoemCell, for: indexPath) as! PtPoemCell
        cell.backgroundColor = "#D8F0EC".pt_argbColor
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 20
        
        cell.poemId = starPoemData[indexPath.row].poemId
        var tmpText = ""
        if starPoemData[indexPath.row].poemName.count <= 3 {
            tmpText = verticalText(text: starPoemData[indexPath.row].poemName)
        } else {
            tmpText = starPoemData[indexPath.row].poemName
        }
        cell.poemText = tmpText
        let poet = poetData.filter { $0.poetId == starPoemData[indexPath.row].poetId }
        cell.poetText = verticalText(text: poet.first?.poetName ?? "")
        cell.contentView.hero.id = "poemCell\(indexPath.row)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width - 48) / 3 // 设置每行3个item，左右间距各是8
        let cellHeight = cellWidth // 控制 cell 的高宽比
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let animationView = collectionView.cellForItem(at: indexPath) else { return }
        ButtonAnimate(animationView)
    }
}
