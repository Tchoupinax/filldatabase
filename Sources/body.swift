//
//  body.swift
//  filldatabase
//
//  Created by Corentin Filoche on 01/08/2017.
//
//

import Foundation

//
//
// This function check if the query is correctly wrote
// It returns true of false with the error message and the row of the error
func checkQueryFile() -> (Bool, Int, String)
{
    // We're getting the content of the file throught a string
    let data = FileManager.default.contents(atPath: FILE_QUERY)
    let content = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
    // We transform the string to an array
    let contentArray = content.components(separatedBy: "\n")
    // We browse all the array
    var index = 0
    var rowNumberError = -10
    var noerror = true
    var ERROR_MESSAGE = "NULL"
    while index < contentArray.count - 1 && noerror
    {
        var dieseFound = false
        if noerror
        {
            // We're searching for the first #
            while contentArray[index] != "#" && noerror && index < contentArray.count - 1
            {
                if contentArray[index] != "" { noerror = false }
                if !noerror
                {
                    rowNumberError = index
                    ERROR_MESSAGE = "Caracter # is missing"
                }
                index = index + 1
            }
            if index < contentArray.count - 1 && noerror
            {
                dieseFound = true
                //
                //
                index = index + 1
                // Checking first row which should feels like keyword table
                if noerror
                {
                    noerror = contentArray[index].matches(with: REGEX_REQUEST_TYPE)
                    if !noerror
                    {
                        rowNumberError = index
                        ERROR_MESSAGE = "You have to give the type of request (insert into, update) and the table"
                    }
                }
                //
                // We force to have as least as one line
                index = index + 1
                if noerror
                {
                    noerror = contentArray[index].matches(with: REGEX_REQUEST_LINE)
                    if !noerror
                    {
                        rowNumberError = index
                        ERROR_MESSAGE = "Row has not a correct syntax"
                    }
                }
                index = index + 1
            }
        }
        while contentArray[index] != "###" && noerror && index < contentArray.count - 1
        {
            if noerror
            {
                noerror = contentArray[index].matches(with: REGEX_REQUEST_LINE)
                if !noerror
                {
                    rowNumberError = index
                    ERROR_MESSAGE = "Row has not a correct syntax"
                }
            }
            index = index + 1
        }
        if dieseFound && contentArray[index] != "###" && noerror
        {
            noerror = false
            if !noerror
            {
                rowNumberError = index
                ERROR_MESSAGE = "End caracter ### is missing"
            }
        }
        if noerror
        {
            index = index + 1
            noerror = contentArray[index].matches(with: REGEX_REQUEST_QUANTITY)
            if !noerror
            {
                rowNumberError = index
                ERROR_MESSAGE = "Quantity row is missing or has incorrect syntax"
            }
            index = index + 1
        }
    }
    // Index begins at 0 but my file begins at 1
    rowNumberError = rowNumberError + 1
    return (noerror, rowNumberError, ERROR_MESSAGE)
}
//
//
// Function which launch the processing of the request
// It exists two major way to do it
//     * The quantity is a number
//     * The quantity is a column (Means make as many request as different information in file)
func start()
{
    // Getting information from the query file
    // into a Request Array
    let data : [Request] = readQueryFileToArray(path: FILE_QUERY)
    // Query file could be contain several request
    // For each one, we process it
    for query in data
    {
        let comments = "--\n--\n-- TABLE \(query.getTable())\n---------------------------------------------------------------------------\n"
        writeToFile(pathfile: FILE_SAVE, whattowrite: comments)
        //
        //
        //
        // *****
        //     Looking for if queries are based on quantity or not
        //
        //
        //
        // This dictionnay allows to save data throught differents columns
        // (e.g. : save name for reuse it in the email)
        var savedValue = [String:String]()
        savedValue["%pk%"] = String("0")
        // CASE ONE
        // Queries are bases on a column
        // We want to have as many request as the file contains row to have each case
        //
        // Checking it quantity is type of String or Integer
        if type(of: query.getQuantity()) == type(of: String())
        {
            // We're getting all data in our master file
            // Case where the master is a simple file
            // In this way we do a simple loop for each row of this file
            // e.g.
            // #
            // insert enterprise
            // name;@name
            // job;@fonction
            // ###
            // QUANTITY:@fonction
            if (query.getQuantity() as! String).substring(to: 1) == "@"
            {
                // Getting our data
                let (array, _) = getDataFromFile(filename: query.getQuantity() as! String)
                // Loop on the master value
                for masterValue in array
                {
                    // Initialize query
                    var queryTOP = "insert into("
                    var queryBOTTOM = "values("
                    // Browse all required data in the request
                    for nb in 0...query.getDataCount() - 1
                    {
                        // Checking the end for having ')' and ');' when it is the
                        // end of the request
                        if nb < query.getDataCount() - 1
                        {
                            queryTOP = "\(queryTOP)\(query.getKey(at: nb)),"
                            // If the key feels like the quantity (so the master column)
                            // We add the master value
                            if(query.getKey(at: nb) == (query.getQuantity() as! String))
                            {
                                queryBOTTOM = "\(queryBOTTOM)\(masterValue),"
                            }
                                // Anyway else we process data as a classic process
                            else
                            {
                                queryBOTTOM = "\(queryBOTTOM)\(traitement(type: query.getData(at: nb), savedValue: &savedValue)),"
                            }
                        }
                        else
                        {
                            // Same thing with the good syntax ')' & ');'
                            queryTOP = "\(queryTOP)\(query.getKey(at: nb)))"
                            if(query.getData(at: nb) == (query.getQuantity() as! String))
                            {
                                queryBOTTOM = "\(queryBOTTOM)\(masterValue));"
                            }
                            else
                            {
                                queryBOTTOM = "\(queryBOTTOM)\(traitement(type: query.getData(at: nb), savedValue: &savedValue)));"
                            }
                        }
                    }
                    savedValue["%pk%"] = String(Int(savedValue["%pk%"]!)! + 1)
                    // Writing the query to the file and reset variable
                    writeToFile(pathfile: FILE_SAVE, whattowrite: "\(queryTOP)\n\(queryBOTTOM)\n")
                    queryTOP = ""
                    queryBOTTOM = ""
                }
            }
                // In other hand the master is a file with condition
                // So we'll get the masterkey and the master value
                // and adding the good key when we add the master value
                // e.g
                // #
                // insert enterprise
                // id;null
                // type;?@typetechno[id]
                // ###
                // QUANTITY:?@type[id]
                // In THIS CASE id can have no value because
                // quantity is base on and it will be filled in terms of quantity
            else
            {
                // Query seems like "?@fileName[index]
                // Here we are storing the ?@filename and
                // getting the index separately
                let s = (query.getQuantity() as! String)
                // ?@filename
                let file = s.components(separatedBy: "[")[0]
                // index
                let masterkey = (s.components(separatedBy: "[")[1]).substring(to: (s.components(separatedBy: "[")[1]).length - 1)
                // Data will be with this form :
                // [":1","data1","data2",":2","data3"]
                let (listOfConditionalData, _) = getDataFromFile(filename: file)
                // e.g. takes :1
                var masterKeyValue : Int = -10
                // Browse all required data in the request
                // Refers from above for more comments
                var i = 0
                while i < listOfConditionalData.count - 1
                {
                    var queryTOP = "insert into("
                    var queryBOTTOM = "values("
                    // If data seems like ":1", we're getting the value and adding
                    // it to our variable
                    if listOfConditionalData[i].matches(with: "^:[0-9]+$")
                    {
                        // Increment for avoid it after, we want to get value
                        // key is just to have the correspond index
                        masterKeyValue = Int(listOfConditionalData[i].substring(from: 1))!
                        i = i + 1
                    }
                    for nb in 0...query.getDataCount() - 1
                    {
                        // Checking the end for having ')' and ');' when it is the
                        // end of the request
                        if nb < query.getDataCount() - 1
                        {
                            queryTOP = "\(queryTOP)\(query.getKey(at: nb)),"
                            // If the key seems like our index, we put the saved value
                            // e.g ?@filename[index] means we take a value but the value xx has the
                            // index :1 in the file. We have saved it. Our loop is with the value xx
                            // at the moment. So when we're finding the index in the column_name, we
                            // put the index :1 that we have save. In this way, the value has its correct
                            // corresponding index
                            if masterkey == query.getKey(at: nb)
                            {
                                queryBOTTOM = "\(queryBOTTOM)\(masterKeyValue),"
                            }
                            else if query.getQuantity() as! String == query.getData(at: nb)
                            {
                                queryBOTTOM = "\(queryBOTTOM)\(listOfConditionalData[i]),"
                            }
                            else
                            {
                                queryBOTTOM = "\(queryBOTTOM)\(traitement(type: query.getData(at: nb), savedValue: &savedValue)),"
                            }
                        }
                        else
                        {
                            // Same thing with ')' and ');' more
                            queryTOP = "\(queryTOP)\(query.getKey(at: nb)))"
                            if masterkey == query.getKey(at: nb)
                            {
                                queryBOTTOM = "\(queryBOTTOM)\(masterKeyValue));"
                            }
                            else if query.getQuantity() as! String == query.getData(at: nb)
                            {
                                queryBOTTOM = "\(queryBOTTOM)\(listOfConditionalData[i]));"
                            }
                            else
                            {
                                queryBOTTOM = "\(queryBOTTOM)\(traitement(type: query.getData(at: nb), savedValue: &savedValue)));"
                            }
                        }
                    }
                    savedValue["%pk%"] = String(Int(savedValue["%pk%"]!)! + 1)
                    // Writing the query to the file and reset variable
                    writeToFile(pathfile: FILE_SAVE, whattowrite: "\(queryTOP)\n\(queryBOTTOM)\n")
                    queryTOP = ""
                    queryBOTTOM = ""
                    i = i + 1
                }
            }
        }
        //
        //
        //
        // CASE TWO
        // Queries are bases on a number
        // We want to have as many request as asked
        else
        {
            // We're doing as many request as asked in the query file
            for _ in 0...(query.getQuantity() as! Int) - 1
            {
                // Initialize query
                var queryTOP = "insert into \(query.getTable())("
                var queryBOTTOM = "values("
                // Initialize the %pk% var
                // Browse all required data in the request
                for nb in 0...query.getDataCount() - 1
                {
                    // Checking the end for having ')' and ');' when it is the
                    // end of the request
                    if nb < query.getDataCount() - 1
                    {
                        queryTOP = "\(queryTOP)\(query.getKey(at: nb)),"
                        queryBOTTOM = "\(queryBOTTOM)\(traitement(type: query.getData(at: nb), savedValue:&savedValue)),"
                    }
                    else
                    {
                        // Same thing with the good syntax ')' & ');'
                        queryTOP = "\(queryTOP)\(query.getKey(at: nb)))"
                        queryBOTTOM = "\(queryBOTTOM)\(traitement(type: query.getData(at: nb), savedValue:&savedValue)));"
                    }
                }
                savedValue["%pk%"] = String(Int(savedValue["%pk%"]!)! + 1)
                // Writing the query to the file and reset variable
                writeToFile(pathfile: FILE_SAVE, whattowrite: "\(queryTOP)\n\(queryBOTTOM)\n")
                queryTOP = ""
                queryBOTTOM = ""
            }
        }
    }
}
//
//
// Performing the data process
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
            value = getDataFromPattern(pattern: type, val: nil)
        }
        // But it alsa could seem like "%pk%,start"
        else if type.components(separatedBy: ",").count == 2
        {
            value = getDataFromPattern(pattern: type, val: Int(savedValue["%pk%"]!))
        }
        else
        {
            value = getStandardRandomData(type: type, saved: savedValue)
        }
        
    }
    // Getting in our dictionnary
    return value
}
