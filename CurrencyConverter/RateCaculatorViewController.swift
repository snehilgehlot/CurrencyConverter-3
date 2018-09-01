//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Snehil on 05/08/18.
//  Copyright © 2018 Snehil. All rights reserved.
//

import UIKit

enum MathOpration {
    case plus
    case minus
    case multiply
    case devide
    case equalTo
    case none
}

class RateCalculatorViewController: UIViewController, UITextFieldDelegate, CurrenciesListViewControllerDelegate {

    @IBOutlet weak var imgCurr1: UIImageView!
    @IBOutlet weak var imgCurr2: UIImageView!
    @IBOutlet weak var txtCurrency1: UITextField!
    @IBOutlet weak var txtCurrency2: UITextField!
    @IBOutlet weak var btnCurrency1: UIButton!
    @IBOutlet weak var btnCurrency2: UIButton!
    @IBOutlet weak var lblRateEquation1: UILabel!
    @IBOutlet weak var lblRateEquation2: UILabel!
    var op1Str = "0"
    var op2Str: String = "" {
        didSet {
            if op2Str == "" {
                return
            }
            var suffix = ""
            if (op2Str.last! == ".") {
                suffix = "."
            }
            if op2Str.hasSuffix(".0") {
                suffix = ".0"
            }
            let inputValue = Float(op2Str)
            currentTF.text = inputValue!.normalisedStr() + suffix
            if op2Str != currentTF.text {
                op2Str = currentTF.text!
            }
            if currentTF == txtCurrency1 {
                txtCurrency2.text = (inputValue! * rateFactor).normalisedStr()
            }else {
                txtCurrency1.text = (inputValue! / rateFactor).normalisedStr()
            }
        }
    }
    var inputString: String = "" {
        didSet {
            var suffix = ""
            if (inputString.last! == "."){
                suffix = "."
            }
            if inputString.hasSuffix(".0") {
                suffix = ".0"
            }
            let inputValue = Float(inputString)
            currentTF.text = inputValue!.normalisedStr() + suffix
            if inputString != currentTF.text {
            inputString = currentTF.text!
            }
            if currentTF == txtCurrency1 {
                txtCurrency2.text = (inputValue! * rateFactor).normalisedStr()
            }else {
                txtCurrency1.text = (inputValue! / rateFactor).normalisedStr()
            }
        }
    }
    
    var currentTF: UITextField = UITextField() {
        didSet {
            txtCurrency1.textColor = UIColor.black
            txtCurrency2.textColor = UIColor.black
            currentTF.textColor = UIColor.red
        }
    }
    var currentOperation: MathOpration = .none
    var rateFactor = Float(2.0)
    var currentCurrButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentCurrButton = btnCurrency1
        txtCurrency1.text = "0"
        txtCurrency2.text = "0"
        currentTF = txtCurrency1
        fetchRate()
//        let digitContainer = self.view.viewWithTag(500)!
//        for subview in digitContainer.subviews {
////            print("ht = \(subview.bounds.height), wd = \(subview.bounds.width)")
////            (subview as! UIButton).layer.cornerRadius = subview.bounds.width/2
////            (subview as! UIButton).clipsToBounds = true
//            subview.backgroundColor = UIColor.clear
//
//            let circleView = UIView(frame: CGRect(x: 0, y: 0, width: subview.bounds.width, height: subview.bounds.width))
//            circleView.backgroundColor = UIColor.white
//            circleView.center = subview.center
//            circleView.layer.cornerRadius = circleView.bounds.width/2
//            circleView.clipsToBounds = true
//            digitContainer.insertSubview(circleView, belowSubview: subview)
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let digitContainer = self.view.viewWithTag(500)!
        for subview in digitContainer.subviews {
            //            print("ht = \(subview.bounds.height), wd = \(subview.bounds.width)")
            //            (subview as! UIButton).layer.cornerRadius = subview.bounds.width/2
            //            (subview as! UIButton).clipsToBounds = true
            subview.backgroundColor = UIColor.clear
            
            let circleView = UIView(frame: CGRect(x: 0, y: 0, width: subview.bounds.width, height: subview.bounds.width))
            circleView.backgroundColor = UIColor.white
            circleView.center = subview.center
            circleView.layer.cornerRadius = circleView.bounds.width/2
            circleView.clipsToBounds = true
            digitContainer.insertSubview(circleView, belowSubview: subview)
        }
    }
    
