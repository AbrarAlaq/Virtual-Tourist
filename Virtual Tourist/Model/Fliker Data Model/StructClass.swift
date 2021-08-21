//  AppDelegate.swift
//
//  Created by ابرار on ٢٧ جما١، ١٤٤٠ هـ.
//  Copyright © ١٤٤٠ هـ Udacity. All rights reserved.

import Foundation

struct Resbonse : Codable {
    let photos : Images
    let stat : String
    
}

struct Images : Codable {
    let perpage : Int
    let photo : [FParse]
    
}

struct FParse : Codable {
    let id : String
    let url_m : String
    
}


