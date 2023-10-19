//
//  ImageGalleryTableViewCell.swift
//  ImageGallery
//
//  Created by sam hastings on 18/10/2023.
//

import UIKit

class ImageGalleryTableViewCell: UITableViewCell, UITextFieldDelegate {


    @IBOutlet weak var galleryTitle: UITextField! {
        didSet {
            galleryTitle.delegate = self
            galleryTitle.isEnabled = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
    }
    
    @objc func handleDoubleTap() {
        galleryTitle.isEnabled = true
        galleryTitle.becomeFirstResponder()
    }
    
    // SOLUTION WITH CLOSURE!!!
    var resignationHandler: (() -> Void)?
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?()
        galleryTitle.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        galleryTitle.resignFirstResponder()
        return true
    }
    
}
