//
//  Communicator.swift
//  JobInterviewHW2.0
//
//  Created by Perry on 01/12/2017.
//  Copyright © 2017 perrchick. All rights reserved.
//

import Foundation
//import Alamofire

typealias RawJsonFormat = [AnyHashable: Any]
public typealias CallbackClosure<T> = ((T) -> Void)
public typealias PredicateClosure<T> = ((T) -> Bool)

class Communicator {
    struct API {
        struct RequestUrls {
            // I usually avoid using inferred types in Swift, to help the compiler run faster, it doesn't affect the run time of course, only the compiling time.
            static let GeocodeFormat: String = "https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&key=%@"
            static let PlaceSearchFormat: String = "https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@"
            static let NearByPlacesFormat: String = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%f&key=%@"
            static let AutocompletePlacesFormat: String = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=address&language=iw&key=%@"
        }
        struct ResponseKeys {
            static let GoogleMapsPredictions: String = "predictions"
            static let GoogleMapsResults: String = "results"
        }
    }
    
    // Inspired from: https://medium.com/@jbergen/you-ve-been-using-enums-in-swift-all-wrong-b8156df64087"
    public enum Response {
        case succeeded(response: Any)
        case failed(error: NSError)
    }

    static private func request(urlString: String, completion: @escaping CallbackClosure<RawJsonFormat?>) {
        //String urlString = ""
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, connectionError) -> Void in
            guard let data = data else { completion(nil); return }
            if let connectionError = connectionError {
                📕("Error: (\(connectionError))")
                completion(nil)
            } else {
                do {
                    let innerJson = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                    completion(innerJson as? RawJsonFormat)
//                    let toastText = parseResponse(innerJson) ?? "Parsing failed"
//                    PerrFuncs.runOnUiThread(block: { () -> Void in
//                        ToastMessage.show(messageText: toastText)
//                    })
                } catch {
                    📕("Error: (\(error))")
                    completion(nil)
                }
            }
        })
        
        // Go fetch...
        dataTask.resume()
    }
    
    static func parseResponse(_ responseObject: Any) -> String? {
        var result: String?
        
        guard let responseDictionary = responseObject as? RawJsonFormat,
            let status = responseDictionary["status"] as? String, status == "OK" else { return result }
        
        📗("Parsing JSON dictionary:\n\(responseDictionary)")
        if let results = responseDictionary["results"] as? [AnyObject],
            let firstPlace = results[0] as? [String:AnyObject],
            let firstPlaceName = firstPlace["formatted_address"] as? String {
            result = "Found address: \(firstPlaceName)"
        }
        
        return result
    }

//    static func request(urlString: String, completion: @escaping CompletionClosure<Response?>) {
//        📗("Calling: \(urlString)")
//        Alamofire.request(urlString).responseJSON { (response) in
//            if let JSON = response.result.value, response.result.error == nil {
//                // Request succeeded!
//                completion(Response.succeeded(response: JSON))
//            } else {
//                // Request failed! ... handle failure
//                ToastMessage.show(messageText: "Error retrieving address")
//                if let error = response.result.error as NSError? {
//                    completion(Response.failed(error: error))
//                } else {
//                    completion(Response.failed(error: NSError.custom(domain: "parsing failed")))
//                }
//            }
//        }
//    }
}

extension NSError {
    static func custom(domain: String, code: Int = 0, userInfo: [String : Any]? = nil) -> NSError {
        let error = NSError(domain: domain, code: code, userInfo: userInfo)
        return error
    }
}
