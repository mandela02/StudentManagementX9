//
//  NSObject+Extension.swift
//  SimpleCalendar
//
//  Created by Cong Nguyen on 9/28/18.
//  Copyright © 2018 komorebi. All rights reserved.
//

import Foundation

extension NSObject {
    @nonobjc class var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    var className: String {
        return type(of: self).className
    }
}
