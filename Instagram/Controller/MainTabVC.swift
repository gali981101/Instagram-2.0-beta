//
//  MainTabVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/15.
//

import UIKit
import YPImagePicker

final class MainTabVC: UITabBarController {
    
    // MARK: - Properties
    
    private var isInitialLoad: Bool?
}

// MARK: - Life Cycle

extension MainTabVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        configureViewControllers()
        checkIfUserIsLoggedIn()
    }
    
}

// MARK: - Handlers

extension MainTabVC {
    
    func configureViewControllers() {
        
        let feedVC = constructNavController(
            unselectedImage: UIImage(systemName: K.SystemImageName.house)!,
            selectedImage: UIImage(systemName: K.SystemImageName.houseFill)!,
            rootViewController: FeedVC(viewSinglePost: false)
        )
        
        let searchVC = constructNavController(
            unselectedImage: UIImage(systemName: K.SystemImageName.magglass)!,
            selectedImage: UIImage(systemName: K.SystemImageName.magglass)!,
            rootViewController: SearchVC()
        )
        
        let imageSelectorVC = constructNavController(
            unselectedImage: UIImage(systemName: K.SystemImageName.plusapp)!,
            selectedImage: UIImage(systemName: K.SystemImageName.plusappFill)!
        )
        
        let notificationVC = constructNavController(
            unselectedImage: UIImage(systemName: K.SystemImageName.heart)!,
            selectedImage: UIImage(systemName: K.SystemImageName.heartFill)!,
            rootViewController: NotificationsVC()
        )
        
        let userProfileVC = constructNavController(
            unselectedImage: UIImage(systemName: K.SystemImageName.person)!,
            selectedImage: UIImage(systemName: K.SystemImageName.personFill)!,
            rootViewController: UserProfileVC()
        )
        
        viewControllers = [feedVC, searchVC, imageSelectorVC, notificationVC, userProfileVC]
        tabBar.tintColor = .label
    }
    
}

// MARK: - Service

extension MainTabVC {
    
    private func checkIfUserIsLoggedIn() {
        if AuthService.shared.getCurrentUserUid() == nil {
            DispatchQueue.main.async { [unowned self] in
                let loginVC = LoginVC()
                
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                
                present(navController, animated: true, completion: nil)
            }
        }
        return
    }
    
}

// MARK: - Helper Methods

extension MainTabVC {
    
    /// construct navigation controllers
    private func constructNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .label
        
        return navController
    }
    
    private func moveToYPImagePicker() {
        var config = YPImagePickerConfiguration()
        
        config.startOnScreen = .library
        config.shouldSaveNewPicturesToAlbum = false
        config.hidesStatusBar = false
        
        config.colors.tintColor = .systemBlue
        config.colors.bottomMenuItemSelectedTextColor = .systemBlue
        
        config.library.maxNumberOfItems = 10
        
        let picker = YPImagePicker(configuration: config)
        picker.modalPresentationStyle = .fullScreen
        
        present(picker, animated: true)
        
        didFinishPickingMedia(picker)
    }
    
    private func didFinishPickingMedia(_ picker: YPImagePicker) {
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if cancelled {
                self.selectedIndex = 0
                picker.dismiss(animated: true)
            } else {
                var photos: [UIImage] = []
                
                for item in items {
                    switch item {
                    case .photo(let photo):
                        photos.append(photo.image)
                    default:
                        break
                    }
                }
                
                picker.dismiss(animated: false) {
                    let uploadPostVC = UploadPostVC(selectedImages: photos, uploadAction: .UploadPost)
                    uploadPostVC.delegate = self
                    
                    let nav = UINavigationController(rootViewController: uploadPostVC)
                    nav.modalPresentationStyle = .fullScreen
                    
                    self.present(nav, animated: false)
                }
            }
        }
    }
    
}

// MARK: - UITabBarControllerDelegate

extension MainTabVC: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2 { moveToYPImagePicker() }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        
        if tabBarIndex == 0 {
            let nav = viewController as? UINavigationController
            let feedVC = nav?.viewControllers[0] as? FeedVC
            feedVC?.collectionView.setContentOffset(.zero, animated: true)
        }
    }
    
}

// MARK: - UploadPostVCDelegate

extension MainTabVC: UploadPostVCDelegate {
    
    func controllerDidDismiss(vc: UploadPostVC, action: UploadAction) {
        switch action {
        case .UploadPost:
            vc.dismiss(animated: true) { [weak self] in
                guard let self else { return }
                self.moveToYPImagePicker()
            }
        case .SaveChanges:
            vc.dismiss(animated: true)
        }
    }
    
    func sharePost(vc: UploadPostVC, action: UploadAction) {
        switch action {
        case .UploadPost:
            selectedIndex = 0
            vc.dismiss(animated: true)
        case .SaveChanges:
            vc.dismiss(animated: true)
        }
    }
    
}

