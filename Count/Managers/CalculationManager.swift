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
    case random
}

class CalculationManager {
    // MARK: - Error
    public enum Calcul: Error {
        case divideError(String)
    }
    
    // MARK: - Struct
    struct RandomCalculationEntity {
        public enum Status {
            case Initial
            case Calculated
        }
        
        var number : Int
        var status : Status = .Initial
    }
    
    
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
        } else if self.mode == .random {
            return self.randomCalcul()
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
        } else if self.mode == .random {
            return self.randomCalcul()
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
    
    func randomCalcul() -> Calculation {
        var possibleNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 25, 50, 100].shuffled()
        var selectedNumbers = [RandomCalculationEntity]()
        
        //Select the numbers will be used to calculate the result
        for _ in 0...Int.random(in: 3...6) {
            let entity = RandomCalculationEntity(number: possibleNumbers.removeFirst(), status: .Initial)

            selectedNumbers.append(entity)
        }
        
        var array = selectedNumbers.map( {$0.number} )
        
        //DEBUG
        array.map( { print("\($0)")} )
        print(" ")
        
        let x: Range = (selectedNumbers.count / 2)..<selectedNumbers.count
        //Add "coefficient" for add sub and mul
        let operations = ["add", "add", "sub", "sub", "mul", "mul", "div"]
        var maxOperationsNumber = Int.random(in: x.clamped(to: (x.min() ?? 2)..<selectedNumbers.count))
        
        let operationBlock = { (operationNumberLeft: Int, op : (Int, Int) throws -> Int) -> Void in
            var entity1 : RandomCalculationEntity? = nil
            var entity2 : RandomCalculationEntity? = nil
            
            //Be sure to use all the calculated numbers
            if (operationNumberLeft <= 2) {
                if let index = selectedNumbers.firstIndex(where: { $0.status == .Calculated }) {
                    entity1 = selectedNumbers.remove(at: index)
                }
                
                if let index = selectedNumbers.firstIndex(where: { $0.status == .Calculated }) {
                    entity2 = selectedNumbers.remove(at: index)
                }
            }
            
            if entity1 == nil {
                entity1 = selectedNumbers.remove(at: Int.random(in: 0..<selectedNumbers.count))
            }
            
            if entity2 == nil {
                entity2 = selectedNumbers.remove(at: Int.random(in: 0..<selectedNumbers.count))
            }
            
            let minimumValue    = entity1!.number > entity2!.number ? entity2!.number : entity1!.number
            let maximumValue    = entity2!.number > entity1!.number ? entity2!.number : entity1!.number
            
            do {
                let newValue = try op(maximumValue, minimumValue)
        
                entity1!.number  = newValue
                entity1!.status  = .Calculated
            } catch _ {
                selectedNumbers.append(entity2!)
            }
        
            defer {
                selectedNumbers.append(entity1!)
            }
        }
        
        //Do calculations by pair
        for i in 0...maxOperationsNumber {
            let op = operations.randomElement()
            
            if selectedNumbers.count == 1 {
                break
            }
            
            switch op {
                case "add":
                    operationBlock(maxOperationsNumber - i, { (x :Int, y: Int) -> Int in
                        print("\(x) + \(y) = \(x + y)")
                        return x + y })
                case "sub":
                    operationBlock(maxOperationsNumber - i, { (x :Int, y: Int) -> Int in
                        print("\(x) - \(y) = \(x - y)")
                        return x - y })
                case "mul":
                    operationBlock(maxOperationsNumber - i, { (x :Int, y: Int) -> Int in
                        print("\(x) * \(y) = \(x * y)")
                        return x * y })
                case "div":
                    operationBlock(maxOperationsNumber - i, { (x :Int, y: Int) -> Int in
                        if y != 0 && x % y == 0 {
                            print("\(x) / \(y) = \(x / y)")
                            return x / y
                        }
                        maxOperationsNumber += 1
                        throw Calcul.divideError("Cannot divide")
                    })
                default:
                    operationBlock(maxOperationsNumber - i, { (x :Int, y: Int) -> Int in return x + y })
            }
        }
        
        //Remove any number which could be equals to the target number
    
        let n = selectedNumbers.filter( { $0.status == .Calculated } ).first!.number
        
        array.removeAll(where: { $0 == n })
        
        return Calculation(numbers: array, number: n)
    }
}
