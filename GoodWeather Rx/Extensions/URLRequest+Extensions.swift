//
//  URLRequest+Extensions.swift
//  GoodWeather Rx
//
//  Created by Myron Dulay on 4/16/21.
//

import Foundation
import RxSwift
import RxCocoa


struct Resource<T> {
  let url: URL
}


extension URLRequest {
  
  static func load<T: Decodable>(resource: Resource<T>) -> Observable<T> {
    return Observable.just(resource.url)
      .flatMap { url -> Observable<(response: HTTPURLResponse, data: Data)> in // turn it into HTTP URLresponse type
        let request = URLRequest(url: url)
        return URLSession.shared.rx.response(request: request) // get response data
      }.map { response, data -> T in
        
        switch response.statusCode {
        case 200..<300 :
          return try JSONDecoder().decode(T.self, from: data)
        default:
          throw RxCocoaURLError.httpRequestFailed(response: response, data: data)
        }
      }.asObservable()
  }
  
  static func load1<T: Decodable>(resource: Resource<T>) -> Observable<T?> {
    
    return Observable
      .from([resource.url])
      .flatMap{ url -> Observable<Data> in
        let request = URLRequest(url: url)
        return URLSession.shared.rx.data(request: request) // Observable sequence of response data.
      }.map { data -> T? in
        return try? JSONDecoder().decode(T.self, from: data) // Decode data to T model.
    }.asObservable() // return as observable.
  }
}
