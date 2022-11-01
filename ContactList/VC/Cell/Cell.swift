//
//  Cell.swift
//  M20
//
//  Created by Яна Дударева on 06.09.2022.
//

import Foundation
import UIKit
import SnapKit

class Cell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
