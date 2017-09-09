//
//  ViewController.swift
//  JsonFun
//
//  Created by Horea Porutiu on 6/6/17.
//  Copyright © 2017 Horea Porutiu. All rights reserved.
//
import UIKit
import Foundation
import SpeechToTextV1
import TextToSpeechV1
import AVFoundation

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerView2: UIPickerView!
    @IBOutlet weak var pickerLabel: UILabel!
    @IBOutlet weak var text: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var translateToLabel: UILabel!
    @IBOutlet weak var topPhrases: UILabel!
    @IBOutlet weak var toneLabel: UILabel!
    
    let watson = Watson();

    let credentials = Credentials()
    let activityLoader = ActivityMonitor()
    
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
                return 4;
            }
            else {
                return targetLanguages.count
            }
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        DispatchQueue.main.async() {
            //Watson translates from English to Arabic,Port,French,Span, but not the other way
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
            }
            if pickerView.tag == 2 {
                self.translateToLabel.text = self.targetLanguages[row]
            }
            self.pickerLabel.isHidden = true
            self.translateToLabel.isHidden = true
        }
    }

    @IBAction func record(_ sender: Any) {
        self.watson.watsonRecord((Any).self, text: text)
    }

    @IBAction func pronounceTouch(_ sender: Any) {
        self.watson.proTouch((Any).self, oneLabel: label, targetLabel: translateToLabel)
    }
    
    @IBAction func onPostTapped(_ sender: Any) {

        var someStr : String = text.text ?? ""
        if (someStr.characters.count <= 0) {
            someStr = "You need to enter something to translate!"
        }
        
        //populate HTTP Body
        let parameters = [
            "source": self.pickerLabel.text,
            "target": self.translateToLabel.text,
            "text": someStr
        ]
        
        self.watson.translate(text: text, label: label, parameters: parameters, toneLabel: toneLabel, homeView: self.view)
    }
    
    override func viewDidLoad() {
        
        self.automaticallyAdjustsScrollViewInsets = false;
        
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
                        self.topPhrases.text = "Popular Phrases \n \n"
                        for event in phrases {
                            if(i==5){break}
                            print(event["phrase"] as! String)
                            self.topPhrases.text = (self.topPhrases.text)! + (event["phrase"] as? String)! + "\n"
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


