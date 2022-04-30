//
//  DatabaseManager.swift
//  Tracking
//
//  Created by Manish on 23/04/22.
//

import Foundation
import FMDB

final class DatabaseManager {
    static let dataBaseFileName = "Tracking.db"
    static var database: FMDatabase!
    static let shared : DatabaseManager = {
        let instance = DatabaseManager()
        return instance
    }()
    func createDatabase(){
        let bundlePath = Bundle.main.path(forResource: "Tracking", ofType: ".db")
        print(bundlePath ?? "","\n") //prints the correct path
        guard let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else{
            return
        }
        let fileManager = FileManager.default
        let fullDestPath = URL(fileURLWithPath: destPath).appendingPathComponent("Tracking.db")
        let fullDestPathString = fullDestPath.path
        
        if fileManager.fileExists(atPath : fullDestPathString){
            print("File is available")
            DatabaseManager.database = FMDatabase(path: fullDestPathString)
            openDataBase()
            print(fullDestPathString)
        }
        else{
            do{

                try fileManager.copyItem(atPath: bundlePath!, toPath: fullDestPathString)
                if fileManager.fileExists(atPath : fullDestPathString){
                    DatabaseManager.database = FMDatabase(path: fullDestPathString)
                    openDataBase()
                    print("file is copy")
                }
                    else{
                        print("file is not copy")
                    }

            }
            catch{
                print("\n")
                print(error   )
                
            }
        }
        
        
         
    }
    func openDataBase(){
        if DatabaseManager.database != nil{
            DatabaseManager.database.open()
        }else{
            DatabaseManager.shared.createDatabase()
        }
        
    }
    func closeDataBase(){
        if DatabaseManager.database != nil{
            DatabaseManager.database.close()
        }else{
        
         }
    }
    
    func insertData(_ data: TrackingModel) -> Bool{
        DatabaseManager.database.open()
        let isSave = DatabaseManager.database.executeUpdate("INSERT INTO tblTracking(distance,startTime,stopTime) VALUES(?,?,?)", withArgumentsIn: [data.distance,data.startTime,data.stopTime])
        DatabaseManager.database.close()
        return isSave
    }
    
    func getData()-> [TrackingModel]{
        DatabaseManager.database.open()
        let resultset : FMResultSet!  = DatabaseManager.database.executeQuery("SELECT * FROM tblTracking", withArgumentsIn: [0])
        var itemInfo : [TrackingModel] = []
        if (resultset != nil){
            while (resultset?.next())!{
                var item : TrackingModel = TrackingModel()
                item.id = Int((resultset?.int(forColumn: "id") ?? 0))
                item.startTime = String((resultset?.string(forColumn: "startTime") ?? ""))
                item.stopTime = String((resultset?.string(forColumn: "stopTime") ?? ""))
                item.distance = String((resultset?.string(forColumn: "distance") ?? ""))
                itemInfo.append(item)
            }
        }
        DatabaseManager.database.close()
        return itemInfo
    }
    func deleteRecord(data: TrackingModel) -> Bool {
        DatabaseManager.database.open()
        let isDelete = DatabaseManager.database.executeUpdate("DELETE FROM tblTracking WHERE id = ?", withArgumentsIn: [data.id])
        DatabaseManager.database.close()
        return isDelete
        
    }
    
    

      
    
    
    
}



