//
//  NewsCell.swift
//  epoznan
//
//  Created by Krzysztof Wolarz on 06/08/2019.
//  Copyright © 2019 Krzysztof Wolarz. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {

    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //articleImage.image = UIImage(named: "noImage")
        articleImage.layer.cornerRadius = articleImage.frame.size.height/20
        articleImage.layer.borderWidth = 1.0
        articleImage.layer.borderColor = UIColor.blue.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
