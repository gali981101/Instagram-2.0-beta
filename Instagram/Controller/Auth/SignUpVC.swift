//
//  SignUpVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/15.
//

import UIKit
import PhotosUI
import IQKeyboardManagerSwift

final class SignUpVC: UIViewController {
    
    // MARK: - Properties
    
    private var profileImage: UIImage?
    
    // MARK: - UIElement
    
    private lazy var plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(
            UIImage(named: K.ImageNames.plusPhoto),
            for: .normal
        )
        
        button.tintColor = .white
        
        button.addTarget(
            self,
            action: #selector(handleSelectProfilePhoto),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var emailTextField: UITextField = {
        let field = TextFieldFactory
            .makeAuthField(K.TextFieldPlaceholder.email)
        
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        
        return field
    }()
    
    private lazy var passwordTextField: UITextField = {
        let field = TextFieldFactory
            .makeAuthField(K.TextFieldPlaceholder.password)
        
        field.isSecureTextEntry = true
        field.textContentType = .oneTimeCode
        field.returnKeyType = .next
        
        return field
    }()
    
    private lazy var fullnameTextField: UITextField = {
        let field = TextFieldFactory
            .makeAuthField(K.TextFieldPlaceholder.fullname)
        
        field.returnKeyType = .next
        
        return field
    }()
    
    private lazy var usernameTextField: UITextField = {
        let field = TextFieldFactory
            .makeAuthField(K.TextFieldPlaceholder.username)
        
        field.returnKeyType = .done
        
        return field
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = ButtonFactory
            .makeAuthButton(K.ButtonTitle.signUp)
        
        button.isEnabled = false
        
        button.addTarget(
            self,
            action: #selector(handleSignUp),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.attributedTitle(
            firstPart: K.AttributedTitle.alreadyHaveAccount,
            secondPart: K.ButtonTitle.login
        )
        
        button.addTarget(
            self,
            action: #selector(handleShowLogin),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            fullnameTextField,
            usernameTextField,
            signUpButton
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 20
        
        return stackView
    }()
    
}

// MARK: - Life Cycle

extension SignUpVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AuthService.shared.delegate = self
        style()
        layout()
    }
    
}

// MARK: - Set Up

extension SignUpVC {
    
    private func style() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        configGradientLayer()
        
        [emailTextField, passwordTextField, fullnameTextField, usernameTextField]
            .forEach { field in
                field.delegate = self
                field.addTarget(self, action: #selector(formValidation), for: .editingChanged)
            }
        
        [plusPhotoButton, stackView, alreadyHaveAccountButton]
            .forEach(view.addSubview(_:))
        
        self.hideKeyboardWhenTappedAround()
    }
    
    private func layout() {
        plusPhotoButton.centerX(inView: view)
        plusPhotoButton.setDimensions(height: 140, width: 140)
        
        plusPhotoButton.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            paddingTop: 32
        )
        
        stackView.anchor(
            top: plusPhotoButton.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 32,
            paddingLeft: 32,
            paddingRight: 32
        )
        
        alreadyHaveAccountButton.centerX(inView: view)
        
        alreadyHaveAccountButton.anchor(
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            paddingBottom: 20
        )
    }
    
}

// MARK: - @objc Actions

extension SignUpVC {
    
    @objc private func handleSelectProfilePhoto() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    @objc private func handleSignUp() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        guard let profileImage = self.profileImage else { return }
        
        let credentials = AuthCredential(
            email: email,
            password: password,
            fullname: fullname,
            username: username,
            profileImage: profileImage
        )
        
        AuthService.shared.createUser(withCredential: credentials) { [unowned self] error, ref in
            if error != nil {
                let alert = AlertFactory.makeSignUpErrorAlert(message: error!.localizedDescription)
                self.present(alert, animated: true)
            }
            view.endEditing(true)
        }
    }
    
    @objc private func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func formValidation() {
        guard
            emailTextField.hasText,
            passwordTextField.hasText,
            fullnameTextField.hasText,
            usernameTextField.hasText, let _ = profileImage else {
            
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = ThemeColor.blue.withAlphaComponent(0.5)
            
            signUpButton.setTitleColor(
                UIColor(white: 1, alpha: 0.64),
                for: .normal
            )
            
            return
        }
        
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = ThemeColor.blue
        
        signUpButton.setTitleColor(
            UIColor(white: 1, alpha: 1),
            for: .normal
        )
    }
    
}

// MARK: - UITextFieldDelegate

extension SignUpVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string == K.String.oneSpace ? false : true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            textField.resignFirstResponder()
            fullnameTextField.becomeFirstResponder()
        case fullnameTextField:
            textField.resignFirstResponder()
            usernameTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        
        return false
    }
    
}

// MARK: - PHPickerViewControllerDelegate

extension SignUpVC: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProviders = results.map(\.itemProvider)
        
        guard let itemProvider = itemProviders.first,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.white.cgColor
        plusPhotoButton.layer.borderWidth = 2
        
        plusPhotoButton.imageView?.contentMode = .scaleAspectFill
        
        itemProvider.loadObject(ofClass: UIImage.self) { [unowned self] (image, error) in
            DispatchQueue.main.async { [unowned self] in
                guard let image = image as? UIImage else { return }
                profileImage = image
                plusPhotoButton.setImage(image
                    .withRenderingMode(.alwaysOriginal), for: .normal)
                formValidation()
            }
        }
    }
    
}

// MARK: - AuthServiceDelegate

extension SignUpVC: AuthServiceDelegate {
    
    func sendErrorAlert(error: any Error) {
        let alert = AlertFactory.makeSignUpErrorAlert(
            message: error.localizedDescription
        )
        
        self.present(alert, animated: true)
    }
    
    func sendEmailVerifyAlert() {
        let alert = UIAlertController(
            title: K.EmailVerify.signTitle,
            message: K.EmailVerify.signMessage,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: K.ActionText.ok, style: .cancel) { [unowned self] _ in
            navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
}








