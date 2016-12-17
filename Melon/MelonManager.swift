//
//  MelonManager.swift
//  Melon
//
//  Created by Caiyanzhi on 2016/10/7.
//  Copyright © 2016年 Caiyanzhi. All rights reserved.
//

import Foundation

enum MelonManagerType {
    case Request
    case Download
}

/// 网络请求管理类.
class MelonManager:NSObject {
    typealias UploadProgressCallback = ((_ bytesSent: Int64, _ totalBytesSent: Int64, _ totalBytesExpectedToSend: Int64) -> Void)
    typealias DownloadProgressCallback = ((_ bytesWritten: Int64, _ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) -> Void)
    
    /// 请求的地址.
    fileprivate var url:String!
    
    /// 请求方法.
    fileprivate var method:String!
    
    /// 请求参数.
    fileprivate var params: [String: Any] = [:]
    
    /// 请求文件的对象.
    fileprivate var formDatas:[Melon.FormData] = []
    
    /// 请求头.
    fileprivate var httpHeaders:[String: String] = [:]
    
    fileprivate var requestType:MelonManagerType = .Request
    
    /// 请求失败的回调.
    fileprivate var errorCallback: ((_ error: NSError) -> Void)?
    
    /// 请求成功的回调.
    fileprivate var successCallback: ((_ data: Data?, _ response: HTTPURLResponse?) -> Void)?
    
    /// 取消请求的回调.
    var cancelCallback:(()->Void)?
    
    /// 上传的回调
    fileprivate var uploadProgressCallback:UploadProgressCallback?
    
    /// 下载回调
    fileprivate var downloadProgressCallback:DownloadProgressCallback?
    
    /// 请求Session.
    fileprivate var session:URLSession!
    
    /// 请求对象.
    fileprivate var request:URLRequest!
    
    /// 请求任务对象.
    var task:URLSessionTask!
    
    init(url:String, method: Melon.HTTPMethod!) {
        super.init()
        
        self.url = url
        self.method = method.rawValue
        request = URLRequest(url: URL(string: url)!)
        request.timeoutInterval = 60
        session = URLSession(configuration: URLSession.shared.configuration, delegate: self, delegateQueue: URLSession.shared.delegateQueue)
    }
    
    init(downloadUrl:String) {
        super.init()
        
        url = downloadUrl
        self.method = "GET"
        requestType = .Download
        request = URLRequest(url: URL(string: url)!)
        session = URLSession(configuration: URLSession.shared.configuration, delegate: self, delegateQueue: URLSession.shared.delegateQueue)
    }

    func addParams(_ params: [String: Any]) {
        self.params = params
        
        Melon.Print("请求参数:\n\(params)")
    }
    
    func addFiles(_ formDatas:[Melon.FormData]?) {
        if let formDatas = formDatas {
            self.formDatas = formDatas
        }
    }
    
    func addUploadProgressCallback(_ uploadProgressCallback:UploadProgressCallback?) {
        self.uploadProgressCallback = uploadProgressCallback
    }
    
    func addDownloadProgressCallback(_ downloadProgressCallback:DownloadProgressCallback?) {
        self.downloadProgressCallback = downloadProgressCallback
    }
    
    func addErrorCallback(_ errorCallback: ((_ error: NSError) -> Void)?) {
        self.errorCallback = errorCallback
    }
    
    func setTimeoutInterval(_ timeoutInterval:TimeInterval) {
        request.timeoutInterval = timeoutInterval
    }
    
    func addHeaders(_ headers: [String:String]) {
        for (key, value) in headers {
            httpHeaders[key] = value
        }
    }
    
    func setHTTPHeader(_ key: String, _ value: String) {
        httpHeaders[key] = value
    }
    
    func fire(_ callback: ((_ data: Data?, _ response: HTTPURLResponse?) -> Void)? = nil) {
        self.successCallback = callback
        
        buildRequest()
        buildHeaders()
        buildHttpBody()
        
        Melon.Print("这是\(method!)请求,请求地址:\(url!)\nheaders: \(httpHeaders)")
        
        fireTask()
    }
}

extension MelonManager {
    fileprivate struct Const {
        static let boundary = "MelonWJSCZML"
        static let errorDomain = "com.caiyanzhi.Melon"
    }
    
