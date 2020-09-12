//
//  SaveViewController.swift
//  AudioMemoApp
//
//  Created by Rapha on 12.09.20.
//  Copyright © 2020 Rapha. All rights reserved.
//

import UIKit

class SaveViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet var categoryButtons: [UIButton]!
    
    var category = "Important"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        nameTextField.delegate = self
    }
    
    func updateCategory(for title: String) {
        category = title
        
        for button in categoryButtons {
            if button.titleLabel?.text == title {
                button.setTitleColor(UIColor.red, for: .normal)
            } else {
                button.setTitleColor(UIColor.white, for: .normal)
            }
        }
    }
    
    func saveNewFile() {
        if let name = nameTextField.text {
            if !name.isEmpty {
                let fileName = name + ".caf"
                if Utility.moveAudioFile(to: category, with: fileName) {
                    dismiss(animated: true, completion: nil)
                } else {
                    showAlert(reason: 1)
                }
            } else {
                showAlert(reason: 0)
            }
        }
    }
    
    func showAlert(reason: Int) {
        let message = reason == 0 ? "Please enter an name!" : "File already exists!"
        let alertViewController = UIAlertController(title: "Could not save file", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertViewController.addAction(okAction)
        present(alertViewController, animated: true, completion: nil)
    }

    @IBAction func buttonHandler(_ sender: UIButton) {
        if let title = sender.titleLabel?.text {
            switch title {
            case "Important", "Funny":
                updateCategory(for: title)
            case "SAVE":
                saveNewFile()
            case "BACK":
                dismiss(animated: true, completion: nil)
            default:
                break
            }
        }
    }
    
}

extension SaveViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
