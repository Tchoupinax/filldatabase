//
//  insert.swift
//  filldatabase
//
//  Created by Corentin Filoche on 25/07/2017.
//  Copyright © 2017 Corentin Filoche. All rights reserved.
//

import Foundation

//
//
// Performing the data traitement
// RETURNS
//    * The value 
//    * Saved value if needed
func traitement(type: String, savedValue: inout [String:String]) -> String
{
    //
    //
    // Initialize with null for writing it in the query 
    // if the type of value in unknow
    var value : String = "null"
    //
    //
    // Data we're taking randomly in the appropriate file
    if type.substring(to: 1) == "@"
    {
        value = getDataBeginsWithArobase(type: type)
        // Saving useful data
        if type == "@name"
        {
            savedValue["name"] = value.substring(with: 1, max: value.length - 1)
        }
        else if type == "@forname"
        {
            savedValue["forname"] = value.substring(with: 1, max: value.length - 1)
        }
    }
    //
    //
    // Data we're taking randomly in the appropriate file
    else if type.substring(to: 1) == "?"
    {
        let _ = type.components(separatedBy: "[")[0]
        let _ = type.components(separatedBy: "[")[1].components(separatedBy: "]")[0]
    }
    //
    //
    // Other data which are randomly generated
    else
    {
        // Type could seem like "integer,min,max" 
        // We're checking that here. If there is true,
        // we call the appropriate function to get the right data
        // Else we perform standard get
        if type.components(separatedBy: ",").count == 3
        {
            value = getDataFromPattern(pattern: type)
        }
        else
        {
            value = getStandardRandomData(type: type, saved: savedValue)
        }
    }
    // Getting in our dictionnary
    return value
}
