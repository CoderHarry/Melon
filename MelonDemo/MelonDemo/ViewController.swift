//
//  ViewController.swift
//  MelonDemo
//
//  Created by Caiyanzhi on 2016/10/11.
//  Copyright © 2016年 Caiyanzhi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Get请求
        testGetRequest()
        
        // Post请求
//        testPostRequest()
        
        // 上传文件
//        testUpload()
        
        // 下载文件
//        testDownload()
        
    }
    
    
    fileprivate func testGetRequest() {
        let melon =
            Melon.GET("https://httpbin.org/get")
                .addHeaders(["a":"a", "b":"b"])
                .addParams(["name": "caiyanzhi", "age":26])
                .onNetworkError({ error in
                    // 请求失败的方法
                }).responseJSON { (jsonObject, response) in
                   print("jsonObject : \(String(describing: jsonObject))" )
        }
        
        print(melon)
    }
    
    fileprivate func testPostRequest() {
        let melon =
            Melon.POST("https://httpbin.org/post")
                .addHeaders(["a":"a", "b":"b"])
                .addParams(["name": "caiyanzhi", "age":26])
                .onNetworkError({ error in
                    // 请求失败的方法
                }).responseJSON { (jsonObject, response) in
                    print("jsonObject : \(String(describing: jsonObject))")
        }
        
        print(melon)
    }
    
    fileprivate func testUpload() {
        let data = UIImageJPEGRepresentation(UIImage(named: "logo.png")!, 1.0)
        let formdata = Melon.FormData(filename: "1.jpg", mimeType: "image/jepg", name: "image", fileData: data!)
        
        let melon =
        Melon.POST("https://httpbin.org/post")
            .addHeaders(["a":"a", "b":"b"])
            .addParams(["name": "caiyanzhi", "age":26])
            .addFiles([formdata])
            .uploadProgress({ (bytesSent, totalBytesSent, totalBytesExpectedToSend) in

            })
            .onNetworkError({ error in
                // 请求失败的方法
            }).responseJSON { (jsonObject, response) in
                print("jsonObject : \(String(describing: jsonObject))")
        }
        
        print(melon)
    }
    
    fileprivate func testDownload() {
        let melon =
        Melon.Download("https://www.google.co.jp/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png").onNetworkError ({ error in
            
        }).downloadProgress({ (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
            print("bytesWritten:\(bytesWritten)")
            print("totalBytesWritten:\(totalBytesWritten)")
            print("totalBytesExpectedToWrite:\(totalBytesExpectedToWrite)")
            print("progress:\(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite))")
        }).responseData { (data, reponse) in
            if let data = data {
                let image = UIImage(data: data)
                print("image: \(String(describing: image))")
            }
        }
        
        print(melon)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

