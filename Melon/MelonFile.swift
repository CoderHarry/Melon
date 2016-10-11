//
//  MelonFormData.swift
//  Melon
//
//  Created by Caiyanzhi on 2016/10/7.
//  Copyright © 2016年 Caiyanzhi. All rights reserved.
//

import Foundation

/**
 * Melon 上传文件的 struct.
 */
extension Melon {
    struct FormData {
        
        /// 文件名.
        var filename: String = ""
        
        /// 文件的类型. .jpg == image/jpeg
        let mimeType: String
        
        /// 对应服务端字段name.
        let name: String
        
        /**
         *  以下两个字段必传一个.
         */
        /// 文件路径.
        var fileURL:URL?
        /// 文件的二进制流.
        var data:Data?
        
        
        init(filename:String = "", mimeType:String, name:String, fileURL:URL) {
            self.filename = filename
            self.mimeType = mimeType
            self.name = name
            self.fileURL = fileURL
        }
        
        init(filename:String = "", mimeType:String, name:String, fileData:Data) {
            self.filename = filename
            self.mimeType = mimeType
            self.name = name
            data = fileData
        }
        
    } 
}


