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


class TalkVC: BaseChatViewController, UITabBarDelegate {

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
        
        showWelcomePrompt()
        setupBackBtn()
    }
    
    func setupBackBtn() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(TalkVC.backBtnPressed))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func backBtnPressed() {
        WatsonManager.instance.restartConvo()
        _ = navigationController?.popViewController(animated: true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showWelcomePrompt() {
        WatsonManager.instance.botInitialWelcome()
    }
    

    // MARK: - Chatto UI
    override func createChatInputView() -> UIView {
        let chatInputView = ChatInputBar.loadNib()
        var appearance = ChatInputBarAppearance()
        appearance.sendButtonAppearance.title = NSLocalizedString("Send", comment: "")
        appearance.textInputAppearance.placeholderText = NSLocalizedString("Ask Emma about money", comment: "")
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
        items.append(AudioInputItem(button: TalkButton()))
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

