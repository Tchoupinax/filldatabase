//
//  main.swift
//  filldatabase
//
//  Created by Corentin Filoche on 25/07/2017.
//  Copyright © 2017 Corentin Filoche. All rights reserved.
//

import Foundation

//
//
// Variables
public let FOLDER_PATH = "/Users/Corentin/Documents/filldatabase/Ressources/"
//
public let FILE_SAVE = "\(FOLDER_PATH)save"
public let FILE_CONFIG = "\(FOLDER_PATH)filldatabase.conf"
public let FILE_QUERY = "\(FOLDER_PATH)query"
//
public let REGEX_REQUEST_TYPE = "^[a-z]+ [a-z_]+$"
public let REGEX_REQUEST_LINE = "^[a-z_]+;[a-z@?]+(,\\d+,\\d+|\\[[a-z]*\\])?$"
public let REGEX_REQUEST_QUANTITY = "^quantity:(\\d+|[?]?[@]?[a-z]+(\\[[a-z]+\\])?)$"
//
//
// Management of arguments
//   * -h, --help : Shows the man
let arg = CommandLine.arguments
if arg.count <= 1
{
    print("Need one argument as least - Use help if needed")
    exit(1)
}
else
{
    if(arg[1] == "--help" || arg[1] == "-h")
    {
        print("HELP")
        print("Command");
    }
    else
    {
        //
        //
        // Loading config file
        if fileExists(file: FILE_CONFIG)
        {
            loadingConfig(file: FILE_CONFIG)
        }
        else
        {
            print("====== WARNING ======")
            print("No config file found\n")
        }
        // Checking the existence of the query file
        if fileExists(file: FILE_QUERY)
        {
            let (testResultSucceded, rowNumber, error_msg) = checkQueryFile()
            if testResultSucceded
            {
                start()
            }
            else
            {
                print("====== ERROR ======")
                print("Your file is not correct")
                print("Error found at line \(rowNumber)")
                if error_msg != "NULL" { print("Error message is : \(error_msg)") }
                exit(1)
            }
        }
        else
        {
            print("====== ERROR ======")
            print("File \(FILE_QUERY) not found !")
            exit(1)
        }
    }
}

