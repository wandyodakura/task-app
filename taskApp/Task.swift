//
//  Task.swift
//  taskApp
//
//  Created by 小田倉真弘 on 2017/09/11.
//  Copyright © 2017年 masahiro.odakura. All rights reserved.
//

import RealmSwift
class Task: Object {
    // 管理用 ID。プライマリーキー
    dynamic var id = 0
    
    // タイトル
    dynamic var title = ""
    
    // 内容
    dynamic var contents = ""
    
    /// 日時
    dynamic var date = NSDate()
    
    /**
     id をプライマリーキーとして設定
     */
    dynamic var category: String = ""
    override static func primaryKey() -> String? {
        return "id"
    }
}