//    func normalisedStr(_ str: String) -> String {
//        if str.hasSuffix(".00") {
//            let index = str.index(of: ".")!
//            return String(str[..<index])
//        }
//        return str
//    }
    
    @IBAction func btnTxtCurrency1Action(_ sender: Any) {
        if currentTF != txtCurrency1 {
        currentTF = txtCurrency1
            currentOperation = .none
            op1Str = "0"
            inputString = "0"
        }
        
    }
    @IBAction func btnTxtCurrency2Action(_ sender: Any) {
        if currentTF != txtCurrency2 {
            currentTF = txtCurrency2
            currentOperation = .none
            op1Str = "0"
            inputString = "0"
        }
    }
    func fetchRate() {
        let curr1Code = btnCurrency1.title(for: .normal)!
        let curr2Code = btnCurrency2.title(for: .normal)!
        let rateApi = "https://free.currencyconverterapi.com/api/v6/convert?q=\(curr1Code)_\(curr2Code)&compact=y"
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: URL(string: rateApi)!) { (data, resp, err) in
            do {
            let resultDict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            let key = "\(curr1Code)_\(curr2Code)"
                let valueDict = (resultDict as! [String: [String: NSNumber]])[key]
                let val = valueDict!["val"]
                self.rateFactor = val!.floatValue
                DispatchQueue.main.async {
                    self.updateUI()
                }
            }catch {
                
            }
        }
        dataTask.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnDigitPressed(_ sender: Any) {
        let tag = (sender as! UIButton).tag
        var str = ""
        if currentOperation == .none {
            str = inputString
        }else {
            str = op2Str
        }
        
        if str.contains("."){
            let range: Range<String.Index> = str.range(of: ".")!
            let index: Int = str.distance(from: str.startIndex, to: range.lowerBound)
            if index == str.count - 3 {
                return
            }
        }
        switch tag % 100 {
        case 0:
            str = str + "0"
        case 1:
            str = str + "1"
        case 2:
            str = str + "2"
        case 3:
            str = str + "3"
        case 4:
            str = str + "4"
        case 5:
            str = str + "5"
        case 6:
            str = str + "6"
        case 7:
            str = str + "7"
        case 8:
            str = str + "8"
        case 9:
            str = str + "9"
        default:
            break
        }
        
        if currentOperation == .none {
            inputString = str
        }else {
            op2Str = str
        }
    }
    
    @IBAction func btnDecimalAction(_ sender: Any) {
        if currentOperation == .none {
            if inputString.contains(".") == false {
                inputString = inputString + "."
            }
        }else {
            if op2Str.contains(".") == false {
                op2Str = op2Str + "."
            }
        }
    }
    
    @IBAction func btnDeleteAction(_ sender: Any) {
//        if Float(currentTF.text!) != 0.0 {
            if currentOperation == .none {
                if inputString.count == 1 {
                    inputString = "0"
                }else {
                inputString.removeLast()
                }
                
            }else {
                if op2Str.count == 1 {
                    op2Str = "0"
                }else {
                op2Str.removeLast()
                }
            }
//        }
    }
    @IBAction func btnEqualToAction(_ sender: Any) {
        performMathOperation()
        currentOperation = .none
    }
    @IBAction func btnMinusAction(_ sender: Any) {
        performMathOperation()
        currentOperation = .minus
        op1Str = currentTF.text!
    }
    @IBAction func btnPlusAction(_ sender: Any) {
        performMathOperation()
        currentOperation = .plus
        op1Str = currentTF.text!
    }
    @IBAction func btnDevidedByAction(_ sender: Any) {
        performMathOperation()
        currentOperation = .devide
        op1Str = currentTF.text!
    }
    @IBAction func btnMultiplyAction(_ sender: Any) {
        performMathOperation()
        currentOperation = .multiply
        op1Str = currentTF.text!
    }
    
    @IBAction func btnEditAction(_ sender: Any) {
        //set custom rate
    }
    @IBAction func btnRefreshAction(_ sender: Any) {
        //hit api to fetch current rates
    }
    
    @IBAction func btnResetAction(_ sender: Any) {
        currentOperation = .none
        op1Str = "0"
        inputString = "0"
    }
    
    @IBAction func btnCurr1Action(_ sender: Any) {
        //show list of curr to choose
        currentCurrButton = btnCurrency1
        let currencyListVC = storyboard?.instantiateViewController(withIdentifier: "CurrenciesListViewController") as! CurrenciesListViewController
        currencyListVC.delegate = self
        navigationController?.pushViewController(currencyListVC, animated: false)
    }
    @IBAction func btnCurr2Action(_ sender: Any) {
        //show list of curr to choose
        currentCurrButton = btnCurrency2
        let currencyListVC = storyboard?.instantiateViewController(withIdentifier: "CurrenciesListViewController") as! CurrenciesListViewController
        currencyListVC.delegate = self
        navigationController?.pushViewController(currencyListVC, animated: false)
    }
    
    func updateUI() {
        let curr1Code = btnCurrency1.title(for: .normal)!
        let curr2Code = btnCurrency2.title(for: .normal)!
        lblRateEquation1.text = "\(curr1Code) 1 = \(rateFactor) \(curr2Code)"
        lblRateEquation2.text = "\(curr2Code) 1 = \(1/rateFactor) \(curr1Code)"
        if currentCurrButton == btnCurrency1 {
            currentTF = txtCurrency1
            inputString = txtCurrency1.text!
        }else {
            currentTF = txtCurrency2
            inputString = txtCurrency2.text!
        }
        
        
    }
    
    func performMathOperation() {
        if currentOperation == .none {
            return
        }
        guard let opOne = Float(op1Str) else {
            return
        }
        guard let opTwo = Float(op2Str) else {
            return
        }
        var result = Float(0.0)
        switch currentOperation {
        case .plus:
            result = opOne + opTwo
        case .minus:
            result = opOne - opTwo
        case .multiply:
            result = opOne * opTwo
        case .devide:
            result = opOne / opTwo
        default:
            result = opOne
        }
        inputString = String(format: "%.2f", result)
//        currentTF.text = String(format: "%.2f", result)
        currentOperation = .none
        op2Str = ""
    }
    
    //MARK: textfield delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        txtCurrency1.textColor = UIColor.black
        txtCurrency2.textColor = UIColor.black
        currentTF = textField
        currentTF.textColor = UIColor.red
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text!.last == "." {
            textField.text = textField.text! + "00"
        }
    }
    
    //MARK: currency list delegate
    func selectedCurrency(currencyCode: String, countryCode: String) {
        navigationController?.popViewController(animated: false)
        currentCurrButton.setTitle(currencyCode, for: .normal)
        if currentCurrButton == btnCurrency1 {
            self.imgCurr1.image = UIImage(named: countryCode.lowercased())
        }else {
            self.imgCurr2.image = UIImage(named: countryCode.lowercased())
        }
        fetchRate()
    }
    
}

