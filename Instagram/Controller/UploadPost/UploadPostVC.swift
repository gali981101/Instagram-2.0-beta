//
//  UploadPostVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/18.
//

import UIKit
import IQKeyboardManagerSwift

private let postImageCell = K.CellId.postImageCell

// MARK: - UploadAction

enum UploadAction: Int {
    case UploadPost
    case SaveChanges
    
    init(index: Int) {
        switch index {
        case 0: self = .UploadPost
        case 1: self = .SaveChanges
        default: self = .UploadPost
        }
    }
}

// MARK: - UploadPostVC

final class UploadPostVC: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: UploadPostVCDelegate?
    
    private var selectedImages: [UIImage]?
    private var uploadAction: UploadAction!
    private var postToEdit: Post?
    
    // MARK: - UIElement
    
    private lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(PostImageCell.self, forCellWithReuseIdentifier: postImageCell)
        
        cv.dataSource = self
        cv.delegate = self
        
        cv.backgroundColor = .systemBackground
        cv.showsHorizontalScrollIndicator = false
        
        return cv
    }()
    
    private lazy var captionTextView: InputTextView = {
        let tv = InputTextView()
        
        tv.placeholderShouldCenter = false
        tv.placeholderText = K.TextViewPlaceholder.enterCaption
        
        tv.font = UIFont.preferredFont(forTextStyle: .callout)
        tv.delegate = self
        
        return tv
    }()
    
    private lazy var characterCountLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .lightGray
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.text = K.LabelText.characterCount
        
        return label
    }()
    
    private lazy var actionButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(
            title: K.ButtonTitle.share,
            style: .done,
            target: self,
            action: #selector(handleUploadAction)
        )
        
        barButton.tintColor = .systemBlue
        barButton.isEnabled = false
        
        return barButton
    }()
    
    // MARK: - init
    
    init(selectedImages: [UIImage]? = nil, uploadAction: UploadAction!, postToEdit: Post? = nil) {
        self.selectedImages = selectedImages
        self.uploadAction = uploadAction
        self.postToEdit = postToEdit
        
        super.init(nibName: nil, bundle: nil)
        imageCollectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Life Cycle

extension UploadPostVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViewController(forUploadAction: uploadAction)
    }
    
}

// MARK: - Set Up

extension UploadPostVC {
    
    private func style() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(imageCollectionView)
        view.addSubview(captionTextView)
        view.addSubview(characterCountLabel)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: K.ButtonTitle.back,
            style: .done,
            target: self,
            action: #selector(handleCancel)
        )
        
        navigationItem.rightBarButtonItem = actionButton
        navigationItem.rightBarButtonItem?.tintColor = .systemBlue
        
        imageCollectionView.delegate = self
        imageCollectionView.layer.cornerRadius = 10
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        self.hideKeyboardWhenTappedAround()
    }
    
    private func layout() {
        imageCollectionView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 12,
            paddingLeft: 12,
            paddingRight: 12,
            height: 260
        )
        
        captionTextView.anchor(
            top: imageCollectionView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 16,
            paddingLeft: 12,
            paddingRight: 12,
            height: 150
        )
        
        characterCountLabel.anchor(
            bottom: captionTextView.bottomAnchor,
            right: view.rightAnchor,
            paddingBottom: -20,
            paddingRight: 12
        )
    }
    
}

// MARK: - @objc Actions

extension UploadPostVC {
    
    @objc private func handleUploadAction() {
        buttonSelector(uploadAction: uploadAction)
    }
    
    @objc private func handleCancel() {
        delegate?.controllerDidDismiss(vc: self, action: self.uploadAction)
    }
    
}

// MARK: - Handlers

extension UploadPostVC {
    
    private func configureViewController(forUploadAction uploadAction: UploadAction) {
        if uploadAction == .SaveChanges {
            guard let post = self.postToEdit else { return }
            
            self.navigationItem.title = K.VCName.editPost
            self.navigationItem.rightBarButtonItem?.title = K.ButtonTitle.saveChanges
            
            captionTextView.text = post.caption
        } else {
            self.navigationItem.title = K.VCName.uploadPost
            self.navigationItem.rightBarButtonItem?.title = K.ButtonTitle.share
        }
    }
    
}

// MARK: - Service

extension UploadPostVC {
    
    private func handleUploadPost() {
        showLoader(true)
        
        guard
            let caption = captionTextView.text,
            let images = selectedImages else { return }
        
        PostService.uploadPost(caption: caption, images: images) { [weak self] postKey in
            guard let self else { return }
            
            showLoader(false)
            
            if caption.contains(K.String.mention) {
                self.uploadHashtagToServer(withPostId: postKey)
            }
            
            if caption.contains(K.String.hashtag) {
                self.uploadMentionNotification(forPostId: postKey, withText: caption, isForComment: false)
            }
            
            delegate?.sharePost(vc: self, action: .UploadPost)
        }
    }
    
    private func handleSavePostChanges() {
    }
    
    private func uploadHashtagToServer(withPostId postId: String) {
        guard let caption = captionTextView.text else { return }
        let words: [String] = caption.components(separatedBy: .whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix(K.String.hashtag) {
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                
                let hashtagValues = [postId: 1]
                HASHTAG_POST_REF.child(word.lowercased()).updateChildValues(hashtagValues)
            }
        }
    }
    
}

// MARK: - Helper Methods

extension UploadPostVC {
    
    private func buttonSelector(uploadAction: UploadAction) {
        switch uploadAction {
        case .UploadPost:
            handleUploadPost()
        case .SaveChanges:
            handleSavePostChanges()
        }
    }
    
    private func checkMaxLength(_ textView: UITextView) {
        if (textView.text.count) > 500 { textView.deleteBackward() }
    }
    
    private func beginEditingLayout() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        
        imageCollectionView.removeFromSuperview()
        
        captionTextView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingLeft: 12,
            paddingRight: 12
        )
    }
    
    private func endEditingLayout() {
        captionTextView.removeFromSuperview()
        style()
        layout()
        
        self.view.layoutIfNeeded()
    }
    
}

// MARK: - UICollectionViewDataSource

extension UploadPostVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postImageCell, for: indexPath) as! PostImageCell
        
        guard let images = selectedImages else { return UICollectionViewCell() }
        
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 10
        
        cell.postImageView.image = images[indexPath.item]
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension UploadPostVC: UICollectionViewDelegate {
}

// MARK: - UICollectionViewDelegateFlowLayout

extension UploadPostVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width:  imageCollectionView.frame.width / 2,
            height: imageCollectionView.frame.height
        )
    }
    
}

// MARK: - UITextViewDelegate

extension UploadPostVC: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        beginEditingLayout()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        checkMaxLength(textView)
        
        let count = textView.text.count
        characterCountLabel.text = "\(count)/500"
        
        guard !textView.text.isEmpty else {
            actionButton.isEnabled = false
            return
        }
        
        actionButton.isEnabled = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        endEditingLayout()
    }
    
}
