//
//  PtChatCustomCell.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/4/1.
//

import MessageKit
import UIKit

class PtChatCustomCell: UICollectionViewCell {
  // MARK: Lifecycle

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setupSubviews()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupSubviews()
  }

  // MARK: Open

  open func setupSubviews() {
    contentView.addSubview(label)
    label.textAlignment = .center
    label.font = UIFont.italicSystemFont(ofSize: 13)
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    label.frame = contentView.bounds
  }

  open func configure(with message: MessageType, at _: IndexPath, and _: MessagesCollectionView) {
    // Do stuff
    switch message.kind {
    case .custom(let data):
      guard let systemMessage = data as? String else { return }
      label.text = systemMessage
    default:
      break
    }
  }

  // MARK: Internal

  let label = UILabel()
}