    fileprivate func buildRequest() {
        // 拼接URL
        if method == "GET" && params.count > 0 {
            request = URLRequest(url: URL(string: url + "?" + Melon.Tools.buildParams(params))!)
        }
        
        // 设置请求方法.
        request.httpMethod = method
    }
    
    fileprivate func buildHeaders() {
        // 设置请求头.
        if method == "POST" && params.count > 0 {
            if formDatas.count > 0 {
                request.addValue("multipart/form-data; boundary=\(Const.boundary)", forHTTPHeaderField: "Content-Type")
            } else {
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            }
        }
        
        request.allHTTPHeaderFields = httpHeaders
    }
    
    fileprivate func buildHttpBody() {
        var data = Data()
        
        if formDatas.count > 0  {
            if method == "GET" {
                Melon.Print("\n\n---------------------\n The remote server may not accept GET method with Http body. But Melon will send it anyway.\n ---------------------")
            }
            
            for (key, value) in params {
                data.append("--\(Const.boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                data.append("\((value as AnyObject).description!)\r\n".data(using: .utf8)!)
            }
            
            
            for formdata in formDatas {
                data.append("--\(Const.boundary)\r\n".data(using: .utf8)!)
                
                let name = formdata.name
                let filename = formdata.filename
                data.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
                data.append("Content-Type: \(formdata.mimeType)\r\n".data(using: .utf8)!)
                data.append("\r\n".data(using: .utf8)!)
                
                if let fileData = formdata.data {
                    data.append(fileData)
                    data.append("\r\n".data(using: .utf8)!)
                }
                
                if let fileURL = formdata.fileURL {
                    if let fileData = try? Data(contentsOf: fileURL) {
                        data.append(fileData)
                        data.append("\r\n".data(using: .utf8)!)
                    }
                }
            }
            
            
            data.append("--\(Const.boundary)--\r\n".data(using: .utf8)!)
            
        } else {
            if params.count > 0 && method == "POST" {
                data.append(Melon.Tools.buildParams(params).data(using: .utf8)!)
            }
        }

        request.httpBody = data
    }
    
    fileprivate func fireTask() {
        if requestType == .Download {
            startDownload()
        } else if requestType == .Request {
            startRequest()
        }
        
        
        task.resume()
    }
    
    fileprivate func startDownload() {
        task = session.downloadTask(with: request)
    }
    
    fileprivate func startRequest() {
        task = session.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error as? NSError {
                self?.handleError(error)
                
                Melon.Print("URLResponse 请求失败:\(error.debugDescription) ")
                
            } else {
                DispatchQueue.main.async {
                    self?.successCallback?(data, response as? HTTPURLResponse)
                    self?.session.finishTasksAndInvalidate()
                }
                
            }
        }
    }
    
    func handleError(_ error: NSError) {
        if error.code == -999 {
            DispatchQueue.main.async { [weak self] in
                self?.cancelCallback?()
            }
        } else {
            let e = NSError(domain: Const.errorDomain, code: error.code, userInfo: error.userInfo)
            Melon.Print("Melon Error: ", e.localizedDescription)
            DispatchQueue.main.async {  [weak self] in
                self?.errorCallback?(e)
                self?.session.finishTasksAndInvalidate()
            }
        }
    }
}

extension MelonManager:URLSessionDataDelegate {
    @objc(URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        DispatchQueue.main.async { [weak self] in
            self?.uploadProgressCallback?(bytesSent, totalBytesSent, totalBytesExpectedToSend)
        }
    }
}

extension MelonManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        var fileData:Data? = nil
        fileData = try? Data(contentsOf: location)
        DispatchQueue.main.async { [weak self] in
            self?.successCallback?(fileData, nil)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async { [weak self] in
            self?.downloadProgressCallback?(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
        }
    }
    
    @objc(URLSession:task:didCompleteWithError:)
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error as? NSError {
            handleError(error)
        }
    }
    
    /*
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if challenge.protectionSpace.authenticationMethod != "NSURLAuthenticationMethodServerTrust" {
            return
        }
        
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
     */
}

/*
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}
*/
