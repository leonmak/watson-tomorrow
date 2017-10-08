//
//  ChatProtocols.swift
//  Watson-Tomorrow
//
//  Created by Leon Mak on 7/10/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import Chatto
import ChattoAdditions

public protocol DemoMessageViewModelProtocol {
    var messageModel: DemoMessageModelProtocol { get }
}

public protocol DemoMessageModelProtocol: MessageModelProtocol {
    var status: MessageStatus { get set }
}

