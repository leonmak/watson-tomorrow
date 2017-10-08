//
//  TalkVC.swift
//  Watson-Tomorrow
//
//  Created by Leon Mak on 7/10/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import UIKit

import Chatto
import ChattoAdditions


class TalkVC: BaseChatViewController {

    @IBOutlet weak var reponseLbl: UILabel!
    @IBOutlet weak var toggleTalkingBtn: UIButton!

    var chatInputPresenter: BasicChatInputBarPresenter!
    lazy private var baseMessageHandler: BaseMessageHandler = {
        return BaseMessageHandler()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.chatDataSource = WatsonManager.instance.dataSource
        super.chatItemsDecorator = ChatItemsDemoDecorator()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Speech to Text
    @IBAction func toggleTalkingBtnPressed(_ sender: Any) {
        if !WatsonManager.instance.isStreamingSpeech {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    func startRecording() {
        toggleTalkingBtn.setTitle("Send response", for: .normal)
        
        WatsonManager.instance.sendSpeech(completion: { results in
            let transcript = results.bestTranscript
            self.reponseLbl.text = transcript
            NSLog(transcript)
        })
    }
    
    func stopRecording() {
        toggleTalkingBtn.setTitle("Start Talking", for: .normal)
        
        WatsonManager.instance.stopSendingSpeech()
    }
    
    // MARK: - Chatto UI
    override func createChatInputView() -> UIView {
        let chatInputView = ChatInputBar.loadNib()
        var appearance = ChatInputBarAppearance()
        appearance.sendButtonAppearance.title = NSLocalizedString("Send", comment: "")
        appearance.textInputAppearance.placeholderText = NSLocalizedString("Send Emma a message", comment: "")
        self.chatInputPresenter = BasicChatInputBarPresenter(
            chatInputBar: chatInputView,
            chatInputItems: self.createChatInputItems(),
            chatInputBarAppearance: appearance
        )
        chatInputView.maxCharactersCount = 1000
        return chatInputView
    }

    func createChatInputItems() -> [ChatInputItemProtocol] {
        var items = [ChatInputItemProtocol]()
        items.append(self.createTextInputItem())
        // TODO: Append audio record
        // items.append(self.createAudioInputItem())
        return items
    }


    private func createTextInputItem() -> TextChatInputItem {
        let item = TextChatInputItem()
        item.textInputHandler = { text in
            WatsonManager.instance.sendReply(text)
        }
        return item
    }

    // MARK: Chatto Presenters
    override func createPresenterBuilders() -> [ChatItemType: [ChatItemPresenterBuilderProtocol]] {
        let textMessagePresenter = TextMessagePresenterBuilder(
            viewModelBuilder: DemoTextMessageViewModelBuilder(),
            interactionHandler: DemoTextMessageHandler(baseHandler: self.baseMessageHandler)
        )
        textMessagePresenter.baseMessageStyle = BaseMessageCollectionViewCellDefaultStyle()

        return [
            DemoTextMessageModel.chatItemType: [
                textMessagePresenter
            ]
        ]
    }

}

