//
//  AuthService.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/16.
//

import UIKit
import FirebaseAuth
import FirebaseMessaging
import FirebaseDatabaseInternal

// MARK: - AuthCredential

struct AuthCredential {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

// MARK: - AuthServiceDelegate

protocol AuthServiceDelegate: AnyObject {
    func sendErrorAlert(error: Error)
    func sendEmailVerifyAlert()
}

// MARK: - AuthService

final class AuthService {
    
    // MARK: - Properties
    
    static let shared: AuthService = AuthService()
    weak var delegate: AuthServiceDelegate?
    
    // MARK: - Init
    
    private init() {}
    
}

// MARK: - Log In

extension AuthService {
    
    func loginUser(with email: String, password: String, completion: @escaping () -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [unowned self] result, error in
            if let error = error {
                delegate?.sendErrorAlert(error: error)
                return
            }
            
            guard let result = result, result.user.isEmailVerified else {
                delegate?.sendEmailVerifyAlert()
                return
            }
            
            completion()
        }
    }
    
}


// MARK: - Register

extension AuthService {
    
    func createUser(withCredential credentials: AuthCredential, completion: @escaping ((Error?), DatabaseReference) -> Void) {
        
        let email = credentials.email
        let password = credentials.password
        
        ImageUploader.uploadImage(image: credentials.profileImage) { imageUrl in
            
            Auth.auth().createUser(withEmail: email, password: password) { [unowned self] result, error in
                if error != nil {
                    delegate?.sendErrorAlert(error: error!)
                    return
                }
                
                sendEmailVerify()
                
                guard let uid = result?.user.uid else { return }
                
                let dictionaryValues: [String: Any] = [
                    K.UserData.email: credentials.email,
                    K.UserData.fullname: credentials.fullname,
                    K.UserData.username: credentials.username,
                    K.UserData.profileImage: imageUrl
                ]
                
                let values = [uid: dictionaryValues]
                
                USERS_REF.updateChildValues(values, withCompletionBlock: completion)
            }
        }
    }
    
}

// MARK: - Reset Password

extension AuthService {
    
    func resetPassword(withEmail email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
}

// MARK: - Get Current User Id

extension AuthService {
    
    func getCurrentUserUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
}

// MARK: - Email Verify

extension AuthService {
    
    private func sendEmailVerify() {
        Auth.auth().currentUser?.sendEmailVerification(completion: { [unowned self] error in
            guard error == nil else { fatalError() }
            delegate?.sendEmailVerifyAlert()
        })
    }
    
}

