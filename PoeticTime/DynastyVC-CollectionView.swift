//
//  DynastyVC-CollectionView.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/30.
//

import UIKit

extension DynastyVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return poemWithDynastyData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPtPoemCell, for: indexPath) as! PtPoemCell
        cell.backgroundColor = .white
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 20
        cell.poemId = poemWithDynastyData[indexPath.row].poemId
        cell.changeStarStatusCompletion = { [weak self] isStar in
            guard let self = self else { return }
            self.poemWithDynastyData[indexPath.row] = Poem(poemId: self.poemWithDynastyData[indexPath.row].poemId, poemName: self.poemWithDynastyData[indexPath.row].poemName, poetId: self.poemWithDynastyData[indexPath.row].poetId, dynastyId: self.poemWithDynastyData[indexPath.row].dynastyId, poemBody: self.poemWithDynastyData[indexPath.row].poemBody, poemStar: isStar)
        }
        var tmpText = ""
        if poemWithDynastyData[indexPath.row].poemName.count <= 3 {
            tmpText = verticalText(text: poemWithDynastyData[indexPath.row].poemName)
        } else {
            tmpText = poemWithDynastyData[indexPath.row].poemName
        }
        cell.poemText = tmpText
        let poet = poetWithDynastyData.filter { $0.poetId == poemWithDynastyData[indexPath.row].poetId }
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
        poemDetailVC.poemId = poemWithDynastyData[indexPath.row].poemId
        poemDetailVC.poemName = poemWithDynastyData[indexPath.row].poemName
        poemDetailVC.poemBody = poemWithDynastyData[indexPath.row].poemBody
        poemDetailVC.poetId = poemWithDynastyData[indexPath.row].poetId
        poemDetailVC.dynastyId = poemWithDynastyData[indexPath.row].dynastyId
        poemDetailVC.isStar = poemWithDynastyData[indexPath.row].poemStar
        poemDetailVC.changeStarStatus = { [weak self] isStar in
            guard let self = self else { return }
            self.poemWithDynastyData[indexPath.row] = Poem(poemId: self.poemWithDynastyData[indexPath.row].poemId, poemName: self.poemWithDynastyData[indexPath.row].poemName, poetId: self.poemWithDynastyData[indexPath.row].poetId, dynastyId: self.poemWithDynastyData[indexPath.row].dynastyId, poemBody: self.poemWithDynastyData[indexPath.row].poemBody, poemStar: isStar)
            let star = isStar ? "is" : "no"
            // 修改UI
            cell.starButton.setImage(UIImage(named: "poetic_time_poem_card_\(star)_star_image"), for: .normal)
        }
        let poet = poetData.filter { $0.poetId == poemWithDynastyData[indexPath.row].poetId }
        let dynasty = dynastyData.filter { $0.dynastyId == poemWithDynastyData[indexPath.row].dynastyId }
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
