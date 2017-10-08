//
//  TalkVC.swift
//  Watson-Tomorrow
//
//  Created by Leon Mak on 7/10/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import UIKit
import SpeechToTextV1
import TextToSpeechV1
import AVFoundation

class TalkVC: UIViewController {

    @IBOutlet weak var reponseLbl: UILabel!
    @IBOutlet weak var toggleTalkingBtn: UIButton!
    
    var speechToText: SpeechToText!
    var speechToTextSession: SpeechToTextSession!
    var isStreamingSpeech = false
    
    var textToSpeech: TextToSpeech!
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWatson()
        
    }

    func setupWatson() {
        self.speechToText = SpeechToText(
            username: Credentials.Watson.SpeechToText.username,
            password: Credentials.Watson.SpeechToText.password
        )
        self.speechToTextSession = SpeechToTextSession(
            username: Credentials.Watson.SpeechToText.username,
            password: Credentials.Watson.SpeechToText.password
        )
        self.textToSpeech = TextToSpeech(
            username: Credentials.Watson.TextToSpeech.username,
            password: Credentials.Watson.TextToSpeech.password
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Speech to Text
    @IBAction func toggleTalkingBtnPressed(_ sender: Any) {
        if !isStreamingSpeech {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    func startRecording() {
        toggleTalkingBtn.setTitle("Send response", for: .normal)
        isStreamingSpeech = true
        
        var settings = RecognitionSettings(contentType: .opus)
        settings.interimResults = true
        
        speechToText.recognizeMicrophone(settings: settings, failure: { NSLog($0.localizedDescription) }) { results in
            let transcript = results.bestTranscript
            self.reponseLbl.text = transcript
            NSLog(transcript)
        }
    }
    
    func stopRecording() {
        toggleTalkingBtn.setTitle("Start Talking", for: .normal)
        isStreamingSpeech = false
        
        speechToText.stopRecognizeMicrophone()
    }
    
    // MARK: - Text to Speech
    func speak(text: String) {
        textToSpeech.synthesize(text, success: { data in
            self.audioPlayer = try! AVAudioPlayer(data: data)
            self.audioPlayer.play()
        })
    }
    
}

