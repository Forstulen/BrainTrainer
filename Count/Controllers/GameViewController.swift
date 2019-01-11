//
//  GameViewController
//  Count
//
//  Created by Romain Tholimet on 07/12/2018.
//  Copyright © 2018 Romain Tholimet. All rights reserved.
//

import UIKit
import os.log
import AsyncTimer
import Spring

class GameViewController: UIViewController {
    //MARK: Constants
    let multiplication                  = "x"
    let addition                        = "+"
    let substraction                    = "-"
    let division                        = "/"
    let completeWord                    = "Great!"
    let skipHint                        = "Tap here to skip!"
    
    
    //MARK: Properties
    @IBOutlet weak var gameZoneView: UIView!
    @IBOutlet weak var gameValueLabel: UILabel!
    @IBOutlet weak var gameHeaderLabel: SpringLabel!
    @IBOutlet weak var gameOperatorStackView: UIStackView!
    @IBOutlet weak var drawingZoneCanvas: UIImageView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    //MARK: Game Properties
    private var gameInteractionViews    = [GameInteractionView]()
    private var selectedViews           = [GameInteractionView]()
    private var expectedGameViewItems   = [GameViewType]()
    private var calculation : Calculation = CalculationManager.shared().getCurrentCalculation(level: CalculationManager.shared().getCurrentLevel())!
    
    private var isConfigured            = false
    private var canSkip                 = false
    private var refreshCounter          = 0
    private var date    : Date          = Date()
    
    private lazy var timer: AsyncTimer  = {
        return AsyncTimer(interval: .milliseconds(100), repeats: true) { [weak self] in
            self?.updateTimer()
        }
    }()

    //MARK: Drawing
    private var path                        = UIBezierPath()
    private var shapeLayer : CAShapeLayer   = CAShapeLayer()
    private var points                      = [CGPoint]()
    private var isPathStarted : Bool        = false
    
    //MARK: ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        self.backButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !isConfigured {
            self.resetCalculation()
            self.initializeGameView()
            self.initializeOperatorsView()
            isConfigured = true
            
