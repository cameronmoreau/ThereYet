//
//  UIImageView+RenderingMode.swift
//  Schooled
//
//  Created by Andrew Whitehead on 12/21/15.
//  Copyright © 2015 Andrew Whitehead. All rights reserved.
//

import UIKit

extension UIImageView {
    var imageRenderingMode: UIImageRenderingMode {
        get {
            return self.image!.renderingMode
        }
        set(newValue) {
            self.image = self.image?.imageWithRenderingMode(newValue)
        }
    }
}
