//
//  Constants.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/14.
//

import Firebase
import FirebaseStorage
import FirebaseDatabaseInternal

// MARK: - Root References

let DB_REF = Database.database().reference()
let STORAGE_REF = Storage.storage().reference()

// MARK: - Storage References

let STORAGE_PROFILE_IMAGES_REF: StorageReference = STORAGE_REF.child(K.FStorage.profile)
let STORAGE_POST_IMAGES_REF: StorageReference = STORAGE_REF.child(K.FStorage.posts)
let STORAGE_MESSAGE_IMAGES_REF: StorageReference = STORAGE_REF.child(K.FStorage.message)
let STORAGE_MESSAGE_VIDEO_REF: StorageReference = STORAGE_REF.child(K.FStorage.videoMessage)

// MARK: - Database References

let USERS_REF = DB_REF.child(K.Database.users)

let USER_FOLLOWER_REF = DB_REF.child(K.Database.followers)
let USER_FOLLOWING_REF = DB_REF.child(K.Database.following)

let POSTS_REF = DB_REF.child(K.Database.posts)
let USER_POSTS_REF = DB_REF.child(K.Database.userPosts)

let USER_FEED_REF = DB_REF.child(K.Database.userFeed)

let USER_LIKES_REF = DB_REF.child(K.Database.userLikes)
let POST_LIKES_REF = DB_REF.child(K.Database.postLikes)

let COMMENT_REF = DB_REF.child(K.Database.comments)

let NOTIFICATIONS_REF = DB_REF.child(K.Database.notifications)

let MESSAGES_REF = DB_REF.child(K.Database.messages)
let USER_MESSAGES_REF = DB_REF.child(K.Database.userMessages)
let USER_MESSAGE_NOTIFICATIONS_REF = DB_REF.child(K.Database.userMessageNotifications)

let HASHTAG_POST_REF = DB_REF.child(K.Database.hashtagPost)

// MARK: - K

enum K {
    
    static let instagram = "Instagram"
    
    // MARK: - Cell Identifier
    
    enum CellId {
        static let feedCell = "FeedCell"
        static let commentCell = "CommentCell"
        static let searchUserCell = "SearchUserCell"
        static let searchPostCell = "SearchPostCell"
        static let notificationCell = "NotificationCell"
        static let postImageCell = "PostImageCell"
        static let userPostCell = "UserPostCell"
        static let followCell = "FollowCell"
    }
    
    // MARK: - Header Identifier
    
    enum HeaderId {
        static let profileHeader = "userProfileHeader"
    }
    
    // MARK: - VC Name
    
    enum VCName {
        static let uploadPost = "Upload Post"
        static let editPost = "Edit Post"
        static let followers = "Followers"
        static let following = "Following"
        static let likes = "Likes"
        static let comment = "Comment"
        static let notifications = "Notifications"
    }
    
    // MARK: - ImageNames
    
    enum ImageNames {
        static let igLogo = "InstagramLogo"
        static let plusPhoto = "plus_photo"
    }
    
    // MARK: - SystemImageName
    
    enum SystemImageName {
        static let heart = "heart"
        static let heartFill = "heart.fill"
        static let message = "message"
        static let paperplane = "paperplane"
        static let circleSlash = "circle.slash"
        static let eyeSlash = "eye.slash"
        static let pencil = "pencil"
        static let trash = "trash"
        static let house = "house"
        static let houseFill = "house.fill"
        static let magglass = "magnifyingglass"
        static let plusapp = "plus.app"
        static let plusappFill = "plus.app.fill"
        static let person = "person"
        static let personFill = "person.fill"
        static let gridSplit = "squareshape.split.3x3"
        static let gridFill = "square.grid.3x3.fill"
        static let personCircle = "person.crop.circle"
        static let personSquare = "person.crop.square"
        static let personSquareFill = "person.crop.square.fill"
        static let bookmark = "bookmark"
        static let bookmarkFill =  "bookmark.fill"
        static let arrowTurnLeft = "arrow.uturn.left"
        static let chevronLeft = "chevron.left"
    }
    
    // MARK: - Space
    
    enum String {
        static let empty = ""
        static let oneSpace = " "
        static let hashtag = "#"
        static let mention = "@"
    }
    
    // MARK: - LabelText
    
    enum LabelText {
        static let username = "Username"
        static let fullname = "Fullname"
        static let likesnum = "3 likes"
        static let postTime = "2 DAYS AGO"
        static let characterCount = "0/500"
    }
    
    // MARK: - Date
    
    enum DateText {
        static let second = "SECOND"
        static let min = "MIN"
        static let hour = "HOUR"
        static let day = "DAY"
        static let week = "WEEK"
        static let month = "MONTH"
        static let s = "S"
        static let ago = "AGO"
    }
    
    // MARK: - Alert Title
    
    enum AlertTitle {
        static let signUpError = "Registration Error"
        static let loginError = "Login Error"
        static let success = "Success"
        static let error = "Error"
        static let options = "Edit Or Delete Post ?"
    }
    
    // MARK: - Action Title
    
