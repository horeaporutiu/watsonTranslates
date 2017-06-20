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
            }
            if pickerView.tag == 2 {
                self.translateToLabel.text = self.targetLanguages[row]
            }
            self.pickerLabel.isHidden = true
            self.translateToLabel.isHidden = true
            
        }
    }
    
    @IBAction func onPostTapped(_ sender: Any) {
        
        let someStr : String = text.text ?? ""
        let parameters = [
            "source": self.pickerLabel.text,
            "target": self.translateToLabel.text,
            "text": someStr
        ]
        guard let url = URL(string: "http://localhost:8080/translates") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            let returnData = String(data: data!, encoding: .utf8) //data to String
            DispatchQueue.main.async() {
                //output the translated Text
                self.label.text = returnData!
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
