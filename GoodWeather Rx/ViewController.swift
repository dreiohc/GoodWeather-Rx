//
//  ViewController.swift
//  GoodWeather Rx
//
//  Created by Myron Dulay on 4/16/21.
//

import UIKit
import RxCocoa
import RxSwift


class ViewController: UIViewController {
  
  // MARK: - Properties

  let disposeBag = DisposeBag()
  
  @IBOutlet weak var cityNameTextField: UITextField!
  @IBOutlet weak var temperatureLabel: UILabel!
  @IBOutlet weak var humidityLabel: UILabel!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    listenToTextField()
  }
  
  // MARK: - API
  
  // Fetching API with Error handler, Retry and Driver.
  private func fetchWeather(by city: String) {
    let url = WEATHER_CITY_URL(city: city)
    let resource = Resource<WeatherResult>(url: url)
    
    let search = URLRequest
      .load(resource: resource)
      .observeOn(MainScheduler.instance)  // This scheduler is usually used to perform UI work.
      .retry(3)                           // Retry for RxSwift. Really powerful API.
      .catchError { error in
        print("DEBUG: Error in API: \(error.localizedDescription)")
        return Observable.just(WeatherResult.empty)     // If error is API.
      }
      .asDriver(onErrorJustReturn: WeatherResult.empty) // If error is about driver.
    
    search
      .map { "\($0.main.temp) ℉" }       // map to get temp values only.
      .drive(temperatureLabel.rx.text)   // Use driver to textfield. Almost same as Bind.
      .disposed(by: disposeBag)
    
    search
      .map { "\($0.main.humidity)" }
      .drive(humidityLabel.rx.text)
      .disposed(by: disposeBag)

  }

  
  // Fetching API using Driver.
  private func fetchWeather3(by city: String) {
    let url = WEATHER_CITY_URL(city: city)
    let resource = Resource<WeatherResult>(url: url)
    
    let search = URLRequest
      .load(resource: resource)
      .observeOn(MainScheduler.instance)   // This scheduler is usually used to perform UI work.
      .asDriver(onErrorJustReturn: WeatherResult.empty)
    
    search
      .map { "\($0.main.temp) ℉" }         // map to get temp values only.
      .drive(temperatureLabel.rx.text)     // Use driver to textfield. Almost same as Bind.
      .disposed(by: disposeBag)
    
    search
      .map { "\($0.main.humidity)" }
      .drive(humidityLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  // Fetching API using Bind.
  private func fetchWeather2(by city: String) {
    let url = WEATHER_CITY_URL(city: city)
    let resource = Resource<WeatherResult>(url: url)
    
    let search = URLRequest
      .load(resource: resource)
      .observeOn(MainScheduler.instance)    // This scheduler is usually used to perform UI work.
      .catchErrorJustReturn(WeatherResult.empty)

    search
      .map { "\($0.main.temp) ℉" }         // map to get temp values only.
      .bind(to: temperatureLabel.rx.text)  // Bind to textfield.
      .disposed(by: disposeBag)
    
    search
      .map { "\($0.main.humidity)" }
      .bind(to: humidityLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  
  // Fetching API using normal method.
  private func fetchWeather1(by city: String) {
    let url = WEATHER_CITY_URL(city: city)
    let resource = Resource<WeatherResult>(url: url)
    
    URLRequest
      .load(resource: resource)
      .observeOn(MainScheduler.instance)    // This scheduler is usually used to perform UI work.
      .catchErrorJustReturn(WeatherResult.empty)
      .subscribe(onNext: { result in
        let weather = result.main
        self.displayWeather(weather)
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Actions
  
  
  
  // MARK: - Helpers
  
  private func displayWeather(_ weather: Weather?) {
    if let weather = weather {
      self.temperatureLabel.text = "\(weather.temp) ℃"
      self.humidityLabel.text = "\(weather.humidity)"
    } else {
      self.temperatureLabel.text = "🙈"
      self.humidityLabel.text = "😝"
    }
  }
 
  private func listenToTextField() {
    cityNameTextField
      .rx
      .controlEvent(.editingDidEndOnExit) // Will only fire if editing is finished.
      .asObservable()
      .map { self.cityNameTextField.text }
      .subscribe(onNext: { city in
        if let city = city {
          if city.isEmpty {
            self.displayWeather(nil)
          } else {
            self.fetchWeather(by: city)
          }
        }
      })
      .disposed(by: disposeBag)
  }
  
  
  
}


// MARK: - Extensions
