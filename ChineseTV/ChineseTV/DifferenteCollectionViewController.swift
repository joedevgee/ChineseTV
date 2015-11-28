//
//  DramaCollectionViewController.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/28/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import Parse

class DramaCollectionViewController: SingleCategoryCollectionViewController {
    override func queryForCollection() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.orderByDescending("createdAt")
        query.whereKey("category", equalTo: "drama")
        return query
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitle = "电视剧"
        segueName = "showDrama"
    }
}

class RealityCollectionViewController: SingleCategoryCollectionViewController {
    override func queryForCollection() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.orderByDescending("createdAt")
        query.whereKey("category", equalTo: "reality")
        return query
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitle = "真人秀"
        segueName = "showReality"
    }
}

class TalkshowCollectionViewController: SingleCategoryCollectionViewController {
    override func queryForCollection() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.orderByDescending("createdAt")
        query.whereKey("category", equalTo: "talkshow")
        return query
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitle = "谈话性"
        segueName = "showTalkshow"
    }
}


