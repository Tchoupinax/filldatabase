//
//  function.swift
//  filldatabase
//
//  Created by Corentin Filoche on 25/07/2017.
//  Copyright © 2017 Corentin Filoche. All rights reserved.
//

import Foundation

//
//
//
#if os(Linux)
    import SwiftGlibc
    public func arc4random_uniform(_ max: UInt32) -> Int32 {
        return (SwiftGlibc.rand() % Int32(max-1))
    }
#endif
//
//
//
extension String {
    var length: Int {
        return characters.count
    }
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    func substring(with min: Int, max: Int) -> String {
        let startIndex = index(from: min)
        let endIndex = index(from: max)
        return substring(with: startIndex..<endIndex)
    }
    func matches(with str: String) -> Bool
    {
        return (range(of: str, options: .regularExpression) != nil)
    }
}
//
//
// Check if a file exists
func fileExists(file: String) -> Bool
{
    return FileManager.default.fileExists(atPath: file)
}
//
//
// Configuration
func loadingConfig(file: String)
{
    
}
func savingConfig(file: String)
{
    
}
//
//
//
func readQueryFileToArray(path: String) -> [Request]
{
    let str = getStringFromFile(pathfile: path)
    let splitedStr = str.components(separatedBy: "\n")
    var i = 0
    var array = [Request]()
    while i < splitedStr.count - 1
    {
        let t = splitedStr
        let req = Request()
        while t[i] != "#"  && i < splitedStr.count - 1
        {
            i = i + 1
        }
        if i < splitedStr.count - 1
        {
            // We have # so taking the next row
            i = i + 1
            // Taking type and table
            req.setType(type: t[i].components(separatedBy: " ")[0])
            req.setTable(table: t[i].components(separatedBy: " ")[1])
            i = i + 1
            while t[i] != "###"
            {
                let key = t[i].components(separatedBy: ";")[0]
                let value = t[i].components(separatedBy: ";")[1]
                req.addingData(key: key, value: value)
                i = i + 1
            }
            i = i + 1
            // Saving quantity
            if Int(t[i].components(separatedBy: ":")[1]) == nil
            {
                req.setQuantity(quantity: t[i].components(separatedBy: ":")[1])
            }
            else
            {
                req.setQuantity(quantity: Int(t[i].components(separatedBy: ":")[1])!)
            }
        }
        if req.getDataCount() != 0
        {
            array.append(req)
        }
    }
    return array
}
//
//
// Read file and return all content throught String
func getStringFromFile(pathfile: String) -> String
{
    let manager = FileManager.default
    if manager.fileExists(atPath: pathfile)
    {
        let data = manager.contents(atPath: pathfile)
        return NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
    }
    else
    {
        print("File \(pathfile) unfound !")
        exit(1)
    }
}
//
//
// Permet d'écrire dans un fichier
func writeToFile(pathfile: String, whattowrite: String)
{
    let manager = FileManager.default
    if manager.fileExists(atPath: pathfile)
    {
        // Transformation en url avec URL(string: pathfile)
        if let fileHandle = try? FileHandle(forWritingTo: URL(string: pathfile)!)
        {
            fileHandle.seekToEndOfFile()
            // Transformation de la string en data
            fileHandle.write(whattowrite.data(using: .utf8)!)
            fileHandle.closeFile()
        }
    }
    else
    {
        manager.createFile(atPath: pathfile, contents: whattowrite.data(using: String.Encoding.utf8))
    }
}
//
func getRandomDataFromFile(pathfile: String, typeofdata: String) -> String
{
    let val = getStringFromFile(pathfile: pathfile + typeofdata)
    let valArray = val.components(separatedBy: "\n")
    let index = Int(arc4random_uniform(UInt32(valArray.count - 1)))
    return "'\(valArray[index])'"
}
//
func getConditionalDataFromFile(pathfile: String, typeofdata: String, number: Int) -> String
{
    let val = getStringFromFile(pathfile: pathfile + typeofdata)
    let valArray = val.components(separatedBy: "\n")
    var indDebut = 0
    while indDebut < valArray.count - 1 && valArray[indDebut] != ":\(number)"
    {
        indDebut = indDebut + 1
    }
    var indFin = indDebut
    while indFin < valArray.count - 1 && valArray[indFin] != ":\(number + 1)"
    {
        indFin = indFin + 1
    }
    let index = randomIntegerBetween(big: indFin - 1, little: indDebut + 1)
    return "'\(valArray[index])'"
}
//
func randomString(length: Int) -> String
{
    let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let allowedCharsCount = UInt32(allowedChars.characters.count)
    var randomString = ""
    
    for _ in 0..<length
    {
        let randomNum = Int(arc4random_uniform(allowedCharsCount))
        let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
        let newCharacter = allowedChars[randomIndex]
        randomString += String(newCharacter)
    }
    return randomString
}
//
func randomIntegerBetween(big: Int, little: Int) -> Int
{
    return Int(arc4random_uniform(UInt32(big - little + 1))) + little
}
//
//
// Return count of row of a file `@filename`
func getDataFromFile(filename: String) -> ([String], Int)
{
    if fileExists(file: FOLDER_PATH + filename)
    {
        let str = getStringFromFile(pathfile: FOLDER_PATH + filename)
        return (str.components(separatedBy: "\n").filter{$0 != ""},str.components(separatedBy: "\n").filter{$0 != ""}.count)
    }
    else
    {
        print("====== ERROR ======")
        print("File \(FOLDER_PATH + filename) not found !")
        exit(1)
    }
}