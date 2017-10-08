//
//  TextMessages.swift
//  Watson-Tomorrow
//
//  Created by Leon Mak on 7/10/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import Foundation
import ChattoAdditions

public class DemoTextMessageViewModelBuilder: ViewModelBuilderProtocol {
    public init() {}
    
    let messageViewModelBuilder = MessageViewModelDefaultBuilder()
    
    public func createViewModel(_ textMessage: DemoTextMessageModel) -> DemoTextMessageViewModel {
        let messageViewModel = self.messageViewModelBuilder.createMessageViewModel(textMessage)
        let textMessageViewModel = DemoTextMessageViewModel(textMessage: textMessage, messageViewModel: messageViewModel)
        textMessageViewModel.avatarImage.value = UIImage(named: "userAvatar")
        return textMessageViewModel
    }
    
    public func canCreateViewModel(fromModel model: Any) -> Bool {
        return model is DemoTextMessageModel
    }
}

public class DemoTextMessageViewModel: TextMessageViewModel<DemoTextMessageModel>, DemoMessageViewModelProtocol {
    public override init(textMessage: DemoTextMessageModel, messageViewModel: MessageViewModelProtocol) {
        super.init(textMessage: textMessage, messageViewModel: messageViewModel)
    }
    
    public var messageModel: DemoMessageModelProtocol {
        return self.textMessage
    }
}

open class TextMessageViewModel<TextMessageModelT: TextMessageModelProtocol>: TextMessageViewModelProtocol {
    public var text: String {
        return self.textMessage.text
    }
    public let textMessage: TextMessageModelT
    public let messageViewModel: MessageViewModelProtocol
    
    public init(textMessage: TextMessageModelT, messageViewModel: MessageViewModelProtocol) {
        self.textMessage = textMessage
        self.messageViewModel = messageViewModel
    }
    
    open func willBeShown() {
    }
    
    open func wasHidden() {
    }
}

// MARK: Text Message Model
public class DemoTextMessageModel: TextMessageModel<MessageModel>, DemoMessageModelProtocol {
    public override init(messageModel: MessageModel, text: String) {
        super.init(messageModel: messageModel, text: text)
    }

    public var status: MessageStatus {
        get {
            return self._messageModel.status
        }
        set {
            self._messageModel.status = newValue
        }
    }
}

func createTextMessageModel(_ uid: String, text: String, isIncoming: Bool) -> DemoTextMessageModel {
    let messageModel = createMessageModel(uid, isIncoming: isIncoming, type: TextMessageModel<MessageModel>.chatItemType)
    let textMessageModel = DemoTextMessageModel(messageModel: messageModel, text: text)
    return textMessageModel
}

func createMessageModel(_ uid: String, isIncoming: Bool, type: String) -> MessageModel {
    let senderId = isIncoming ? "1" : "2"
    let messageStatus = isIncoming || arc4random_uniform(100) % 3 == 0 ? MessageStatus.success : .failed
    let messageModel = MessageModel(uid: uid, senderId: senderId, type: type, isIncoming: isIncoming, date: Date(), status: messageStatus)
    return messageModel
}

extension TextMessageModel {
    static var chatItemType: String {
        return "text"
    }
}