    enum ActionText {
        static let ok = "OK"
        static let cancel = "Cancel"
        static let logout = "Log Out"
        static let edit = "Edit"
        static let delete = "Delete Post?"
    }
    
    // MARK: - AttributedTitle
    
    enum AttributedTitle {
        static let dontHaveAccount = "Don't have an account?  "
        static let alreadyHaveAccount = "Already have an account?  "
    }
    
    // MARK: - ButtonTitle
    
    enum ButtonTitle {
        static let login = "Login"
        static let signUp = "Sign Up"
        static let logout = "Logout"
        static let threeDots = "•••"
        static let back = "Back"
        static let share = "Share"
        static let saveChanges = "Save Changes"
        static let loading = "Loading"
        static let editProfile = "Edit Profile"
        static let username = "Username"
    }
    
    // MARK: - TextField Placeholder
    
    enum TextFieldPlaceholder {
        static let email = "Email"
        static let password = "Password"
        static let fullname = "Fullname"
        static let username = "Username"
    }
    
    // MARK: - TextView Placeholder
    
    enum TextViewPlaceholder {
        static let enterCaption = "Write some.."
        static let enterComment = "Share your thoughts.."
    }
    
    // MARK: - Attributed String
    
    enum AttributedString {
        static let posts = "posts"
        static let followers = "followers"
        static let following = "following"
    }
    
    // MARK: - Animation
    
    enum Animation {
        static let tScale = "transform.scale"
        static let pulse = "pulse"
    }
    
    // MARK: - Notification Center
    
    enum NotificationCenter {
        static let updateFeed = "updateFeed"
    }
    
    // MARK: - UserData
    
    enum UserData {
        static let uid = "uid"
        static let fcmToken = "fcmToken"
        static let profileImage = "profileImageUrl"
        static let email = "email"
        static let fullname = "fullname"
        static let username = "username"
    }
    
    // MARK: - FollowStats
    
    enum FollowStats {
        static let follow = "Follow"
        static let following = "Following"
    }
    
    // MARK: - Post
    
    enum Post {
        static let caption = "caption"
        static let creationDate = "creationDate"
        static let likes = "likes"
        static let imageUrls = "imageUrls"
        static let ownerUid = "ownerUid"
        static let ownerImageUrl = "ownerImageUrl"
        static let ownerUsername = "ownerUsername"
        static let postId = "postId"
        static let postLikes = "post-likes"
        static let comments = "comments"
    }
    
    // MARK: - Comment
    
    enum Comment {
        static let uid = "uid"
        static let commentId = "commentId"
        static let commentText = "commentText"
        static let creationDate = "creationDate"
    }
    
    // MARK: - Notification
    
    enum Notification {
        static let checked = "checked"
        static let creationDate = "creationDate"
        static let uid = "uid"
        static let type = "type"
        static let postId = "postId"
        static let commentId = "commentId"
        static let notificationId = "notificationId"
    }
    
    // MARK: - Notification description
    
    enum NotifyDescription {
        static let like = " liked your post"
        static let comment = " commented on your post"
        static let follow = " started following you"
        static let commentMention = " mentioned you in a comment"
        static let postMention = " mentioned you in a post"
    }
    
    // MARK: - FStorage
    
    enum FStorage {
        static let contentType = "image/jpg"
        static let profile = "profile_images"
        static let posts = "post_images"
        static let message = "message_images"
        static let videoMessage = "video_messages"
    }
    
    // MARK: - Realtime Database
    
    enum Database {
        static let users = "users"
        static let followers = "user-followers"
        static let following = "user-following"
        static let posts = "posts"
        static let userPosts = "user-posts"
        static let userFeed = "user-feed"
        static let userLikes = "user-likes"
        static let postLikes = "post-likes"
        static let comments = "comments"
        static let notifications = "notifications"
        static let messages = "messages"
        static let userMessages = "user-messages"
        static let userMessageNotifications = "user-message-notifications"
        static let hashtagPost = "hashtag-post"
    }
    
    // MARK: - EmailVerify
    
    enum EmailVerify {
        static let signTitle = "Email Verification"
        static let signMessage = "We've just sent a confirmation email to your email address. Please check your inbox and click the verification link in that email to complete the sign up."
        static let logMessage = "You haven't confirmed your email address yet. We sent you a confirmation email wh en you sign up. Please click the verification link in that email. If you need us t o send the confirmation email again, please tap Resend Email."
        static let resend = "Resend email"
        static let resetPasswordSuccess = "We sent a link to your email to reset your password."
    }
    
}

// MARK: - Decoding Values

let LIKE_INT_VALUE = 0
let COMMENT_INT_VALUE = 1
let FOLLOW_INT_VALUE = 2
let COMMENT_MENTION_INT_VALUE = 3
let POST_MENTION_INT_VALUE = 4

// MARK: - Helper Methods

func getDatabaseReference(viewingMode: ViewingMode?) -> DatabaseReference? {
    guard let viewingMode = viewingMode else { return nil }
    
    switch viewingMode {
    case .Followers: return USER_FOLLOWER_REF
    case .Following: return USER_FOLLOWING_REF
    case .Likes: return POST_LIKES_REF
    }
}


