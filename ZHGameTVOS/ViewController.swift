//
//  ViewController.swift
//  ZHGameTVOS
//
//  Created by Zakk Hoyt on 12/12/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var clientsTextView: NSTextView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var clientsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var users = [ZHUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabel.text = "Waiting"
        clientsLabel.text = ""
        
        BonjourTCPServer.sharedInstance.dataReceivedCallback = {(data: String) in
            NSLog("Received: \(data)")
            let user = ZHUser(jsonString: data)
            self.users.append(user)
            self.collectionView.reloadData()
            
//            BonjourTCPServer.sharedInstance.send("Closed loop");
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
        @IBOutlet weak var clientView: UIView!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ZHUserCollectionViewCell", forIndexPath: indexPath) as? ZHUserCollectionViewCell
        cell!.user = users[indexPath.item]
        return cell!
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let w = collectionView.bounds.size.width / 4.0
        return CGSize(width: w, height: w)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
}

extension ViewController: UICollectionViewDelegate {
    
}


