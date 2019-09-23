//
//  NewsTableVC.swift
//  epoznan
//
//  Created by Krzysztof Wolarz on 06/08/2019.
//  Copyright © 2019 Krzysztof Wolarz. All rights reserved.
//

import UIKit
import SwiftSoup
import Alamofire
import Kingfisher
import SkeletonView

class NewsTableVC: UITableViewController, UIGestureRecognizerDelegate {
    
    var indicator = UIActivityIndicatorView()
    var loadingView = UIView()
    
    var fetchingMore = false
    
    let url = "https://epoznan.pl/index.php"
    var page = 1
    //let parameters = ["section": "news", "subsection": "", "page": String(page)]
    
    var articleLinks = [String]()
    var articleTitles = [String]()
    var articleDates = [String]()
    var articleImageLinks = [String]()
    
    
    @IBOutlet weak var mainArticleImage: UIImageView!
    @IBOutlet weak var mainArticleTitle: UILabel!
    @IBOutlet weak var mainArticleView: UIView!
    
    
    @IBAction func refreshPulled(_ sender: UIRefreshControl) {
        
        articleLinks.removeAll()
        articleTitles.removeAll()
        articleDates.removeAll()
        articleImageLinks.removeAll()
        page = 1
        let parameters = ["section": "news", "subsection": "", "page": String(page)]
        self.getWebData(url: url, parameters: parameters)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            sender.endRefreshing()
        })
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //viewWillAppear(true)
        
        tableView.separatorStyle = .singleLine
        
        view.isSkeletonable = true
        view.showAnimatedGradientSkeleton()
        
        //addLoadingView()
        //activityIndicator()
        indicator.startAnimating()
        indicator.backgroundColor = .white
        
        
        let parameters = ["section": "news", "subsection": "", "page": String(page)]
        getWebData(url: url, parameters: parameters)
        tableView.reloadData()
        //animateTable()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap(_:)))
        tap.delegate = self
        mainArticleView.addGestureRecognizer(tap)
    }
    
    
    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer){
        //mainArticleView.alpha = 0.5
        print("DUPA")
    }
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2 - 20, y: self.view.frame.height/2 - 100, width: 40, height: 40))
        indicator.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(indicator)
    }
    
    func addLoadingView(){
        loadingView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        loadingView.backgroundColor = UIColor.white
        loadingView.center = self.view.center
        self.view.addSubview(loadingView)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return articleTitles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "News", for: indexPath) as! NewsCell

        // Configure the cell...
        cell.titleLabel.text = articleTitles[indexPath.row]
        cell.articleImage.image = UIImage(named: "noImage")
        //cell.textLabel?.text = articleTitles[indexPath.row]
        //if tableView.visibleCells.count < indexPath.row{
            cell.articleImage.kf.setImage(
                with: URL(string: "https://epoznan.pl/\(articleImageLinks[indexPath.row])"),
                placeholder: UIImage(named: "noImage"))
        //}

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let addButton = UITableViewRowAction(style: .normal, title: "Dodaj"){ (rowAction, indexpath) in
            print("ADDBUTTON PRESSED")
        }
        addButton.backgroundColor = UIColor.amethyst
        
        return [addButton]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailVC{
            detailVC.url = articleLinks[indexPath.row]
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func getWebData(url: String, parameters: [String: String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseString(encoding: String.Encoding.isoLatin2){ response in
            self.parseWebData(response: "\(response)")
        }
    }
    
    func parseWebData(response: String){
        do {
            let html = response
            let doc: Document = try SwiftSoup.parse(html)
            
            let mainImage = try doc.getElementsByClass("news_story").first()
            let mainTitle = try doc.getElementsByClass("news_story_title").first()
            
            
            //mainArticleImage.image = UIImage(named: "epoznan")
            mainArticleTitle.text = try mainTitle?.text()
            //print(try mainImage!.attr("style"))
            
            let mainImageURL = try mainImage!.attr("style")
            let firstNawias = mainImageURL.firstIndex(of: "(")
            let lastNawias = mainImageURL.firstIndex(of: ")")
            let mainImageLink = mainImageURL[firstNawias!..<lastNawias!]
            let newURL = mainImageLink.replacingOccurrences(of: "(", with: "https://epoznan.pl/")
            print(newURL)
            mainArticleImage.kf.setImage(with: URL(string: newURL), placeholder: UIImage(named: "epoznan"))
            
           
            
            let newsInfo = try doc.getElementsByClass("new_news_1_link").array()
            let newsDateInfo = try doc.getElementsByClass("new_przypis_news").array()
            let newsImageLink = try doc.getElementsByClass("new_miniimg").array()
            //print(try newsInfo[0].text())
            
            for i in 0...29{
                articleLinks.append(try newsInfo[i].attr("href"))
                articleTitles.append(try newsInfo[i].text())
                articleDates.append(try newsDateInfo[i].text())
                articleImageLinks.append(try newsImageLink[i].attr("src"))
            }

            tableView.reloadData()
            view.hideSkeleton()
            loadingView.isHidden = true
            indicator.stopAnimating()
            indicator.hidesWhenStopped = true
            
            if self.page == 1{
                animateTable()
            }

        } catch Exception.Error(let type, let message) {
            print("TYPE: \(type), MESSAGE: \(message)")
        } catch {
            print("error")
        }
    }
    
    
    
    func animateTable() {
        tableView.reloadData()
        let cells = tableView.visibleCells
        
        let tableViewHeight = tableView.bounds.size.height
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        
        var delayCounter = 0
        for cell in cells {
            UIView.animate(withDuration: 1.5, delay: Double(delayCounter) * 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
    
 
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        //print("Offset: \(offsetY), coontentHeight: \((contentHeight - scrollView.frame.height * 3))")
        
        if abs(offsetY) > abs(contentHeight - scrollView.frame.height * 1.5){
            if !fetchingMore{
                beginFetching()
            }
        }
    }
    
    func beginFetching(){
        fetchingMore = true
        
        page += 1
        let parameters = ["section": "news", "subsection": "", "page": String(page)]
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.25, execute: {
            self.getWebData(url: self.url, parameters: parameters)
            self.fetchingMore = false
        })
        tableView.reloadData()
        print(page)
    }

}
