//
//  ChatDataSource.swift
//  Watson-Tomorrow
//
//  Created by Leon Mak on 7/10/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import Chatto

class ChatDataSource: ChatDataSourceProtocol {
    var nextMessageId = 0
    var hasMoreNext = false
    var hasMorePrevious = false
    var chatItems: [ChatItemProtocol] = []
    weak var delegate: ChatDataSourceDelegateProtocol?
    
    func loadNext() {
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }
    
    func loadPrevious() {
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }
    
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: (Bool) -> Void) {
        let didAdjust = true
        completion(didAdjust)
    }
    
    func addTextMessage(_ text: String, isIncoming: Bool=false) {
        let uid = "\(self.nextMessageId)"
        self.nextMessageId += 1
        let message = createTextMessageModel(uid, text: text, isIncoming: isIncoming)
        chatItems.append(message)
        self.delegate?.chatDataSourceDidUpdate(self)
    }
}
