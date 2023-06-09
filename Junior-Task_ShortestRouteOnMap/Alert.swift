//
//  Alert.swift
//  Junior-Task_ShortestRouteOnMap
//
//  Created by Akbarshah Jumanazarov on 6/9/23.
//

import UIKit

extension UIViewController {
    func alertAdd(title: String, placdeHolder: String, completionHandler: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            let textField = alertController.textFields?.first
            guard let text = textField?.text else { return }
            completionHandler(text)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertController.addTextField { tf in
            tf.placeholder = placdeHolder
        }
        
        present(alertController, animated: true)
    }
    
    func alertError(title: String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(alertController, animated: true)
    }
}
