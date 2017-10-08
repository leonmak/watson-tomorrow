//
//  TalkButton.swift
//  Watson-Tomorrow
//
//  Created by Leon Mak on 8/10/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

class TalkButton: UIButton {

    @objc func toggleTalkingBtnPressed(_ sender: Any) {
        if !WatsonManager.instance.isStreamingSpeech {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    func startRecording() {
        self.setTitle(">", for: .normal)
        self.sizeToFit()

        WatsonManager.instance.sendSpeech(completion: { results in
            let transcript = results.bestTranscript
            WatsonManager.instance.sendReply(transcript)
            NSLog(transcript)
        })
    }
    
    func stopRecording() {
        self.setTitle("Talk", for: .normal)
        self.sizeToFit()

        WatsonManager.instance.stopSendingSpeech()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setTitle("Talk", for: .normal)
        self.setTitleColor(UIColor.blue, for: .normal)
        self.sizeToFit()
        self.addTarget(self, action: #selector(self.toggleTalkingBtnPressed(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


open class AudioInputItem {
    typealias Class = AudioInputItem
    public var button: UIButton
    
    public init(button: UIButton) {
        self.button = button
    }
    
    open var selected = false {
        didSet {
            if selected {
                button.layer.opacity = 0.5
            } else {
                button.layer.opacity = 1
            }
        }
    }
}

extension AudioInputItem: ChatInputItemProtocol {
    public var presentationMode: ChatInputItemPresentationMode {
        return .none
    }
    
    public var showsSendButton: Bool {
        return false
    }
    
    public var inputView: UIView? {
        return nil
    }
    
    public var tabView: UIView {
        return self.button
    }
    
    public func handleInput(_ input: AnyObject) {
        return
    }
}
