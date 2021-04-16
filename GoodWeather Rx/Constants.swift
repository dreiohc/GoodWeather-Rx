//
//  Constants.swift
//  GoodWeather Rx
//
//  Created by Myron Dulay on 4/16/21.
//

import Foundation


func WEATHER_CITY_URL(city: String) -> URL {
  
  let userdefaults = UserDefaults.standard
  let unit = userdefaults.value(forKey: "unit") as? String ?? "metric"
  
  return URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city.escaped())&APPID=b0f21f281c75fccbb15685a2e7b0b1c1&units=\(unit)")!
}


