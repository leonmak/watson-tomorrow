//
//  File.swift
//  Watson-Tomorrow
//
//  Created by Leon Mak on 7/10/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import AVFoundation

import SpeechToTextV1
import TextToSpeechV1
import ConversationV1

class WatsonManager {
    static let instance = WatsonManager()
    
    var audioPlayer: AVAudioPlayer!
    
    var textToSpeech: TextToSpeech!
    
    var isStreamingSpeech = false
    var speechToText: SpeechToText!
    var speechToTextSession: SpeechToTextSession!
    var settings = RecognitionSettings(contentType: .opus)
    
    var conversation: Conversation!
    var convoContext: Context?
    var dataSource = ChatDataSource()
    
    private init() {
        setupWatson()
    }
    
    // MARK: Speech
    func sendSpeech(completion: @escaping (SpeechRecognitionResults) -> Void) {
        isStreamingSpeech = true
        speechToText.recognizeMicrophone(settings: settings, failure: { NSLog($0.localizedDescription) }) { results in
            completion(results)
        }
    }
    
    func stopSendingSpeech() {
        isStreamingSpeech = false
        speechToText.stopRecognizeMicrophone()
    }
    
    // MARK: User reply
    func sendReply(_ message: String, completion: (((MessageResponse) -> Void)?)=nil ) {
        NSLog("Sending text: " + message)
        self.dataSource.addTextMessage(message)
        let request = MessageRequest(text: message, context: convoContext)
        self.conversation.message(withWorkspace: Credentials.Watson.Conversation.workspace, request: request) { response in
            DispatchQueue.main.async {
                self.botRespond(response)
                if let handler = completion{
                    handler(response)
                }
            }
        }
    }
    
    // MARK: Emma reply
    func botRespond(_ response: MessageResponse) {
        NSLog("Received Response: " + response.json.description)
        
        // TODO: check if ended
        self.convoContext = response.context
        if didHandleMultipleResponses() {
            return
        }
        
        response.output.text.forEach { outputText in
            self.botReplySpeech(outputText)
        }
        
        didHandleAnalytics()
        
    }
    
    func didHandleAnalytics() {
        if let apiToCall = self.convoContext?.json["ApiToCall"] as? String {
            DataManager.instance.getAnalyticsForSavings(fromApi: apiToCall) { insights in
                insights.forEach {self.botReplySpeech($0)}
            }
        }
    }
    
    func didHandleMultipleResponses() -> Bool {
        if let allResponses = self.convoContext?.json["AllResponses"] as? [String], allResponses.count > 0 {
            allResponses.forEach { botReplySpeech($0) }
            return true
        }
        return false
    }
    func botInitialWelcome() {
        botReplySpeech(Constants.welcomeMessage)
    }
    
    func botReplySpeech(_ message: String) {
        self.dataSource.addTextMessage(message, isIncoming: true)
        speak(text: message)
    }

    func restartConvo() {
        self.dataSource = ChatDataSource()
        self.convoContext = nil
        stopSendingSpeech()
    }
    
    // MARK: - Text to Speech
    func speak(text: String) {
        textToSpeech.getVoice(SynthesisVoice.es_Laura.rawValue) { voice in
            let guid = voice.customization?.customizationID
            self.textToSpeech.synthesize(text, voice: SynthesisVoice.gb_Kate.rawValue, customizationID: guid, success: { data in
                print("playing", data)
                self.audioPlayer = try! AVAudioPlayer(data: data)
                self.audioPlayer.play()
            })
        }
    }

    private func setupWatson() {
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
        self.conversation = Conversation(
            username: Credentials.Watson.Conversation.username,
            password: Credentials.Watson.Conversation.password,
            version: Credentials.Watson.Conversation.version
        )
        self.convoContext = nil
        self.settings.interimResults = true
    }

    
}
