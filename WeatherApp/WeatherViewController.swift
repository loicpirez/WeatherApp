import UIKit
import Auth0
import SimpleKeychain
import Foundation

@available(iOS 10.0, *)
class WeatherViewController: UIViewController {
    var city:String!
    var celcius:Bool!
    var apikeys: NSDictionary?
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var town: UILabel!
    @IBOutlet weak var degrees: UILabel!
    @IBOutlet weak var aqi: UILabel!
    @IBOutlet weak var forecastStackView: UIStackView!
    @IBAction func locationButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "getBackToLocationFromWeather", sender: nil)
    }
    
    @IBAction func settingsButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "jumpToSettings", sender: nil)
    }

    func dataToString(_ data: Data) -> String {
        return String(data: data, encoding: String.Encoding.utf8)!
    }
    
    func jsonStringToDictionnary(_ jsonString: String) -> NSDictionary {
        var dictonary:NSDictionary?
        if let data = jsonString.data(using: String.Encoding.utf8) {
            do {
                dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] as NSDictionary?
                return dictonary!
            } catch let error as NSError {
                print(error)
            }
        }
        return dictonary!
    }
    
    func kelvinToCelcius(_ kelvin : Double ) -> Double {
        return kelvin - 273.15
    }
    
    func kelvinToFahrenheit(_ kelvin : Double ) -> Double {
        return (kelvin - 273.15) * 9/5 + 32
    }
    
    func getEmojiFromWeatherDescription(_ weatherDescription : String) -> String {
        switch weatherDescription {
        case "clear sky":
                return "🌤"
        case "few clouds":
                return "🌥"
        case "scattered clouds":
                return "☁"
        case "broken clouds":
                return "☁"
        case "shower rain":
                return "🌦"
        case "light rain":
            return "🌧"
        case "moderate rain":
            return "🌧"
        case "rain":
                return "🌧"
        case "thunderstorm":
                return "⛈"
        case "snow":
                return "🌨"
        case "mist":
                return "💨"
        case "haze":
                 return "🌫"
        default:
                return "🌥"
        }
    }

    func getBackgroundFromWeatherDescription(_ weatherDescription : String) {
        switch weatherDescription {
        case "clear sky":
            background.image = UIImage(named: "sunny")
        case "few clouds":
            background.image = UIImage(named: "cloudy")
        case "scattered clouds":
            background.image = UIImage(named: "cloudy")
        case "broken clouds":
            background.image = UIImage(named: "cloudy")
        case "shower rain":
            background.image = UIImage(named: "rainy")
        case "light rain":
            background.image = UIImage(named: "rainy")
        case "rain":
            background.image = UIImage(named: "rainy")
        case "thunderstorm":
            background.image = UIImage(named: "thunderstorm")
        case "snow":
            background.image = UIImage(named: "snow")
        case "mist":
            background.image = UIImage(named: "fog")
        case "haze":
            background.image = UIImage(named: "haze")
        default:
            background.image = UIImage(named: "cloudy")
        }
    }

    
    // getBackgroundFromWeatherDescription
    
    func getWeatherInformations() {
        let request = URLRequest(url:URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city!)&apikey=\(self.apikeys!["OpenWeather"]!)")!)
        let weatherTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let data = data , error == nil else { return }
            DispatchQueue.main.async {
                let dictionnary = self.jsonStringToDictionnary(self.dataToString(data))
                let informations = dictionnary["main"] as! NSDictionary
                let temperature = informations["temp"] as! Double
                let weather = dictionnary["weather"] as! [(NSDictionary)]
                let description = weather[0]["description"] as! String

                let emoji = self.getEmojiFromWeatherDescription(description)
                self.getBackgroundFromWeatherDescription(description)

                
                if (self.celcius == true) {
                    let temp = Int(self.kelvinToCelcius(temperature))
                    self.degrees.text = "\(emoji) \(temp)°C"
                }
                else {
                    let temp = Int(self.kelvinToFahrenheit(temperature))
                    self.degrees.text = "\(emoji) \(temp)°F"

                }
            }
        }
        weatherTask.resume()
    }
    
    func getAQI() {
        let request = URLRequest(url:URL(string: "https://api.waqi.info/feed/\(city!)/?token=\(self.apikeys!["AQICN"]!)")!)
        let AQITask = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let data = data , error == nil else { return }
            DispatchQueue.main.async {
                let dictionnary = self.jsonStringToDictionnary(self.dataToString(data))
                let aqidata = dictionnary["data"] as? NSDictionary
                    let aqi = aqidata?["aqi"]
                        self.aqi.text = "AQI: \(aqi!)"
            }
        }
        AQITask.resume()
    }
    
    func getCurrentDate() -> Date {
        var now = Date()
        var nowComponents = DateComponents()
        let calendar = Calendar.current
        nowComponents.year = Calendar.current.component(.year, from: now)
        nowComponents.month = Calendar.current.component(.month, from: now)
        nowComponents.day = Calendar.current.component(.day, from: now)
        nowComponents.hour = Calendar.current.component(.hour, from: now)
        nowComponents.minute = Calendar.current.component(.minute, from: now)
        nowComponents.second = Calendar.current.component(.second, from: now)
        nowComponents.timeZone = NSTimeZone.local
        now = calendar.date(from: nowComponents)!
        return now as Date
    }
    
    func getFormattedDateWithMoreDay(_ daysToAdd : Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: daysToAdd, to: self.getCurrentDate())
        return "\(Calendar.current.component(.year, from: date!))-\(Calendar.current.component(.month, from: date!))-\(String(format: "%02d", Calendar.current.component(.day, from: date!))) 00:00:00"

    }
    
    func getForecastInformations() {
        let request = URLRequest(url:URL(string: "https://api.openweathermap.org/data/2.5/forecast?q=\(city!)&apikey=\(self.apikeys!["OpenWeather"]!)")!)
        let forecastTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let data = data , error == nil else { return }
            DispatchQueue.main.async {
                let dictionnary = self.jsonStringToDictionnary(self.dataToString(data))
                let forecastList = dictionnary["list"]
                let forecasts = forecastList as! [NSDictionary]
                let wanted_dates = [
                    self.getFormattedDateWithMoreDay(1),
                    self.getFormattedDateWithMoreDay(2),
                    self.getFormattedDateWithMoreDay(3),
                    self.getFormattedDateWithMoreDay(4)
                ]
                var i = 1
                for forecast in forecasts {
                    for date in wanted_dates {
                        if (date == forecast["dt_txt"]! as! String) {
                            var inc = 1
                            for stackview in self.forecastStackView.arrangedSubviews {
                                if (inc == i) {
                                    var dateFmt = DateFormatter()
                                    dateFmt.dateFormat =  "yyyy-MM-dd 00:00:00"
                                    var time = dateFmt.date(from: date)
                                    let informations = forecast["main"] as! NSDictionary
                                    let temperature = informations["temp"] as! Double //TODO: Handle Celcius Farentheit
                                    let weather = forecast["weather"] as! [(NSDictionary)]
                                    let description = weather[0]["description"] as! String
                                    var temp = 0
                                    if (self.celcius == true) {
                                        temp = Int(self.kelvinToCelcius(temperature))
                                    }
                                    else {
                                        temp = Int(self.kelvinToFahrenheit(temperature))
                                    }
                                    let emoji = self.getEmojiFromWeatherDescription(description)
                                    var label_number = 0
                                    for item in stackview.subviews {
                                        if (label_number == 0) {


                                            let formatted_date = "\(String(format: "%02d", Calendar.current.component(.month, from: time!)))/\(String(format: "%02d", Calendar.current.component(.day, from: time!)))"
                                            
                                            (item as! UILabel).text = formatted_date
                                        }
                                        if (label_number == 1) {
                                            (item as! UILabel).text = emoji
                                        }
                                        if (label_number == 2) {
                                            (item as! UILabel).text = String(temp)
                                        }
                                        label_number += 1
                                    }
                                }
                                inc += 1
                            }
                            inc = 0
                            i += 1
                        }
                    }
                }
            }
        }
        forecastTask.resume()
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") {
            self.apikeys = NSDictionary(contentsOfFile: path)
        }
        let user = UserOperations().getUser(access_token: ((SessionManager.shared.credentials?.accessToken)!))
        city = user?.location
        
        if (user!.temperature_format == 0) {
            celcius = true
        }
        else {
            celcius = false
        }
        
        getWeatherInformations()
        getAQI()
        getForecastInformations()
        


        town.text = city
    }
}
