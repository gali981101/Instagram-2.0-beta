//
//  LoginVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/15.
//

import UIKit
import FirebaseAuth
import IQKeyboardManagerSwift

final class LoginVC: UIViewController {
    
    // MARK: - UIElement
    
    private lazy var iconImage: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(named: K.ImageNames.igLogo)
        )
        
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private lazy var emailTextField: UITextField = {
        let field = TextFieldFactory
            .makeAuthField(K.TextFieldPlaceholder.email)
        
        field.delegate = self
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        
        field.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        
        return field
    }()
    
    private lazy var passwordTextField: UITextField = {
        let field = TextFieldFactory
            .makeAuthField(K.TextFieldPlaceholder.password)
        
        field.delegate = self
        field.isSecureTextEntry = true
        field.textContentType = .oneTimeCode
        field.returnKeyType = .go
        
        field.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        
        return field
    }()
    
    private lazy var loginButton: UIButton = {
        let button = ButtonFactory
            .makeAuthButton(K.ButtonTitle.login)
        
        button.isEnabled = false
        
        button.addTarget(
            self,
            action: #selector(handleLogin),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.attributedTitle(
            firstPart: K.AttributedTitle.dontHaveAccount,
            secondPart: K.ButtonTitle.signUp
        )
        
        button.addTarget(
            self,
            action: #selector(handleShowSignUp),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            loginButton
        ])
        
        view.axis = .vertical
        view.spacing = 20
        
        return view
    }()
    
}

// MARK: - Life Cycle

extension LoginVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AuthService.shared.delegate = self
        style()
        layout()
    }
    
}

// MARK: - Set Up

extension LoginVC {
    
    private func style() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        configGradientLayer()
        
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        [iconImage, stackView, dontHaveAccountButton]
            .forEach { subView in
                view.addSubview(subView)
            }
        
        self.hideKeyboardWhenTappedAround()
    }
    
    private func layout() {
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 80, width: 120)
        
        iconImage.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            paddingTop: 32
        )
        
        stackView.anchor(
            top: iconImage.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 32,
            paddingLeft: 32,
            paddingRight: 32
        )
        
        dontHaveAccountButton.centerX(inView: view)
        
        dontHaveAccountButton.anchor(
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            paddingBottom: 20
        )
    }
    
}

// MARK: - @objc Actions

extension LoginVC {
    
    @objc private func handleLogin() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        
        AuthService.shared.loginUser(with: email, password: password) { [weak self] in
            guard let self else { return }
            self.view.endEditing(true)
            
            let mainTabVC = MainTabVC()
            
            let keyWindow = UIApplication
                .shared
                .connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .last
            
            keyWindow?.rootViewController = mainTabVC
            
            mainTabVC.configureViewControllers()
            
            self.dismiss(animated: true)
        }
    }
    
    @objc private func handleShowSignUp() {
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc private func handleShowResetPassword() {}
    
    @objc private func formValidation() {
        guard emailTextField.hasText,
              passwordTextField.hasText else {
            
            loginButton.isEnabled = false
            loginButton.backgroundColor = ThemeColor.blue.withAlphaComponent(0.5)
            
            loginButton.setTitleColor(
                UIColor(white: 1, alpha: 0.64),
                for: .normal
            )
            
            return
        }
        
        loginButton.isEnabled = true
        loginButton.backgroundColor = ThemeColor.blue
        
        loginButton.setTitleColor(
            UIColor(white: 1, alpha: 1),
            for: .normal
        )
    }
    
}

// MARK: - UITextFieldDelegate

extension LoginVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string == K.String.oneSpace ? false : true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }
    
}

// MARK: - AuthServiceDelegate

extension LoginVC: AuthServiceDelegate {
    
    func sendErrorAlert(error: any Error) {
        let alert = AlertFactory.makeSignUpErrorAlert(
            title: K.AlertTitle.loginError,
            message: error.localizedDescription
        )
        
        self.present(alert, animated: true)
    }
    
    func sendEmailVerifyAlert() {
        let alert = UIAlertController(
            title: K.AlertTitle.loginError,
            message: K.EmailVerify.logMessage,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: K.EmailVerify.resend, style: .default) { _ in
            Auth.auth().currentUser?.sendEmailVerification()
        }
        
        let cancelAction = UIAlertAction(title: K.ActionText.cancel, style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
}
