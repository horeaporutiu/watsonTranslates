import UIKit
import Foundation

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var pickerView2: UIPickerView!
    @IBOutlet weak var pickerLabel: UILabel!
    @IBOutlet weak var text: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var translateToLabel: UILabel!
    @IBOutlet weak var topPhrases: UILabel!
    @IBOutlet weak var toneLabel: UILabel!
    let watson = Watson();
    let cloudant = Cloudant();
    let credentials = Credentials()
    var sourceLanguages = [ "Arabic", "English", "Portuguese", "French", "Spanish"]
    var targetLanguages = ["English"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1}

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            if (row == 1) {
                targetLanguages = ["Arabic", "Portuguese", "French", "Spanish"]
            }
            else {
                 targetLanguages = ["English"]
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
    @IBAction func pronounce(_ sender: Any) {
        self.watson.proTouch((Any).self, oneLabel: label, targetLabel: translateToLabel)
    }
    @IBAction func translate(_ sender: Any) {
        self.watson.translate(text: text, label: label, toneLabel: toneLabel, homeView: self.view, pickerLabel: pickerLabel, translateToLabel: translateToLabel )
    }
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false;
        cloudant.getTopPhrases(topPhrases: topPhrases);
    }
}


