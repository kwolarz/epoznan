//
//  DetailVC.swift
//  epoznan
//
//  Created by Krzysztof Wolarz on 07/08/2019.
//  Copyright © 2019 Krzysztof Wolarz. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import SwiftSoup
import SkeletonView

class DetailVC: UIViewController {
    
    var url = String()
    
    @IBOutlet weak var detailArticleImage: UIImageView!
    @IBOutlet weak var detailArticleTitle: UILabel!
    @IBOutlet weak var detailArticleTreść: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setSkeletonView()
        getWebData(url: "https://epoznan.pl/\(url)")
    }
    
    func getWebData(url: String){
        Alamofire.request(url, method: .get).responseString{ response in
            //print(response)
            self.parseWebData(response: "\(response)")
            self.hideSkeletonView()
        }
    }
    
    func parseWebData(response: String){
        do {
            print(response)
            let html = response.replacingOccurrences(of: "<p>", with: "%%%%")
            
            let doc: Document = try SwiftSoup.parse(html)
            
            if let image = try doc.getElementsByClass("post__featuredImage").first()?.attr("src"){
            //detailArticleImage.kf.indicatorType = .activity
                detailArticleImage.kf.setImage(with: URL(string: image), placeholder: UIImage(named: "noImage"))
            } else{
                detailArticleImage.image = UIImage(named: "noImage")
            }
            
            let title = try doc.getElementsByClass("post__title").first()
            detailArticleTitle.text = try title?.text()
            
            let treść = try doc.getElementsByClass("post__content").first()
            detailArticleTreść.text = try treść?.text().replacingOccurrences(of: "%%%%", with: "\n\n")
            
//            let treść = try doc.select("p").array()
//            detailArticleTreść.text = try treść[0].text()
            
        } catch Exception.Error(let type, let message) {
            print("TYPE: \(type), MESSAGE: \(message)")
        } catch {
            print("error")
        }
    }
    
    
    func setSkeletonView(){
        detailArticleImage.isSkeletonable = true
        detailArticleTitle.isSkeletonable = true
        detailArticleTreść.isSkeletonable = true
        detailArticleImage.showAnimatedGradientSkeleton()
        detailArticleTitle.showAnimatedGradientSkeleton()
        detailArticleTreść.showAnimatedGradientSkeleton()
    }
    
    func hideSkeletonView(){
        self.detailArticleImage.hideSkeleton()
        self.detailArticleTitle.hideSkeleton()
        self.detailArticleTreść.hideSkeleton()
    }
}
