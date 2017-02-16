//
//  NoteDAO.swift
//  MyNotes
//
//  Created by 关东升 on 15/12/31.
//  本书网站：http://www.51work6.com
//  智捷课堂在线课堂：http://www.zhijieketang.com/
//  智捷课堂微信公共号：zhijieketang
//  作者微博：@tony_关东升
//  作者微信：tony关东升
//  QQ：569418560 邮箱：eorient@sina.com
//  QQ交流群：162030268
///Users/wesley_du/Downloads/iOSBook14/ch12/12.4/Swift/MyNotesWorkspace/PersistenceLayer/PersistenceLayer/dao/NoteDAO.swift:17:8: Could not build Objective-C module 'sqlite3'

import Foundation
//import sqlite3
import sqlite3simulator


let DBFILE_NAME = "NotesList.sqlite3"

open class NoteDAO {
    
    fileprivate var db:OpaquePointer? = nil
    
    //私有DateFormatter属性
    fileprivate var dateFormatter = DateFormatter()
    //私有沙箱目录中属性列表文件路径
    fileprivate var plistFilePath: String!
    
    open static let sharedInstance: NoteDAO = {
        let instance = NoteDAO()
        
        //初始化沙箱目录中属性列表文件路径
        instance.plistFilePath = instance.applicationDocumentsDirectoryFile()
        //初始化DateFormatter
        instance.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //初始化属性列表文件
        instance.createEditableCopyOfDatabaseIfNeeded()
        
        return instance
    }()
    
