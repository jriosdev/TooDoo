//
//  LockViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/21/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica
import LocalAuthentication

final class LockViewController: UIViewController {

    /// Storyboard identifier.
    
    static let identifier = "Lock"
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var backgroundGradientView: GradientView!
    @IBOutlet var lockImageView: UIImageView!
    
    @IBOutlet var passcodeContainerView: UIView!
    @IBOutlet var hidePasscodeImageView: UIImageView!
    @IBOutlet var passcodeTextField: UITextField!
    @IBOutlet var biometricButton: UIButton!
    
    // MARK: - View Life Cycle.

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        
        authenticateUser()
    }
    
    /// Set up views.
    
    fileprivate func setupViews() {
        // Configure background gradient view
        backgroundGradientView.alpha = 1
        backgroundGradientView.startColor = currentThemeIsDark() ? UIColor(hexString: "4F4F4F") : .white
        backgroundGradientView.endColor = currentThemeIsDark() ? UIColor(hexString: "2B2B2B") : UIColor.flatWhite().darken(byPercentage: 0.15)
        // Configure lock image view
        lockImageView.alpha = 1
        lockImageView.transform = .init(scaleX: 1, y: 1)
    }
    
    /// Perform authentication.
    
    private func authenticateUser() {
        let context = LAContext()
        let reason = "permission.authentication.reason".localized
        
        var authError: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluateError in
                if success {
                    // User authenticated successfully
                    self.authenticationPassed()
                } else {
                    // User did not authenticate successfully
                    self.authenticationFailed()
                }
            }
        } else {
            // Could not evaluate policy
            authenticationFailed()
        }
    }
    
    /// User taps unlock icon.
    
    @IBAction func unlockDidTap(_ sender: Any) {
        // Generate haptic feedback
        Haptic.impact(.medium).generate()
        
        authenticateUser()
    }
    
    /// Authentication failed.
    
    private func authenticationFailed() {
//        "alert.authentication-failed".localized
        
        DispatchQueue.main.async {
            Haptic.notification(.error).generate()
        }
        
        // Shake text field
        // Add red border
    }
    
    /// Authentication passed.
    
    private func authenticationPassed() {
        // Send notification
        NotificationManager.send(notification: .UserAuthenticated)
        
        DispatchQueue.main.async {
            // Generate haptic feedback
            Haptic.notification(.success).generate()
            
            // Animate views
            UIView.animate(withDuration: 0.25) {
                self.backgroundGradientView.alpha = 0
            }
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                self.lockImageView.alpha = 1
                self.lockImageView.transform = .init(scaleX: 0.01, y: 0.01)
            }) {
                if $0 {
                    // Dismiss self once completed
                    self.dismiss(animated: true, completion: {
                        /// Redirection after authentication
                        if let identifier = DispatchManager.main.redirectSegueIdentifier {
                            switch identifier {
                            case ToDoOverviewViewController.Segue.ShowSettings.rawValue:
                                NotificationManager.send(notification: .ShowSettings)
                            case ToDoOverviewViewController.Segue.ShowCategory.rawValue:
                                NotificationManager.send(notification: .ShowAddCategory)
                            case ToDoOverviewViewController.Segue.ShowTodo.rawValue:
                                NotificationManager.send(notification: .ShowAddToDo)
                            default:
                                break
                            }
                        }
                        // Reset redirection
                        DispatchManager.main.redirectSegueIdentifier = nil
                    })
                }
            }
        }
    }
    
    /// Light status bar.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return themeStatusBarStyle()
    }
    
}