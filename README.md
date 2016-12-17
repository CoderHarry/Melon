# Melon

Melon is a Swift HTTP networking libray.

### Install

current Version only support cocoapods.

```
pod 'Melon', '~> 1.0.1' 
pod update
```


### Requirements

> iOS 7.0+
> Xcode 8(Swift 3)


### Simple Using

**GET:**

```
Melon.GET("https://httpbin.org/get")
            .addHeaders(["a":"a", "b":"b"])
            .addParams(["name": "caiyanzhi", "age":26])
            .onNetworkError({ error in
            }).responseJSON { (jsonObject, response) in
                print("jsonObject : \(jsonObject)" )
        }
```

**POST:**

```
 Melon.POST("https://httpbin.org/post")
            .addHeaders(["a":"a", "b":"b"])
            .addParams(["name": "caiyanzhi", "age":26])
            .onNetworkError({ error in
            }).responseJSON { (jsonObject, response) in
                print("jsonObject : \(jsonObject)")
        }
```

**upload:**

```
let melon =
        Melon.POST("https://httpbin.org/post")
            .addHeaders(["a":"a", "b":"b"])
            .addParams(["name": "caiyanzhi", "age":26])
            .addFiles([formdata])
            .uploadProgress({ (bytesSent, totalBytesSent, totalBytesExpectedToSend) in
                Melon.Print("totalBytesSent:\(totalBytesSent)")
                Melon.Print("totalBytesExpectedToSend:\(totalBytesExpectedToSend)")
            })
            .onNetworkError({ error in
            }).responseJSON { (jsonObject, response) in
                print("jsonObject : \(jsonObject)")
        }
```


**download:**

```
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
                print("image: \(image)")
            }
        }
```


**cancel:**

```
you can use cancel method to cancel request

melon.cancel()
melon.cancel {
	// cancel callback
}
```



### future will Support

> Setting SSL pinning
> Queue


