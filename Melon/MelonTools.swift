//
//  MelonUtils.swift
//  Melon
//
//  Created by Caiyanzhi on 2016/10/7.
//  Copyright © 2016年 Caiyanzhi. All rights reserved.
//

import Foundation

/**
 *  Melon相关的工具方法，工具类.
 */

extension Melon {
    class Tools {
        /// 处理请求参数.
        ///
        /// - parameter params: 传入参数字典.
        ///
        /// - returns: 编码转换之后的字符串. ex.a=1&b=2.
        static func buildParams(_ params: [String: Any]) -> String {
            var components:[(String, String)] = []
            
            let sortedArray = Array(params.keys).sorted(by: <)
            for key in sortedArray {
                let value = params[key]!
                components += queryComponents(fromKey: key, value: value)
            }
            
            return components.map {"\($0)=\($1)"}.joined(separator: "&")
        }
        
        
        /// 递归查询所有的参数.
        static func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
            var components: [(String, String)] = []
            
            if let dictionary = value as? [String: Any] {
                for (nestedKey, value) in dictionary {
                    components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
                }
            } else if let array = value as? [Any] {
                for value in array {
                    components += queryComponents(fromKey: "\(key)[]", value: value)
                }
            } else if let value = value as? NSNumber {
                if value.isBool {
                    components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
                } else {
                    components.append((escape(key), escape("\(value)")))
                }
            } else if let bool = value as? Bool {
                components.append((escape(key), escape((bool ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
            
            return components
        }
        
        
        /// URLEncode.
        static func escape(_ string: String) -> String {
            let generalDelimitersToEncode = ":#[]@"
            let subDelimitersToEncode = "!$&'()*+,;="
            
            var allowedCharacterSet = CharacterSet.urlQueryAllowed
            allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
            
            return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        }
    }
}

extension NSNumber {
    var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}

extension Melon {
    /// 注释代码
    static func Print<T>(_ message: T, _ file: String = #file, _ method:String = #function, _ line:Int = #line) {
        #if DEBUG
            print("\((file as NSString).lastPathComponent)[\(line)], \(method):\n\(message)")
        #endif
    }

}

