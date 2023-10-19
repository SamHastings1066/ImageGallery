//
//  Image.swift
//  ImageGallery
//
//  Created by sam hastings on 13/10/2023.
//

import Foundation

struct Image {
    
    /// The URL of the image
    var imageURL: URL?
    
    /// The ratio of the cell's width to its height
    var aspectRatio: Double?
    
    /// The data retrieved from a network call to the imageURL
    var data: Data?
    
}
