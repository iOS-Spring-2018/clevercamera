//
//  Responses.swift
//  U_JSON Demo
//
//  Created by Jon Eikholm on 24/02/2018.
//  Copyright © 2018 Jon Eikholm. All rights reserved.
//

import Foundation
struct Responses: Decodable {
    let responses:[Response]
}
struct Response: Decodable {
    let labelAnnotations:[Annotation]
    //let faceAnnotations:[Annotation]
}
struct Annotation : Decodable {
    let mid: String
    let description: String
    let score: Double
    let topicality: Double
}