            if CalculationManager.shared().mode == .timeAttack {
                self.date = Date()
                self.timer.start()
            }
        }
    }
    
    //MARK: Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.initializePath(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        self.createPath(touches : touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        self.finishPath(touches : touches)
    }
    
    //MARK: Actions
    @IBAction func refreshGameViews(_ sender: Any) {
        resetCalculation()
        initializeGameView()
        checkCanSkip()
    }
    @IBAction func skipCalculation(_ sender: Any) {
        if canSkip {
            self.selectNewCalculation()
        }
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    private func initializeGameView() {
        let radius      = (self.gameZoneView.frame.width / 2.0) * 0.75 //75%
        let center      = CGPoint(x: self.gameZoneView.frame.width / 2.0, y: self.gameZoneView.frame.height / 2.0)
        
        if CalculationManager.shared().mode == .random {
            self.gameHeaderLabel.text = "∞"
        } else if CalculationManager.shared().mode != .timeAttack {
            self.gameHeaderLabel.text = "\(CalculationManager.shared().getCurrentIndex(level: CalculationManager.shared().getCurrentLevel()) + 1)/\(CalculationManager.shared().getTotalCalculationNumber(level: CalculationManager.shared().getCurrentLevel()))"
        }
        
        for gameView in gameInteractionViews.filter({ (GameInteractionView) -> Bool in
            if GameInteractionView.type == .number {
                return true
            } else {
                return false
            }
        }) {
            if let index = gameInteractionViews.index(of: gameView) {
                gameInteractionViews.remove(at: index).removeFromSuperview()
            }
        }
        
        for i in 0..<self.calculation.numbers!.count {
            let customView  = GameInteractionView.instantiate()
            let val         = self.calculation.numbers![i]
    
            customView.arithmeticExpression = .num
            customView.configureView(value : String(val), index: i, maximumViewNumber: self.calculation.numbers!.count, radius: Float(radius), center : center)
            gameInteractionViews.append(customView)
            gameZoneView.addSubview(customView)
            gameValueLabel.text = String(self.calculation.number!)
        }
    }
    
    private func selectNewCalculation() {
        if let calc = CalculationManager.shared().getNextCalculation(level: CalculationManager.shared().getCurrentLevel()) {
            self.calculation = calc
            self.resetCalculation()
            self.initializeGameView()
            self.canSkip = false
            self.refreshCounter = 0
        } else {
            self.timer.stop()
            
            let record = CalculationManager.shared().setPersonalBest(time: self.gameHeaderLabel.text!)
            
            if record {
                self.gameHeaderLabel.animate()
            }
        }
    }
    
    private func updateTimer() {
        let interval: TimeInterval = abs(self.date.timeIntervalSinceNow)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "mm:ss:SS"
        
        self.gameHeaderLabel.text = formatter.string(from: Date(timeIntervalSinceReferenceDate: interval))
    }

    
    private func selectGameView(touchLocation : CGPoint) -> Bool {
        for subview in gameInteractionViews {
            if !selectedViews.contains(where: {$0 === subview}) {
                let obstacleViewFrame = self.view.convert(subview.frame, from: subview.superview)
                
                if obstacleViewFrame.contains(touchLocation) {
                    if expectedGameViewItems.contains(where: { element in
                        if element == subview.type {
                            return true
                        }
                        return false
                    }) {
                        if let index = expectedGameViewItems.firstIndex(of: subview.type) {
                            expectedGameViewItems.remove(at: index)
                        }
                        selectedViews.append(subview)
                        
                        if selectedViews.count == 3 {
                            endDrawing()
                            applyCalculation()
                        }
                        
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    private func applyCalculation() {
        let firstNumber     = getGameView(type: .number)
        let secondNumber    = getGameView(type: .number)
        let firstValue      = firstNumber?.value
        let secondValue     = secondNumber?.value
        let firstOperator   = getGameView(type: .op)?.arithmeticExpression
        
        let minimumValue    = Int(firstValue ?? "0") ?? 0 > Int(secondValue ?? "0") ?? 0 ? Int(secondValue ?? "0") ?? 0 : Int(firstValue ?? "0") ?? 0
        let maximumValue    = Int(firstValue ?? "0") ?? 0 < Int(secondValue ?? "0") ?? 0 ? Int(secondValue ?? "0") ?? 0 : Int(firstValue ?? "0") ?? 0
        
        var result : Int?
        
        switch firstOperator {
            case .add?:
                result = minimumValue + maximumValue
            case .mul?:
                result = minimumValue * maximumValue
            case .sub?:
                result = maximumValue - minimumValue
            case .div?:
                if (minimumValue != 0 && maximumValue != 0) && maximumValue % minimumValue == 0  {
                    result = maximumValue / minimumValue
                } else {
                    result = nil
                }
            default:
                result = minimumValue + maximumValue
        }
        
        guard result != nil else {
            firstNumber?.shake()
            secondNumber?.shake()
            resetCalculation()
            return
        }
        
        firstNumber?.value = String(result!)
        firstNumber?.fadeOut(initColor: UIColor.white)
        removeGameView(view: secondNumber!)
        resetCalculation()
        checkResult(result: result!)
    }
    
    private func getGameView(type : GameViewType) -> GameInteractionView? {
        let first = selectedViews.first { (GameInteractionView) -> Bool in
            if GameInteractionView.type == type {
                return true
            }
            return false
        }
        
        selectedViews = selectedViews.filter({ (GameInteractionView) -> Bool in
            GameInteractionView !== first
        })
        
        return first
    }

    
    private func resetCalculation() {
        expectedGameViewItems = [.number, .number, .op]
        selectedViews.removeAll()
    }
    
    private func initializeOperatorsView() {
        let add     = GameInteractionView.instantiate()
        let minus   = GameInteractionView.instantiate()
        let mult    = GameInteractionView.instantiate()
        let div     = GameInteractionView.instantiate()
        
        add.arithmeticExpression    = .add
        minus.arithmeticExpression  = .sub
        mult.arithmeticExpression   = .mul
        div.arithmeticExpression    = .div
        
        add.value   = self.addition
        minus.value = self.substraction
        mult.value  = self.multiplication
        div.value   = self.division
        
        let operators = [add, minus, mult, div]
        
        for op in operators {
            op.translatesAutoresizingMaskIntoConstraints = false
            op.heightAnchor.constraint(equalToConstant: gameOperatorStackView.bounds.height).isActive = true
            op.widthAnchor.constraint(equalToConstant: gameOperatorStackView.bounds.width / 4.5).isActive = true
            gameOperatorStackView.addArrangedSubview(op)
        }
        gameInteractionViews += operators
    }
    
    private func removeGameView(view : GameInteractionView) {
        let radius      = (self.gameZoneView.frame.width / 2.0) * 0.75 //75%
        let center      = CGPoint(x: self.gameZoneView.frame.width / 2.0, y: self.gameZoneView.frame.height / 2.0)
        
        if let index = gameInteractionViews.index(of: view) {
            gameInteractionViews.remove(at: index).removeFromSuperview()
        }
        let count = gameInteractionViews.filter{ $0.type == .number }.count
        
        for i in 0 ..< gameInteractionViews.count {
            if gameInteractionViews[i].type == .number {
                gameInteractionViews[i].reconfigureView(index: i, maximumViewNumber: count, radius: Float(radius), center : center)
            }
        }
    }
    
    private func checkCanSkip() {
        self.refreshCounter += 1
        if self.refreshCounter >= 3 && CalculationManager.shared().mode != .timeAttack {
            self.gameHeaderLabel.text = self.skipHint
            self.canSkip = true
        }
    }
    
    private func checkResult(result : Int) {
        if result == self.calculation.number {
            self.gameValueLabel.text = self.completeWord
            
            let numbers = gameInteractionViews.filter{ $0.type == .number }
            var lastGameView : GameInteractionView?
            
            for view in numbers {
                if Int(view.value) != self.calculation.number {
                    self.removeGameView(view: view)
                } else {
                    lastGameView = view
                }
            }
            
            lastGameView!.fadeIn(finalColor: UIColor.green)
            
            _ = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
                self.selectNewCalculation()
            }
            
        } else {
            let numbers = gameInteractionViews.filter{ $0.type == .number }
            
            if numbers.count == 1 {
                for view in numbers {
                    view.shake()
                }
                resetCalculation()
                initializeGameView()
                checkCanSkip()
            }
        }
    }
    
    //MARK: Drawing
    private func initializePath(touches : Set<UITouch>) {
        let isGameViewSelected = self.isViewSelected(touches: touches)
        self.points.removeAll()
        if isGameViewSelected {
            let lastSelectedView = self.selectedViews.last
            self.points.append((lastSelectedView?.superview!.convert((lastSelectedView?.center)!, to: self.view))!)
            isPathStarted = true
        } else {
            isPathStarted = false
        }
    }
    
    private func createPath(touches : Set<UITouch>) {
        if (isPathStarted) {
            let isGameViewSelected = self.isViewSelected(touches: touches)
            
            var index = 2
            
            if isGameViewSelected || points.count >= 3 {
                if self.selectedViews.count < 2 {
                    return
                }
                
                let selectedView = self.selectedViews[1]
                
                if points.count >= index {
                    self.points[index - 1] = ((selectedView.superview!.convert((selectedView.center), to: self.view)))
                } else {
                    self.points.append((selectedView.superview!.convert((selectedView.center), to: self.view)))
                }
                
                index = 3
            }
            
            if points.count >= index {
                self.points[index - 1] = touches.first!.location(in: self.view)
            } else {
                self.points.append(touches.first!.location(in: self.view))
            }
            
            
            self.path = UIBezierPath()
            
            var paths = [UIBezierPath]()
            
            for i in 0..<(self.points.count - 1) {
                let bezier = UIBezierPath()
                
                bezier.move(to: self.points[i])
                if i + 1 < self.points.count {
                    bezier.addLine(to: self.points[i + 1])
                }
                
                paths.append(bezier)
            }
            
            for path in paths {
                self.path.append(path)
            }
            
            self.shapeLayer.removeFromSuperlayer()
            self.shapeLayer = CAShapeLayer()
            self.shapeLayer.path = self.path.cgPath
            self.shapeLayer.strokeColor = UIColor.white.cgColor
            self.shapeLayer.lineWidth = 8.0
            self.shapeLayer.fillColor = UIColor.clear.cgColor
            
            self.view.layer.insertSublayer(shapeLayer, at: 0)
            self.view.setNeedsDisplay()
        }
    }
    
    private func finishPath(touches : Set<UITouch>) {
        if selectedViews.count != 3 {
            resetCalculation()
        }
        
        self.endDrawing()
    }
    
    private func isViewSelected(touches: Set<UITouch>) -> Bool{
        if let touch = touches.first {
            let touchLocation = touch.location(in: self.view)
            return selectGameView(touchLocation: touchLocation)
        }
        return false
    }
    
    private func endDrawing() {
        self.points.removeAll()
        self.path = UIBezierPath()
        self.shapeLayer.removeFromSuperlayer()
        self.shapeLayer = CAShapeLayer()
        self.view.setNeedsDisplay()
        isPathStarted = false
    }
}

