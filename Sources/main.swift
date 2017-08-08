//
//  main.swift
//  filldatabase
//
//  Created by Corentin Filoche on 25/07/2017.
//  Copyright © 2017 Corentin Filoche. All rights reserved.
//

import Foundation
import Commander

//
//
// Variables
public var FOLDER_PATH : String = ""
//
public var FILE_SAVE : String = ""
public var FILE_CONFIG : String = ""
public var FILE_QUERY : String = ""
//
public let REGEX_REQUEST_TYPE = "^[a-z]+ [a-z_]+$"
public let REGEX_REQUEST_LINE = "^[a-z_0-9]+;([a-z@?]+(,\\d+,\\d+|\\[[a-z]*\\])?|(%pk%,\\d+)?)$"
public let REGEX_REQUEST_QUANTITY = "^quantity:(\\d+|[?]?[@]?[a-z]+(\\[[a-z]+\\])?)$"
//
//
// Seeding for random function under Linux
#if os(Linux)
    srand(time(nil))
#endif
//
//
// Using the frameworks Commander to manage command line
// https://github.com/kylef/Commander
// Options are listed below
command (
    Option("folder", "\(FileManager.default.currentDirectoryPath)/Ressources/" , description : "Where is your resource folder"),
    Option("input", "query", description: "File which contains the query"),
    Option("output", "filldatabase_output.sql", description: "Name of file for saving output script"),
    Option("save", "true", description: "Save arguments in a conf file for having them next time without give them")
)
{ folder, input,  output, save in
    FOLDER_PATH = folder
    // Checking if the directory passed is a directory
    if directoryExists(path: FOLDER_PATH)
    {
        FILE_QUERY = "\(FOLDER_PATH)\(input)"
        if fileExists(file: FILE_QUERY)
        {
            // No need to test it, write function will
            // create it if needed
            FILE_SAVE = "\(FOLDER_PATH)\(output)"
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
            // We're controlling the query file to see if 
            // there is no error. In this way we will do amazing thing with it
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
            print("File : \"\(FILE_QUERY)\" does not exist !")
            exit(1)
        }
    }
    else
    {
        print("====== ERROR ======")
        print("Directory : \"\(folder)\" does not exist !")
        exit(1)
    }
}.run()
