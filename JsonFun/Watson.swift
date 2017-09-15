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

class Watson: UIViewController {

    let credentials = Credentials()
    let activityLoader = ActivityMonitor()
    var audioPlayer = AVAudioPlayer()
    
    func proTouch(_ sender: Any, oneLabel: UILabel, targetLabel: UILabel) {
        let username = credentials.TTSUsername
        let password = credentials.TTSPassword
        let textToSpeech = TextToSpeech(username: username, password: password)
        let textToPronounce = oneLabel.text
        var voiceToPlay = SynthesisVoice.es_Enrique
        let targetLang = targetLabel.text!
        
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
    
    func watsonRecord(_ sender: Any, text: UITextField) {
        text.text = ""
        //your SpeechToText service credentials
        let username = credentials.STTUsername
        let password = credentials.STTPassword
        let speechToText = SpeechToText(username: username, password: password)
        
        var settings = RecognitionSettings(contentType: .opus)
        settings.interimResults = true
        let failure = { (error: Error) in print(error) }
        speechToText.recognizeMicrophone(settings: settings, failure: failure) { results in
            print(results)
            text.text = (results.bestTranscript)
            print(failure)
            for result in results.results {
                if result.final {
                    // stop transcribing microphone audio
                    speechToText.stopRecognizeMicrophone()
                }
            }
        }

    }
    
    func toneAnalyzer(toneData: String, toneLabel: UILabel){
        let parameters = ["text": toneData]
        //OpenWhisk Web Action URL
        let OWurl = URL(string: "https://openwhisk.ng.bluemix.net/api/v1/web/Developer%20Advocate_dev/demo1/toneAnalyzer")
        var request = URLRequest(url: OWurl!)
        request.httpMethod = "POST"
        
        //convert JSON into JSON data
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {print("else");return}
        
        request.httpBody = httpBody
        //ensure server knows that we will pass in json
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                let returnData = String(data: data!, encoding: .utf8) //data to String
                print("toneAnalyzer returnData2: ")
                print(returnData!)
                if data != nil {
                    let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
                    let docTone = json?["document_tone"] as! [String:Any]
                    
                    let toneCategories = docTone["tone_categories"] as! [[String:AnyObject]]
                    toneLabel.text = "Your Tone \n \n"
                    DispatchQueue.main.async() {
                        for key in toneCategories {
                            if (key["tones"] != nil) {
                                let tonesArray = key["tones"] as! [[String:AnyObject]]
                                for key in tonesArray {
                                    if (key["score"] != nil) {
                                        let score = key["score"] as! Double
                                        if (score > 0.5){
                                            toneLabel.text = (toneLabel.text)! + (key["tone_name"] as! String) + ", Score: \(score) \n";
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
            }.resume()
    }
    
    func translate (text: UITextField, label: UILabel, toneLabel: UILabel, homeView: UIView, pickerLabel: UILabel, translateToLabel: UILabel) {
        
        var someStr : String = text.text ?? ""
        if (someStr.characters.count <= 0) {
            someStr = "You need to enter something to translate!"
        }
        
        //populate HTTP Body
        let parameters = [
            "source": pickerLabel.text,
            "target": translateToLabel.text,
            "text": someStr
        ]

        label.text = ""
        let loader = activityLoader.customActivityIndicatory(homeView, startAnimate: false)
        label.layer.zPosition = 3
        loader.layer.zPosition = 1
        self.activityLoader.customActivityIndicatory(homeView, startAnimate: true)

        //OpenWhisk Web Action URL
        guard let kituraUrl = URL(string: "http://localhost:8080/translates") else {return}
        let OWurl = URL(string: "https://openwhisk.ng.bluemix.net/api/v1/web/Developer%20Advocate_dev/demo1/translate")
        //let bluemixURL = URL(string: "https://getstartednode-inductionless-gamone.mybluemix.net/translates")
        
        //pass url we want to make request to
        var request = URLRequest(url: kituraUrl)
        request.httpMethod = "POST"
        
        //convert JSON into JSON data
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {print("else");return}
        
        request.httpBody = httpBody
        //ensure server knows that we will pass in json
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if data != nil {
                let returnData = String(data: data!, encoding: .utf8)
                DispatchQueue.main.async() {
                    //output the translated Text
                    label.isHidden = false
                    label.text = returnData
                    self.toneAnalyzer(toneData: parameters["text"]!!, toneLabel: toneLabel)
                    self.activityLoader.customActivityIndicatory(homeView, startAnimate: false)
                }
            }
            else {
                print("Invalid Data")
            }
            }.resume()

    }

}
