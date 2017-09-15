//
//  Cloudant.swift
//  JsonFun
//
//  Created by Horea Porutiu on 9/9/17.
//  Copyright © 2017 Horea Porutiu. All rights reserved.
//

import Foundation

//
//  Watson.swift
//  JsonFun
//
//  Created by Horea Porutiu on 9/8/17.
//  Copyright © 2017 Horea Porutiu. All rights reserved.
//

import Foundation
import UIKit
import TextToSpeechV1
import SpeechToTextV1
import AVFoundation

class Cloudant: UIViewController {
    
    func getTopPhrases(topPhrases: UILabel) {
        
        let OWurl = URL(string: "https://openwhisk.ng.bluemix.net/api/v1/web/Developer%20Advocate_dev/demo1/getPopularPhrases")
        var request = URLRequest(url: OWurl!)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            do {
                if data != nil {
                    let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
                    let index = json?["index"] as! [String:Any]
                    
                    let phrases = index["phrases"] as! [[String:AnyObject]]
                    var i = 0;
                    DispatchQueue.main.async() {
                        topPhrases.text = "Popular Phrases \n \n"
                        for event in phrases {
                            if(i==5){break}
                            print(event["phrase"] as! String)
                            topPhrases.text = (topPhrases.text)! + (event["phrase"] as? String)! + "\n"
                            i=i+1;
                        }
                    }
                }
                
            } catch {
                print("Error deserializing JSON: \(error)")
            }
            }.resume()

    
    }
    
  }
