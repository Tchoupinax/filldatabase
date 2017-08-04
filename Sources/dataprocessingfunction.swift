//
//  dataprocessingfunction.swift
//  filldatabase
//
//  Created by Corentin Filoche on 03/08/2017.
//
//

import Foundation

// **
// Street
//
func getStreet() -> String
{
    var value = getRandomDataFromFile(typeofdata: "@street")
    // We're adding the number with the street
    // Removing the first quote
    value = value.substring(from: 1)
    // Create the random number
    // the number has 70% chance to be lower than 100
    let chance = arc4random_uniform(100)
    let random : Int
    if chance < 70
    {
        random = Int(arc4random_uniform(100))
    }
    else
    {
        random = Int(arc4random_uniform(300))
    }
    value = "'\(random), \(value)"
    return value
}
// **
// City
//
func getCity() -> String
{
    var value = getRandomDataFromFile(typeofdata: "@city")
    // Adding a escape caracter for the '
    value = value.substring(with: 1,max: value.length - 1).replacingOccurrences(of: "'", with: "''")
    return "'\(value)'"
}
// **
// Phone number
//
func getPhoneNumber() -> String
{
    var number = "0" + String(randomIntegerBetween(big: 9, little: 1))
    var tmp = 0
    for _ in 0...3
    {
        tmp = randomIntegerBetween(big: 99, little: 1)
        if tmp < 10
        {
            number = "\(number)0\(String(tmp))"
        }
        number = "\(number)\(tmp)"
    }
    return "'\(number)'"
}
// **
// E-mail address
//
func getEmail(forname: String?, name: String?) -> String
{
    // Remove special characters
    let name2 = name?.folding(options: .diacriticInsensitive, locale: nil)
    let forname2 = forname?.folding(options: .diacriticInsensitive, locale: nil)
    // Use random String if not data
    return "'\(forname2?.lowercased() ?? randomString(length: 5)).\(name2?.lowercased() ?? randomString(length: 5))@debian.org'"
}
// **
// Date
//
func getDate(from: Int) -> String
{
    let date = Date()
    let calendar = Calendar.current
    let month  = arc4random_uniform(12 - 1) + 1
    let day = arc4random_uniform(31 - 1) + 1
    let year = randomIntegerBetween(big: calendar.component(.year, from: date), little: from)
    return "TO_DATE('\(year)/\(month)/\(day)', 'yyyy/mm/dd')"
}
// **
// Birthday date
//
// From 1950 To Today
func getBirthdayDate() -> String
{
    return getDate(from: 1950)
}
// **
// Postal code
//
func getPostalCode() -> String
{
    let cp = arc4random_uniform(99999)
    var value = String(cp)
    while value.length != 5
    {
        value = "0\(value)"
    }
    return value
}
// **
// Lorem ipsum
//
func getLorem(number: Int) -> String
{
    let value = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
    if number >= value.length
    {
        return value
    }
    else
    {
        return value.substring(to: number)
    }
}
// **
// Get integer with pattern "typeofdatas,min,max"
//
func getDataFromPattern(pattern: String, val: Any?) -> String
{
    if pattern.components(separatedBy: ",")[0] == "integer"
    {
        let v2 = Int(pattern.components(separatedBy: ",")[1])
        let v3 = Int(pattern.components(separatedBy: ",")[2])
        return String(randomIntegerBetween(big: v3!, little: v2!))
    }
    else if pattern.components(separatedBy: ",")[0] == "%pk%"
    {
        let v1 : Int = val as! Int
        let v2 : Int = Int(pattern.components(separatedBy: ",")[1])!
        return String(v1 + v2)
    }
    print("getDataFromPattern(pattern: String) -> Error")
    return "NULL"
}
//
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//
// **
// Manage "@thing" case
//
func getDataBeginsWithArobase(type: String) -> String
{
    if type == "@street"
    {
        return getStreet()
    }
    if type == "@city"
    {
        return getCity()
    }
    // Simply get data from file
    return  getRandomDataFromFile(typeofdata: type)
}
// **
// Standard format of data
//
func getStandardRandomData(type: String, saved: [String:String]) -> String
{
    switch type
    {
        case "phone":
            return getPhoneNumber()
        case "lorem":
            return getLorem(number: 20)
        case "datebirthday":
            return getBirthdayDate()
        case "date":
            return getDate(from: 1995)
        case "postalcode":
            return getPostalCode()
        case "email":
            return getEmail(forname: saved["forname"], name: saved["name"])
        default:
            return "null"
    }
}
