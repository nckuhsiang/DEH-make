//
//  TextField.swift
//  DEH-Make-II
//
//  Created by Ray Chen on 2017/12/26.
//  Copyright © 2017年 Ray Chen. All rights reserved.
//

import UIKit

class TextField: UITextField {
//    override func caretRect(for position: UITextPosition) -> CGRect {
//        return CGRect.zero
//    }
    
    override func selectionRects(for range: UITextRange) -> [Any] {
        return []
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) || action == #selector(selectAll(_:)) || action == #selector(paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
