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
public extension Melon {
    public struct FormData {
        
        /// 文件名.
        public var filename: String = ""
        
        /// 文件的类型. .jpg == image/jpeg
        public var mimeType: String!
        
        /// 对应服务端字段name.
        public var name: String!
        
        /**
         *  以下两个字段必传一个.
         */
        /// 文件路径.
        public var fileURL:URL?
        /// 文件的二进制流.
        public var data:Data?
        
        public init() {}
        
        public  init(filename:String = "", mimeType:String, name:String, fileURL:URL) {
            self.filename = filename
            self.mimeType = mimeType
            self.name = name
            self.fileURL = fileURL
        }
        
        public init(filename:String = "", mimeType:String, name:String, fileData:Data) {
            self.filename = filename
            self.mimeType = mimeType
            self.name = name
            data = fileData
        }
        
    } 
}


