//
//  UserService.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/20.
//

import FirebaseDatabase

enum UserService {
    
    // MARK: - Fetch User Data
    
    static func fetchUserData(with userId: String? = nil, completion: @escaping (User) -> Void) {
        
        let uid = (userId != nil) ? userId : AuthService.shared.getCurrentUserUid()
        
        guard let uid = uid else { return }
        
        USERS_REF.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dict: dictionary)
            completion(user)
        }
    }
    
}

// MARK: - Fetch Users

extension UserService {
    
    static func fetchCurrentUsers(limit: UInt, completion: @escaping (User, String) -> Void) {
        
        USERS_REF.queryLimited(toLast: limit).observeSingleEvent(of: .value) { snapshot, _ in
            
            guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.forEach({ (snapshot) in
                let uid = snapshot.key
                
                self.fetchUserData(with: uid) { user in
                    completion(user, first.key)
                }
            })
        }
    }
    
    static func fetchOldUsers(_ userCurrentKey: String?, completion: @escaping (User, Int, String) -> Void) {
        USERS_REF.queryOrderedByKey().queryEnding(atValue: userCurrentKey).queryLimited(toLast: 5).observeSingleEvent(of: .value) { snapshot, _ in
            
            guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.removeAll(where: { $0.key == userCurrentKey })
            
            allObjects.forEach({ (snapshot) in
                let uid = snapshot.key
                
                if uid != userCurrentKey {
                    self.fetchUserData(with: uid) { user in completion(user, allObjects.count, first.key) }
                }
            })
        }
    }
    
    static func fetchSomeUsers(ref: DatabaseReference, id: String, completion: @escaping (DataSnapshot, [DataSnapshot]) -> Void) {
        ref.child(id).queryLimited(toLast: 4).observeSingleEvent(of: .value) { snapshot in
            guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            completion(first, allObjects)
        }
    }
    
    static func fetchSomeOldUsers(ref: DatabaseReference, id: String, key: String?, completion: @escaping (DataSnapshot, [DataSnapshot]) -> Void) {
        ref.child(id)
            .queryOrderedByKey()
            .queryEnding(atValue: key)
            .queryLimited(toLast: 5).observeSingleEvent(of: .value) { snapshot in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                completion(first, allObjects)
            }
    }
    
}

// MARK: - Fetch User Posts

extension UserService {
    
    static func fetchUserPosts(uid: String, completion: @escaping ([DataSnapshot]) -> Void) {
        USER_POSTS_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            completion(snapshot)
        }
    }
    
}



