//
//  request.swift
//  filldatabase
//
//  Created by Corentin Filoche on 02/08/2017.
//
//

import Foundation

class Request
{
    //
    //
    // Attributes
    private var quantity : Any
    private var type : String
    private var table : String
    private var order : [String]
    private var data : [String:String]
    //
    //
    // Constructor
    init()
    {
        self.quantity = 0
        self.type = ""
        self.table = ""
        self.order = [String]()
        self.data = [String:String]()
    }
    //
    //
    // Getters and setters
    public func setQuantity(quantity: Any) { self.quantity = quantity }
    public func setType(type: String) { self.type = type }
    public func setTable(table: String) { self.table = table }
    public func getQuantity() -> Any { return self.quantity }
    public func getType() -> String { return self.type }
    public func getTable() -> String { return self.table }
    public func getKey(at: Int) -> String { return self.order[at] }
    public func getData(at: Int) -> String { return getData(withKey: self.order[at]) }
    public func getDataCount() -> Int { return self.order.count }
    //
    //
    // Private helpers
    private func getData(withKey: String) -> String { return self.data[withKey]! }
    //
    //
    // Adding a data in this request
    public func addingData(key: String, value: String)
    {
        // Saving order
        self.order.append(key)
        // Store data
        self.data[key] = value
    }
}
