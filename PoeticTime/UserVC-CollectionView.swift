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
        cell.changeStarStatusCompletion = { [weak self] isStar in
            guard let self = self else { return }
            self.starPoemData[indexPath.row] = Poem(poemId: self.starPoemData[indexPath.row].poemId, poemName: self.starPoemData[indexPath.row].poemName, poetId: self.starPoemData[indexPath.row].poetId, dynastyId: self.starPoemData[indexPath.row].dynastyId, poemBody: self.starPoemData[indexPath.row].poemBody, poemStar: isStar)
        }
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
        guard let cell = collectionView.cellForItem(at: indexPath) as? PtPoemCell else { return }
        ButtonAnimate(cell)
        let poemDetailVC = PoemDetailVC()
        poemDetailVC.poemId = starPoemData[indexPath.row].poemId
        poemDetailVC.poemName = starPoemData[indexPath.row].poemName
        poemDetailVC.poemBody = starPoemData[indexPath.row].poemBody
        poemDetailVC.isStar = starPoemData[indexPath.row].poemStar
        poemDetailVC.changeStarStatus = { [weak self] isStar in
            guard let self = self else { return }
            self.reloadCurrentVC()
        }
        poemDetailVC.poetId = starPoemData[indexPath.row].poetId
        poemDetailVC.dynastyId = starPoemData[indexPath.row].dynastyId
        let poet = poetData.filter { $0.poetId == starPoemData[indexPath.row].poetId }
        let dynasty = dynastyData.filter { $0.dynastyId == starPoemData[indexPath.row].dynastyId }
        poemDetailVC.poetName = poet.first?.poetName ?? ""
        poemDetailVC.dynastyName = dynasty.first?.dynastyName ?? ""
        let uuid = "\(UUID())"
        cell.hero.id = uuid
        poemDetailVC.view.hero.id = uuid
        poemDetailVC.hero.isEnabled = true
        poemDetailVC.modalPresentationStyle = .overFullScreen
        present(poemDetailVC, animated: true)
    }
}
