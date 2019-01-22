//
//  Env.swift
//  HealthAI
//
//  Created by Naresh Kumar on 02/12/18.
//  Copyright © 2018 Team9. All rights reserved.
//

import Foundation
import UIKit

class Env {
    
    static var iPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
