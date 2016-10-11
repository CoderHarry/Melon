//
//  Melon
//  Melon
//
//  Created by Caiyanzhi on 2016/10/7.
//  Copyright © 2016年 Caiyanzhi. All rights reserved.
//

import UIKit

class Melon {
    fileprivate var melonManager:MelonManager!
    
    static func build(HTTPMethod method: Melon.HTTPMethod, url: String) -> Melon {
        let melon = Melon()
        melon.melonManager = MelonManager(url: url, method: method)
        return melon
    }
    
    static func GET(_ url:String) -> Melon {
        return build(HTTPMethod: .GET, url: url)
    }
    
    static func POST(_ url:String) -> Melon {
        return build(HTTPMethod: .POST, url: url)
    }
    
    func addParams(_ params:[String: Any]) -> Melon {
        melonManager.addParams(params)
        return self
    }
    
    func setTimeoutInterval(_ timeoutInterval:TimeInterval) {
        melonManager.setTimeoutInterval(timeoutInterval)
    }
    
    func addHeaders(_ headers: [String:String]) -> Melon {
        melonManager.addHeaders(headers)
        return self
    }
    
    func setHTTPHeader(_ key: String, _ value: String) -> Melon {
        melonManager.setHTTPHeader(key, value)
        return self
    }
    
    func cancel(_ callback: (() -> Void)? = nil) {
        melonManager.cancelCallback = callback
        melonManager.task.cancel()
    }
}


// MARK: - call back

extension Melon {
    func responseString(_ callback: ((_ jsonString:String?, _ response:HTTPURLResponse?)->Void)?) -> Melon {
        return responseData({ (data, response) in
            if let data = data {
                
                let string = String(data: data, encoding: .utf8)
                callback?(string, response)
                
            } else {
                callback?(nil, response)
            }
        })
    }
    
    func responseJSON(_ callback: ((_ jsonObject:Any?, _ response:HTTPURLResponse?)->Void)?) -> Melon {
        return responseData { (data, response) in
            if let data = data {
                let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                callback?(object, response)
            } else {
                callback?(nil, response)
            }
        }
    }
    
    func responseData(_ callback:((_ data:Data?, _ response:HTTPURLResponse?) -> Void)?) -> Melon {
        melonManager.fire(callback)
        return self
    }
    
    func responseXML() -> Melon {
        return self
    }
    
    func onNetworkError(_ errorCallback: ((_ error:NSError)->Void)?) -> Melon {
        melonManager.addErrorCallback(errorCallback)
        return self
    }
}


// MARK: - upload Methods

extension Melon {
    func uploadProgress(_ uploadProgress:((_ bytesSent: Int64, _ totalBytesSent: Int64, _ totalBytesExpectedToSend: Int64)->Void)?) -> Melon {
        melonManager.addUploadProgressCallback(uploadProgress)
        return self
    }
    
    func addFiles(_ formdatas: [Melon.FormData]) -> Melon {
        melonManager.addFiles(formdatas)
        return self
    }
}

// MARK: - download Methods

extension Melon {
    static func Download(_ url:String) -> Melon {
        let melon = Melon()
        melon.melonManager = MelonManager(downloadUrl: url)
        return melon
    }
    
    func downloadProgress(_ downloadProgress:((_ bytesWritten: Int64, _ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) -> Void)?) -> Melon {
        melonManager.addDownloadProgressCallback(downloadProgress)
        return self
    }
}


