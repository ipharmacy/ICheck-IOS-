//
//  User.swift
//  iCheck
//
//  Created by Youssef Marzouk on 21/11/2020.
//

import Foundation

struct Customer:Decodable {
    var _id:String
    var firstName:String
    var lastName:String
    var email:String
    var password:String
    var phone:String
    var sexe:String
    var avatar:String
    var favorites:[Favorite]?
    /*var createdAt:Date
    var updatedAt:Date*/
    

}
