//
//  Message.swift
//  ChatRoom
//
//  Created by Max Livingston on 8/21/17.
//  Copyright © 2017 Max Livingston. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromId: String?
    var toId: String?
    var timeStamp: NSNumber?
    var text: String?
    
    func chatPartnerId() -> String? {
        
        //Sender or Reciever
        if fromId == Auth.auth().currentUser?.uid {
            return toId!
        }
        else{
            return fromId!
        }

    }
}
