//
//  ViewController.swift
//  FBLoginDemo
//
//  Created by 季 雲 on 2017/04/28.
//  Copyright © 2017 Ericji. All rights reserved.
//

import UIKit
import SnapKit
import FBSDKCoreKit
import FBSDKLoginKit
import AWSCognito
import FirebaseAuth
import AWSLambda
import Apollo


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let faceBtn1 = UIButton()
        faceBtn1.setTitle("Facebook Login1", for: .normal)
        faceBtn1.setTitleColor(UIColor.white, for: .normal)
        faceBtn1.layer.cornerRadius = 10
        faceBtn1.layer.masksToBounds = true
        faceBtn1.backgroundColor = UIColor(red: 60.0/255.0, green: 90.0/255.0, blue: 149/255.0, alpha: 1.0)
        faceBtn1.addTarget(self, action: #selector(self.onTapFbBtn1(btn:)), for: .touchUpInside)
        self.view.addSubview(faceBtn1)
        faceBtn1.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        let faceBtn2 = FBSDKLoginButton()
        self.view.addSubview(faceBtn2)
        faceBtn2.snp.makeConstraints { (make) in
            make.width.height.centerX.equalTo(faceBtn1)
            make.centerY.equalTo(faceBtn1).offset(100)
        }
        
        
        let awsLambdaBtn = UIButton()
        awsLambdaBtn.backgroundColor = UIColor.orange
        awsLambdaBtn.setTitle("authorizeLambda", for: UIControlState())
        awsLambdaBtn.setTitleColor(UIColor.black, for: UIControlState())
        awsLambdaBtn.addTarget(self, action: #selector(self.authorizeLambda), for: .touchUpInside)
        self.view.addSubview(awsLambdaBtn)
        awsLambdaBtn.snp.makeConstraints { (make) in
            make.width.height.centerX.equalTo(faceBtn1)
            make.centerY.equalTo(faceBtn1).offset(-100)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onTapFbBtn1(btn: UIButton) {
        let loginMg = FBSDKLoginManager()
        loginMg.logOut()
        loginMg.logIn(withReadPermissions: ["public_profile", "email", "user_friends","user_birthday", "user_education_history", "user_hometown", "user_likes"], from: self) { (resultValue, fbError) in
            guard fbError == nil else {return}
            guard let result = resultValue else {return}
            guard result.isCancelled == false else {return}
            guard FBSDKAccessToken.current() != nil else {return}
            FBSDKAccessToken.setCurrent(result.token)
            let dictInfo = ["fields" : "id,name,birthday,education,email,location,languages,hometown,friends,religion,context.fields(mutual_friends)"]
            let request = FBSDKGraphRequest(graphPath: "me", parameters: dictInfo)
            request?.start(completionHandler: { (_, result, _) in
                print(result as! [String : Any])
            })
//            self.authorizeAWS()
            self.authorizeLambda()
            
        }
    }
    
    func authorizeAWS() {
        let provider = MyProvider(tokens: [AWSIdentityProviderFacebook : FBSDKAccessToken.current().tokenString])
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USWest2, identityPoolId: "us-west-2:e4591547-3f13-4eea-87fd-78884cf82e2f", identityProviderManager: provider)
        let configuration = AWSServiceConfiguration(region:.USWest2, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        credentialsProvider.getIdentityId().continueWith { (task) -> Any? in
            print(task.result)
            var request = URLRequest(url: URL(string: "https://nu48kxwf7a.execute-api.us-west-2.amazonaws.com/dev/firebaseLogin")!)
            request.httpMethod = "POST"
            
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                let result = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                print(result)
                let token = (result as! [String : String])["token"]
                
                FIRAuth.auth()?.signIn(withCustomToken: token!, completion: { (user, error) in
                    print(user)
                    print(error)
                })
                
            })
            task.resume()

            return nil
        }
    }
    
    func authorizeLambda() {
        let provider = MyProvider(tokens: [AWSIdentityProviderFacebook : FBSDKAccessToken.current().tokenString])
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USWest2, identityPoolId: "us-west-2:e4591547-3f13-4eea-87fd-78884cf82e2f", identityProviderManager: provider)
        let configuration = AWSServiceConfiguration(region:.USWest2, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        // lambda
        let lambdaInvoker = AWSLambdaInvoker.default()
        
        let filePath = Bundle.main.path(forResource: "test", ofType: "txt")
        let content = try! String(contentsOfFile: filePath!, encoding: String.Encoding.utf8)
        let string = content.components(separatedBy: "\n").joined(separator: "")
        
        let param = ["body": "{\"query\" : \"{  profile(query: {term: {bodyType: {value: \\\"99\\\"}}}) {    hits {      _source {        identityId        bloodType        photos {          photo {            type            url            urlType1            urlType2            approval            path          }          stamp {            use          }          cover {            type            path          }        }      }    }    count    aggregations    max_score    took    timed_out  }}\"}",
                     "httpMethod": "POST"] as [String : Any]
        lambdaInvoker.invokeFunction("RabbinSearch", jsonObject: param).continueWith { (task) -> Any? in
            print(task.result?["body"])
        }
        
        
    }

}

