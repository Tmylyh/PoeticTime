//
//  DynastyVC-ConfigUI.swift
//  PoeticTime
//
//  Created by 李跃行 on 2024/3/30.
//

import UIKit

extension DynastyVC {
    
    // 配制球体UI
    func setSphereUI() {
        var array = [UIButton]()
        for i in 1..<40 {
            let btn = UIButton(type: UIButton.ButtonType.system)
            let poetName = poetWithDynastyData[i % poetWithDynastyData.count].poetName
            btn.setTitle("\(poetName)", for: .normal)
            btn.setTitleColor(colorData["DynastyVC_sphereView_\(currentDynasty.rawValue)_color1"]?.pt_argbColor, for: .normal)
            btn.titleLabel?.font = UIFont(name: ZiTi.sjbkjt.rawValue, size: 24)
            btn.frame = CGRect(x: 0, y: 0, width: 100, height: 24)
            btn.tag = i
            tagWithPoet[btn.tag] = poetName
            btn.addTarget(self, action: #selector(self.poetButtonTapped), for: .touchUpInside)
            array.append(btn)
            sphereView.addSubview(btn)
        }
        sphereView.setCloudTags(array)
        sphereView.backgroundColor = .clear
    }
    
    @objc func poetButtonTapped(sender: UIButton) {
        let poetDetailVC = PoetDetailVC()
        let poet = poetData.filter { poet in
            poet.poetName == tagWithPoet[sender.tag] ?? ""
        }
        poetDetailVC.poetId = poet.first?.poetId ?? "dumu"
        poetDetailVC.poetName = tagWithPoet[sender.tag] ?? ""
        poetDetailVC.hero.isEnabled = true
        poetDetailVC.modalPresentationStyle = .overFullScreen
        poetDetailVC.heroModalAnimationType = .zoom
        present(poetDetailVC, animated: true)
    }
    
    // 配制页面UI和布局
    func setUIAndLayout() {
        stackButtonView.addSubview(seperateStackLine1)
        stackButtonView.addSubview(seperateStackLine2)
        self.view.addSubview(stackButtonView)
        self.view.addSubview(backInfoView)
        self.view.addSubview(infoScrollView)
        self.view.addSubview(backButton)
        self.view.addSubview(tagLabel)
        self.view.addSubview(animationBackgroundView)
        
        diyPoemButton.snp.makeConstraints { make in
            make.width.equalTo(dynastyStoryButton)
        }
    
        poemListButton.snp.makeConstraints { make in
            make.width.equalTo(dynastyStoryButton)
        }
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(44)
            make.width.height.equalTo(32)
        }
        
        seperateStackLine1.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Bounds.width / 3 - 1)
            make.width.equalTo(2)
            make.height.equalTo(33)
            make.centerY.equalToSuperview()
        }
        
        seperateStackLine2.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Bounds.width / 3 * 2 - 1)
            make.width.equalTo(2)
            make.height.equalTo(33)
            make.centerY.equalToSuperview()
        }
        
        stackButtonView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(sphereRaius * 2 + statusBarHeight + 32)
            make.height.equalTo(44)
            make.width.equalToSuperview()
        }
        
        backInfoView.snp.makeConstraints { make in
            make.top.equalTo(stackButtonView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        infoScrollView.snp.makeConstraints { make in
            make.top.equalTo(stackButtonView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        tagLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(44)
            make.height.equalTo(240)
            make.width.equalTo(64)
        }
        
        animationBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // 配制infoView的子View
    func setInfoSubViewUI() {
        infoSubViews.append(dynastyStoryView)
        infoSubViews.append(poemUserTableView)
        infoSubViews.append(poemListCollectionView)
        for (index, view) in infoSubViews.enumerated() {
            view.frame = CGRect(x: index * Int(Bounds.width), y: 0, width: Int(Bounds.width), height: Int(infoScrollView.frame.height + 10))
            infoScrollView.addSubview(view)
        }
        setDynastyStoryViewUI()
        setWriteButtonUI()
    }
    
    // 配制个人作诗按钮UI
    private func setWriteButtonUI() {
        self.view.addSubview(poemWriteButton)
        self.view.addSubview(poemWriteBackGroundImage)
        self.view.addSubview(poemWriteLabel)
        
        poemWriteButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-46)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)
            make.width.equalTo(190)
        }
        
        poemWriteBackGroundImage.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14)
            make.centerX.equalToSuperview()
            make.height.equalTo(110)
            make.width.equalTo(200)
        }
        
        poemWriteLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-44)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(120)
        }
    }
    
    // 配制朝代故事UI
    private func setDynastyStoryViewUI() {
        // 朝代故事总页面
        var pages = 0
        
        // 滑动页面控制器
        pageControl = UIPageControl(frame: CGRect(x: 0, y: infoScrollView.frame.height - 64, width: view.frame.width, height: 50))
        guard let pageControl = pageControl else { return }
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
        dynastyStoryContentView.frame = CGRect(x: 16, y: 16, width: Int(Bounds.width) - 32, height: Int(infoScrollView.frame.height) - 48)
        infoScrollView.addSubview(dynastyStoryContentView)
        infoScrollView.addSubview(pageControl)
        // 提前放好四个Label，最后根据字数来控制可滑动范围
        dynastyStoryLabel1.frame = CGRect(x: 8, y: 8, width: Int(dynastyStoryContentView.frame.width) - 16, height: Int(dynastyStoryContentView.frame.height) - 16)
        dynastyStoryLabel2.frame = CGRect(x: Int(dynastyStoryContentView.frame.width) + 8, y: 8, width: Int(dynastyStoryContentView.frame.width) - 16, height: Int(dynastyStoryContentView.frame.height) - 16)
        dynastyStoryLabel3.frame = CGRect(x: Int(dynastyStoryContentView.frame.width * 2) + 8, y: 8, width: Int(dynastyStoryContentView.frame.width) - 16, height: Int(dynastyStoryContentView.frame.height) - 16)
        dynastyStoryLabel4.frame = CGRect(x: Int(dynastyStoryContentView.frame.width * 3) + 8, y: 8, width: Int(dynastyStoryContentView.frame.width) - 16, height: Int(dynastyStoryContentView.frame.height) - 16)
        // 每一页字数
        var perCount = Int((dynastyStoryContentView.frame.width - 16) / 22)
        perCount = perCount * perCount - 1
        // 计算出共有几页
        pages = dynastyStoryData.dynastyInfo.count / perCount + (dynastyStoryData.dynastyInfo.count % perCount > 0 ? 1 : 0)
        pageControl.numberOfPages = pages
        dynastyStoryContentView.contentSize = CGSize(width: Int(dynastyStoryContentView.frame.width) * pages, height: 0)
        // 分割字符串来显示每页内容
        let textList = splitTextIntoChunks(text: dynastyStoryData.dynastyInfo, chunkSize: perCount)
        dynastyStoryLabel1.text = textList.count >= 1 ? textList[0] : ""
        dynastyStoryLabel2.text = textList.count >= 2 ? textList[1] : ""
        dynastyStoryLabel3.text = textList.count >= 3 ?  textList[2] : ""
        dynastyStoryLabel4.text = textList.count >= 4 ? textList[3] : ""
        dynastyStoryContentView.addSubview(dynastyStoryLabel1)
        dynastyStoryContentView.addSubview(dynastyStoryLabel2)
        dynastyStoryContentView.addSubview(dynastyStoryLabel3)
        dynastyStoryContentView.addSubview(dynastyStoryLabel4)
    }
    
    // 分割字符串
    private func splitTextIntoChunks(text: String, chunkSize: Int) -> [String] {
        var chunks: [String] = []
        
        // 循环遍历文本，每次取出指定长度的子字符串
        var startIndex = text.startIndex
        while startIndex < text.endIndex {
            let endIndex = text.index(startIndex, offsetBy: chunkSize, limitedBy: text.endIndex) ?? text.endIndex
            let chunk = String(text[startIndex..<endIndex])
            chunks.append(chunk)
            
            // 更新起始索引
            startIndex = endIndex
        }
        
        return chunks
    }
}
