//
//  TrashTableViewCell.swift
//  CatchIdea
//
//  Created by Linsw on 16/12/18.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit

class TrashTableViewCell: UITableViewCell {

    @IBOutlet weak var markColorView: UIView!
    @IBOutlet weak var contentHeaderLabel: UILabel!
    
    internal var header = "" {
        didSet{
            contentHeaderLabel.text = header
        }
    }
    
    internal var delegate : IdeaCellManagerDelegate?
    
    private let gap: CGFloat = 4
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let contentLayer = CALayer()
        contentLayer.frame = CGRect(x: gap, y: gap, width: windowBounds.width-gap*2, height: self.frame.height-gap*2)
        contentLayer.cornerRadius = 10
        contentLayer.backgroundColor = Theme.shared.tableViewCellBackgroundColor.cgColor
        layer.insertSublayer(contentLayer, at: 0)
        
        markColorView.layer.backgroundColor = UIColor.red.cgColor
        
        addGesture()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        markColorView.layer.cornerRadius = markColorView.frame.width/2
    }
    
    private func addGesture(){
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftToDeleteIdeaCell(sender:)))
        swipeLeftGesture.direction = .left
        addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightToRestoreIdeaCell(sender:)))
        swipeRightGesture.direction = .right
        addGestureRecognizer(swipeRightGesture)
    }

    @objc private func swipeLeftToDeleteIdeaCell(sender: UISwipeGestureRecognizer) {
        delegate?.deleteIdea(sender: self)
    }
    
    @objc private func swipeRightToRestoreIdeaCell(sender: UISwipeGestureRecognizer) {
        delegate?.restoreIdea?(sender: self)
    }
}