    //初始化文件
    func createEditableCopyOfDatabaseIfNeeded() {
        
        let cpath = self.plistFilePath.cString(using: String.Encoding.utf8)
        
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("数据库打开失败。")
        } else {
            let sql = "CREATE TABLE IF NOT EXISTS Note (cdate TEXT PRIMARY KEY, content TEXT)"
            let cSql = sql.cString(using: String.Encoding.utf8)
            
            if (sqlite3_exec(db,cSql!, nil, nil, nil) != SQLITE_OK) {
                NSLog("建表失败。")
            }
        }
        sqlite3_close(db)
    }
    
    func applicationDocumentsDirectoryFile() -> String {
        let documentDirectory: NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let path = (documentDirectory[0] as AnyObject).appendingPathComponent(DBFILE_NAME) as String
        return path
    }
    
    //插入Note方法
    open func create(_ model: Note) -> Int {
        
        let cpath = self.plistFilePath.cString(using: String.Encoding.utf8)
        
        if (sqlite3_open(cpath!, &db) != SQLITE_OK) {
            NSLog("数据库打开失败。")
        } else {
            let sql = "INSERT OR REPLACE INTO note (cdate, content) VALUES (?,?)"
            let cSql = sql.cString(using: String.Encoding.utf8)

            //语句对象        
            var statement:OpaquePointer? = nil
            //预处理过程
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                
                let strDate = self.dateFormatter.string(from: model.date as Date)
                let cDate = strDate.cString(using: String.Encoding.utf8)
                
                let cContent = model.content.cString(using: String.Encoding.utf8)
                
                //绑定参数开始
                sqlite3_bind_text(statement, 1, cDate!, -1, nil)
                sqlite3_bind_text(statement, 2, cContent!, -1, nil)
                
                //执行插入
                if (sqlite3_step(statement) != SQLITE_DONE) {
                    NSLog("插入数据失败。")
                }
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(db)
        return 0
    }
    
    //删除Note方法
    open func remove(_ model: Note) -> Int {
        
        let cpath = self.plistFilePath.cString(using: String.Encoding.utf8)
        
        if (sqlite3_open(cpath!, &db) != SQLITE_OK) {
            NSLog("数据库打开失败。")
        } else {
            let sql = "DELETE from note where cdate =?"
            let cSql = sql.cString(using: String.Encoding.utf8)
            
            //语句对象       
            var statement:OpaquePointer? = nil
            //预处理过程
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
 
                let strDate = self.dateFormatter.string(from: model.date as Date)
                let cDate = strDate.cString(using: String.Encoding.utf8)
                
                //绑定参数开始
                sqlite3_bind_text(statement, 1, cDate!, -1, nil)
                //执行删除数据
                if (sqlite3_step(statement) != SQLITE_DONE) {
                    NSLog("删除数据失败。")
                }
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(db)
        return 0
    }
    
    //修改Note方法
    open func modify(_ model: Note) -> Int {

        let cpath = self.plistFilePath.cString(using: String.Encoding.utf8)
        
        if (sqlite3_open(cpath!, &db) != SQLITE_OK) {
            NSLog("数据库打开失败。")
        } else {
            let sql = "UPDATE note set content=? where cdate =?"
            let cSql = sql.cString(using: String.Encoding.utf8)

            //语句对象           
            var statement:OpaquePointer? = nil
            //预处理过程
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                
                let strDate = self.dateFormatter.string(from: model.date as Date)
                let cDate = strDate.cString(using: String.Encoding.utf8)
                
                let cContent = model.content.cString(using: String.Encoding.utf8)
                
                //绑定参数开始
                sqlite3_bind_text(statement, 1, cContent!, -1, nil)
                sqlite3_bind_text(statement, 2, cDate!, -1, nil)
                
                //执行修改数据
                if (sqlite3_step(statement) != SQLITE_DONE) {
                    NSLog("修改数据失败。")
                }
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(db)
        return 0
    }
    
    //查询所有数据方法
    open func findAll() -> NSMutableArray? {

        let cpath = self.plistFilePath.cString(using: String.Encoding.utf8)

        if (sqlite3_open(cpath!, &db) != SQLITE_OK) {
            NSLog("数据库打开失败。")
        } else {
            let sql = "SELECT cdate,content FROM Note"
            let cSql = sql.cString(using: String.Encoding.utf8)
            
            //语句对象
            var statement:OpaquePointer? = nil
            //预处理过程
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                let listData = NSMutableArray()
                //执行查询
                while (sqlite3_step(statement) == SQLITE_ROW) {
                     /*
                    let bufDate = UnsafePointer<Int8>(sqlite3_column_text(statement, 0))
                    let strDate = String.fromCString(bufDate!)!
                    let date : Date = self.dateFormatter.date(from: strDate)!
                    
                    let bufContent = UnsafePointer<Int8>(sqlite3_column_text(statement, 1))
                    let strContent = String.fromCString(bufContent!)!
                    */
                    
                    let buf_Date = sqlite3_column_text(statement, 0)
                    let bufDate = buf_Date?.withMemoryRebound(to: Int8.self, capacity: 1){
                        (ptr: UnsafePointer<Int8>) -> UnsafePointer<Int8> in
                        return ptr
                    }
                    let strDate = String.init(describing: bufDate!)
                    let date : Date = self.dateFormatter.date(from: strDate)!
                    
                    let buf_Content = sqlite3_column_text(statement, 0)
                    let bufContent = buf_Content?.withMemoryRebound(to: Int8.self, capacity: 1){
                        (ptr: UnsafePointer<Int8>) -> UnsafePointer<Int8> in
                        return ptr
                    }
                    let strContent = String.init(describing: bufContent!)
                    
                    let note = Note(date: date, content:strContent)
                    
                    listData.add(note)
                }
                
                sqlite3_finalize(statement)
                sqlite3_close(db)
                
                return listData
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(db)
        return nil
    }
    
    //按照主键查询数据方法
    open func findById(_ model: Note) -> Note? {
        
        let cpath = self.plistFilePath.cString(using: String.Encoding.utf8)
        
        if (sqlite3_open(cpath!, &db) != SQLITE_OK) {
            NSLog("数据库打开失败。")
        } else {
            let sql = "SELECT cdate,content FROM Note where cdate =?"
            let cSql = sql.cString(using: String.Encoding.utf8)
            
            var statement:OpaquePointer? = nil
            //预处理过程
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                //准备参数
                let strDate = self.dateFormatter.string(from: model.date as Date)
                let cDate = strDate.cString(using: String.Encoding.utf8)
                
                //绑定参数开始
                sqlite3_bind_text(statement, 1, cDate!, -1, nil)
                
                //执行查询
                if (sqlite3_step(statement) == SQLITE_ROW) {
                    
                    //let bufDate = UnsafePointer<Int8>(sqlite3_column_text(statement, 0))
                    let buf_Date = sqlite3_column_text(statement, 0)
                    let bufDate = buf_Date?.withMemoryRebound(to: Int8.self, capacity: 1){
                        (ptr: UnsafePointer<Int8>) -> UnsafePointer<Int8> in
                        return ptr
                    }
  
                   // let strDate = String.fromCString(bufDate!)!
                    let strDate = String.init(describing: bufDate!)
                    let date : Date = self.dateFormatter.date(from: strDate)!
                
                    let buf_Content = sqlite3_column_text(statement, 0)
                    let bufContent = buf_Content?.withMemoryRebound(to: Int8.self, capacity: 1){
                        (ptr: UnsafePointer<Int8>) -> UnsafePointer<Int8> in
                        return ptr
                    }
                    
                    //let bufContent = UnsafePointer<Int8>(sqlite3_column_text(statement, 1))
                    //let strContent = String.fromCString(bufContent!)!
                    let strContent = String.init(describing: bufContent!)
                    let note = Note(date: date, content:strContent)
                    
                    sqlite3_finalize(statement)
                    sqlite3_close(db)
                    
                    return note
                }
                
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(db)
        return nil
    }
    
}
