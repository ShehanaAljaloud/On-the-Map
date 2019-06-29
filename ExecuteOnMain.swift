//
//  performUIUpdatesOnMain.swift
//  On The Map
//
//  Created by Shehana Aljaloud on 16/06/2019.
//  Copyright © 2019 Shehana Aljaloud. All rights reserved.
//

import Foundation

func executeOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
