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
    
    @IBOutlet weak var pickerView2: UIPickerView!
    @IBOutlet weak var pickerLabel: UILabel!
    
    @IBOutlet weak var text: UITextField!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var translateToLabel: UILabel!
    
    //TODO: map languages to correct two letter abrev
    var sourceLanguages = [ "Arabic", "English", "Portuguese", "French", "Spanish"]
    
    var targetLanguages = ["English"]
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            switch row{
            case 0:
                targetLanguages = ["English"]
            case 1:
                targetLanguages = ["Arabic", "Portuguese", "French", "Spanish"]
            case 2:
                targetLanguages = ["English"]
            case 3:
                targetLanguages = ["English"]
            case 4:
                targetLanguages = ["English"]
            default:
                print("error")
            }
            self.pickerView2.reloadAllComponents()
            return sourceLanguages[row]
        }
        
        return targetLanguages[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return sourceLanguages.count
        }
        else {
            if self.sourceLanguages[2] == "English" {
                print("@@@@@@@@@@@@@@@@@@@@@@@@@")
                return 4;
            }
            else {
                return targetLanguages.count
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        DispatchQueue.main.async() {
            
            if pickerView.tag == 1 {
                let lang: String = self.sourceLanguages[row]
                switch lang {
                case "Arabic":
                    self.pickerLabel.text = "ar"
                    self.translateToLabel.text = "en"
                case "English":
                    self.pickerLabel.text = "en"
                    self.targetLanguages = ["Arabic", "Portuguese", "French", "Spanish"]
                    pickerView.reloadAllComponents()
                case "Portuguese":
                    self.pickerLabel.text = "pt"
                    self.translateToLabel.text = "en"
                case "French":
                    self.pickerLabel.text = "fr"
                    self.translateToLabel.text = "en"
                case "Spanish":
                    self.pickerLabel.text = "es"
                    self.translateToLabel.text = "en"
                default:
                    print("Error")
                }
                //self.pickerLabel.text = self.sourceLanguages[row]
            }
            if pickerView.tag == 2 {
                self.translateToLabel.text = self.targetLanguages[row]
            }
            self.pickerLabel.isHidden = true
            self.translateToLabel.isHidden = true

        }
    }
    
    @IBAction func onPostTapped(_ sender: Any) {
        
        print("*********************************************")
         print(text.text ?? "")
        let someStr : String = text.text ?? ""
        let parameters = [
            "source": self.pickerLabel.text,
            "target": self.translateToLabel.text,
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
                                self.label.text = finalStr
                            }
                        }
                    }
                                        
                }
                catch {
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

