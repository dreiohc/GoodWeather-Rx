//
//  String+Extensions.swift
//  GoodWeather Rx
//
//  Created by Myron Dulay on 4/16/21.
//

import Foundation

extension String {
  
  func escaped() -> String {
    return self.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) ?? self // space will be converted to % sign.
  }
  
}
