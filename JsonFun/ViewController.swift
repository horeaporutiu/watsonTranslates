//
//  ViewController.swift
//  JsonFun
//
//  Created by Horea Porutiu on 6/6/17.
//  Copyright © 2017 Horea Porutiu. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerLabel: UILabel!
    
    @IBOutlet weak var text: UITextField!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var translateToLabel: UILabel!
    
    
    let sourceLanguages = [ "Arabic", "Brazilian", "Portuguese", "French", "German", "Italian", "Spanish"]
    
    let targetLanguages = ["Arabic", "Brazilian", "Portuguese", "French", "German", "Italian", "Spanish"]
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sourceLanguages[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sourceLanguages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 1 {
            pickerLabel.text = sourceLanguages[row]
        }
        if pickerView.tag == 2 {
            translateToLabel.text = targetLanguages[row]
        }
    }
    
    
    
    
    @IBAction func onPostTapped(_ sender: Any) {
        
        print("*********************************************")
         print(text.text ?? "")
        let someStr : String = text.text ?? ""
        let parameters = [
            "source": "en",
            "target": "es",
            "text": someStr]
        
        guard let url = URL(string: "https://watson-api-explorer.mybluemix.net/language-translator/api/v2/translate") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
                    //print(json)
                    if let translation = json["translations"]  {
                        for index in 0...translation.count-1 {
                            let aObject = translation[index] as! [String : AnyObject]
                            let something = String(describing: aObject)
                            //cut out useless characters from JSON response
                            let tempStr = String(something.characters.dropLast(1))
                            let finalStr = String(tempStr.characters.dropFirst(16))
                            print(finalStr)
                            //make sure label gets updated instantly
                            DispatchQueue.main.async() {
                                //update label
                                self.label.text = finalStr                            }
                        }
                    }
                    
                    
                }
                catch {
                    print("opsdfdfs")
                    print(error)
                }
            }
        }.resume()
        
        
    }
    
    
    

    override func viewDidLoad() {
       
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

