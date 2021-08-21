//
//
//  ImageOb.swift
//
//  Created by ابرار on ٢٧ جما١، ١٤٤٠ هـ.
//  Copyright © ١٤٤٠ هـ Udacity. All rights reserved.
//

import Foundation
import CoreData

extension ImageOb{
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
