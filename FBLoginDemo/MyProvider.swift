//
//  MyProvider.swift
//  FBLoginDemo
//
//  Created by 季 雲 on 2017/06/20.
//  Copyright © 2017 Ericji. All rights reserved.
//

import UIKit
import AWSCognito
import AWSCore

class MyProvider: NSObject, AWSIdentityProviderManager {
    
    var tokens : [String : String]
    init(tokens: [String : String]) {
        self.tokens = tokens
    }
    func logins() -> AWSTask<NSDictionary> {
        return AWSTask(result: tokens as NSDictionary)
    }
}
