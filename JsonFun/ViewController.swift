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
    
    let passwordManager = ViewController1()
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
    
    func customActivityIndicatory(_ viewContainer: UIView, startAnimate:Bool? = true) -> UIActivityIndicatorView {
        let mainContainer: UIView = UIView(frame: viewContainer.frame)
        mainContainer.center = viewContainer.center
        mainContainer.tag = 789456123
        mainContainer.isUserInteractionEnabled = false
        
        let viewBackgroundLoading: UIView = UIView(frame: CGRect(x:0,y: 0,width: 80,height: 80))
        viewBackgroundLoading.center = viewContainer.center
        viewBackgroundLoading.layer.cornerRadius = 15
        
        let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.frame = CGRect(x:0.0,y: 0.0,width: 40.0, height: 40.0)
        activityIndicatorView.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        activityIndicatorView.center = CGPoint(x: viewBackgroundLoading.frame.size.width / 2, y: viewBackgroundLoading.frame.size.height / 1.16)
        if startAnimate!{
            viewBackgroundLoading.addSubview(activityIndicatorView)
            mainContainer.addSubview(viewBackgroundLoading)
            viewContainer.addSubview(mainContainer)
            activityIndicatorView.startAnimating()
        }else{
            for subview in viewContainer.subviews{
                if subview.tag == 789456123{
                    subview.removeFromSuperview()
                }
            }
        }
        return activityIndicatorView
    }
    
    
    @IBAction func record(_ sender: Any) {
        text.text = ""
        //your SpeechToText service credentials
        let username = passwordManager.STTUsername
        let password = passwordManager.STTPassword
        let speechToText = SpeechToText(username: username, password: password)
        
        var settings = RecognitionSettings(contentType: .opus)
        settings.interimResults = true
        let failure = { (error: Error) in print(error) }
        speechToText.recognizeMicrophone(settings: settings, failure: failure) { results in
                print("poonation")
                print(results)
                self.text.text = (results.bestTranscript)
                print(failure)
                for result in results.results {
                    if result.final {
                    // stop transcribing microphone audio
                        speechToText.stopRecognizeMicrophone()
                    }
                }
            }
    }

    var audioPlayer = AVAudioPlayer() // see note below
    @IBAction func pronounceTouch(_ sender: Any) {
        let username = passwordManager.TTSUsername
        let password = passwordManager.TTSPassword
        let textToSpeech = TextToSpeech(username: username, password: password)
        let textToPronounce = self.label.text
        var voiceToPlay = SynthesisVoice.es_Enrique
        let targetLang = self.translateToLabel.text!
        print(targetLang)

        switch targetLang {
            case "en":
                voiceToPlay = SynthesisVoice(rawValue: SynthesisVoice.us_Michael.rawValue)!
            case "Portuguese":
                voiceToPlay = SynthesisVoice(rawValue: SynthesisVoice.br_Isabela.rawValue)!
            case "French":
                voiceToPlay = SynthesisVoice(rawValue: SynthesisVoice.fr_Renee.rawValue)!
            case "Spanish":
                voiceToPlay = SynthesisVoice(rawValue: SynthesisVoice.es_Enrique.rawValue)!
            default:
                voiceToPlay = SynthesisVoice(rawValue: SynthesisVoice.es_Enrique.rawValue)!
            }

        
        let failure = { (error: Error) in print(error) }
        print(failure)
        textToSpeech.synthesize(textToPronounce!,voice: voiceToPlay.rawValue, failure: failure) { data in
            self.audioPlayer = try! AVAudioPlayer(data: data)
            self.audioPlayer.prepareToPlay()
            print("prepare to play")
            print(self.audioPlayer)
            self.audioPlayer.play()

        }

        
    }
    
    
    @IBAction func onPostTapped(_ sender: Any) {
        label.text = ""
        let loader = customActivityIndicatory(self.view, startAnimate: false)
        label.layer.zPosition = 3
        loader.layer.zPosition = 1
        customActivityIndicatory(self.view, startAnimate: true)

        
        //get the text from the text field
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
        
        //OpenWhisk Web Action URL
        //guard let kituraUrl = URL(string: "http://localhost:8080/translates") else {return}
        //let OWurl = URL(string: "https://openwhisk.ng.bluemix.net/api/v1/web/Developer%20Advocate_dev/demo1/translate")
        
        let bluemixURL = URL(string: "https://getstartednode-inductionless-gamone.mybluemix.net/translates")
        
        //pass url we want to make request to
        var request = URLRequest(url: bluemixURL!)
        request.httpMethod = "POST"
        
        //convert JSON into JSON data
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {print("else");return}
        
        request.httpBody = httpBody
        //ensure server knows that we will pass in json
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            let returnData = String(data: data!, encoding: .utf8) //data to String
            DispatchQueue.main.async() {
                //output the translated Text
                self.label.isHidden = false
                self.label.text = returnData!
                self.customActivityIndicatory(self.view, startAnimate: false)
            }
        }.resume()
    }
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
