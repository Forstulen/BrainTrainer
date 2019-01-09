//
//  CalculationManager.swift
//  Count
//
//  Created by Romain Tholimet on 09/12/2018.
//  Copyright © 2018 Romain Tholimet. All rights reserved.
//

import Foundation
import ObjectMapper

enum GameMode {
    case practice
    case timeAttack
}

class CalculationManager {
    // MARK: - Properties
    let calculationFileName : String                            = "calculations.json"
    let saveFileName        : String                            = "save.json"
    let noPersonalBest      : String                            = "--"
    var calculations        : [LevelDifficulty : [Calculation]] = [LevelDifficulty : [Calculation]]()
    var currentIndexes      : [LevelDifficulty : Int]           = [LevelDifficulty : Int]()
    var status              : Status                            = Status(indexes: [], pb: "")
    var currentDifficulty   : LevelDifficulty                   = .easy
    var mode                : GameMode                          = .practice
    
    var timeAttackList      : [Calculation]                     = [Calculation]()
    
    subscript(level : LevelDifficulty) -> Calculation {
        let index       = currentIndexes[level]
        let calculation = calculations[level]![index! + 1]
        
        currentIndexes[level] = index! + 1
        
        return calculation
    }
    
    private static var sharedCalculationkManager: CalculationManager = {
        let calculationManager = CalculationManager()
        
        calculationManager.currentIndexes[.easy]    = 0
        calculationManager.currentIndexes[.medium]  = 0
        calculationManager.currentIndexes[.hard]    = 0
        
        calculationManager.calculations[.easy]      = [Calculation]()
        calculationManager.calculations[.medium]    = [Calculation]()
        calculationManager.calculations[.hard]      = [Calculation]()
        
        calculationManager.loadData()
        
        return calculationManager
    }()
    
    deinit {
        self.saveData()
    }
    
    // Initialization
    private init() {
    }
    
    // MARK: - Accessors
    class func shared() -> CalculationManager {
        return sharedCalculationkManager
    }
    
    //MARK: Private Methods
    private func getCalculations(array : [Calculation], level : LevelDifficulty) -> [Calculation] {
        let t = array.filter({ c -> Bool in
            c.level == level
        })
        
        return t
    }
    
    private func createTimeAttackList() {
        self.timeAttackList.removeAll()
        
        var easy = [Calculation]()
        
        for _ in 0..<4 {
            easy.append((self.calculations[.easy]?.randomElement()!)!)
        }
        
        var medium = [Calculation]()
        
        for _ in 0..<2 {
            medium.append((self.calculations[.medium]?.randomElement()!)!)
        }
        
        let hard : [Calculation] = [(self.calculations[.hard]?.randomElement())!]
        
        self.timeAttackList = easy + medium + hard
    }
    
    //MARK: Public Methods
    func loadData() {
        let calculations = Mapper<Calculation>().mapArray(JSONfile: calculationFileName)
        
        let easy = getCalculations(array: calculations ?? [Calculation](), level: .easy)
        let medium = getCalculations(array: calculations ?? [Calculation](), level: .medium)
        let hard = getCalculations(array: calculations ?? [Calculation](), level: .hard)
        
        self.calculations[.easy]?   += easy
        self.calculations[.medium]?  += medium
        self.calculations[.hard]?    += hard
        
        self.manipulateFile(fileName: saveFileName) { (url) in
            let JSONString = try String(contentsOf: url, encoding: .utf8)
                
            if let status = Mapper<Status>().map(JSONString: JSONString) {
                self.status = status
    
                if (self.status.indexes?.count)! >= 3 {
                    self.currentIndexes[.easy] = self.status.indexes![0]
                    self.currentIndexes[.medium] = self.status.indexes![1]
                    self.currentIndexes[.hard] = self.status.indexes![2]
                }
            }
        }
    }
    
    func manipulateFile(fileName : String, block : (URL) throws -> Void) {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            let fileURL = documentsDirectory.appendingPathComponent("save.json")
            do {
                try block(fileURL)
            } catch {
                print("an error happened while manipulating the file")
            }
        }
    }
    
    func saveData() {
        let pb      = self.status.pb
        
        self.status.indexes = [self.currentIndexes[.easy], self.currentIndexes[.medium], self.currentIndexes[.hard]] as? [Int]
        self.status.pb      = pb
        
        let JSONString = Mapper().toJSONString(status, prettyPrint: true)
        
        self.manipulateFile(fileName: saveFileName) { (url) in
            try JSONString!.write(to: url, atomically: false, encoding: .utf8)
        }
    }
    
    func setMode(mode : GameMode) {
        self.mode = mode
        
        if self.mode == .timeAttack {
            self.createTimeAttackList()
        }
    }
    
    func getCurrentCalculation(level : LevelDifficulty) -> Calculation? {
        if self.mode == .timeAttack {
            let calc = self.timeAttackList.first
            
            return calc
        } else {
            guard let index = self.currentIndexes[level] else {
                return nil
            }
            return self.calculations[level]![index]
        }
    }
    
    func getNextCalculation(level : LevelDifficulty) -> Calculation? {
        if self.mode == .timeAttack {
            if self.timeAttackList.count > 1 {
                self.timeAttackList.remove(at: 0)
                
                return self.timeAttackList.first
            }
  
            return nil
        } else {
            if let calc = self.calculations[level]?[(self.currentIndexes[level]! + 1) % (self.calculations[level]?.count)!] {
                self.currentIndexes[level] = (self.currentIndexes[level]! + 1) % (self.calculations[level]?.count)!
                return calc
            }
            return nil
        }
    }
    
    func getTotalCalculationNumber(level : LevelDifficulty) -> Int {
        return (self.calculations[level]?.count)!
    }
    
    func getCurrentIndex(level : LevelDifficulty) -> Int {
        return self.currentIndexes[level]!
    }
    
    func getCurrentLevel() -> LevelDifficulty {
        return self.currentDifficulty
    }
    
    func setCurrentLevel(level : LevelDifficulty) {
        self.currentDifficulty = level
    }
    
    func setPersonalBest(time : String) -> Bool {
        var isRecordBeaten = false
        
        if status.pb!.isEmpty || status.pb! > time {
            status.pb = time
            isRecordBeaten = true
        }
        
        saveData()
        
        return isRecordBeaten
    }
    
    func getPersonalBest() -> String {
        if (status.pb?.isEmpty)! {
            return self.noPersonalBest
        }
        return self.status.pb!
    }
}
