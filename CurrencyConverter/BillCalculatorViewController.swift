//
//  BillCalculatorViewController.swift
//  CurrencyConverter
//
//  Created by Snehil on 11/08/18.
//  Copyright © 2018 Snehil. All rights reserved.
//

import UIKit

class BillCalculatorViewController: UIViewController, CurrenciesListViewControllerDelegate {

    @IBOutlet var txtFields: [UITextField]!
    
    @IBOutlet var btnCurrencyCodes: [UIButton]!
    
    @IBOutlet weak var lblToPay: UILabel!
    var currentTF = UITextField() {
        didSet {
            for tf in txtFields {
                tf.textColor = UIColor.black
            }
            currentTF.textColor = UIColor.red
        }
    }
    
    
    var currentOperation: MathOpration = .none
    var rateFactor = Float(2.0)
    var currentCurrButton : UIButton!
    
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
//            if currentTF == txtCurrency1 {
//                txtCurrency2.text = (inputValue! * rateFactor).normalisedStr()
//            }else {
//                txtCurrency1.text = (inputValue! / rateFactor).normalisedStr()
//            }
        }
    }
    var inputString: String = "" {
        didSet {
            var suffix = ""
            if (inputString.last! == ".") {
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
            let totalBillAmount = Float(txtFields[0].text!)! + Float(txtFields[1].text!)! / rateFactor
            let differenceAmt = Float((totalBillAmount - Float(txtFields[2].text!)! - Float(txtFields[3].text!)! / rateFactor).normalisedStr())!
            if differenceAmt > Float(0) {
                let instructionText = "Pay \(differenceAmt.normalisedStr()) \(btnCurrencyCodes[0].title(for: .normal)!) or \((differenceAmt * rateFactor).normalisedStr()) \(btnCurrencyCodes[1].title(for: .normal)!)"
                self.lblToPay.text = instructionText
                self.lblToPay.textColor = UIColor.red
            }else if differenceAmt < Float(0) {
                let instructionText = "Paying extra \((differenceAmt * Float(-1)).normalisedStr()) \(btnCurrencyCodes[0].title(for: .normal)!) or \((differenceAmt * rateFactor * (-1)).normalisedStr()) \(btnCurrencyCodes[1].title(for: .normal)!)"
                self.lblToPay.text = instructionText
                self.lblToPay.textColor = UIColor.blue
            }else {
                let instructionText = "you are paying right amount"
                self.lblToPay.text = instructionText
                self.lblToPay.textColor = UIColor(red: 24/255.0, green: 190/255.0, blue: 32/255.0, alpha: 1)
            }
//            if txtFields[0].text?.isEmpty == false && txtFields[1].text?.isEmpty == false && txtFields[2].text?.isEmpty == false {
//
//            }
//            if currentTF == txtCurrency1 {
//                txtCurrency2.text = (inputValue! * rateFactor).normalisedStr()
//            }else {
//                txtCurrency1.text = (inputValue! / rateFactor).normalisedStr()
//            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentTF = txtFields[0]
        fetchRate()
        lblToPay.text = "Pay 0 \(btnCurrencyCodes[0].title(for: .normal)!), 0 \(btnCurrencyCodes[1].title(for: .normal)!)"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnTxtFieldFocusAction(_ sender: Any) {
        let btn = sender as! UIButton
        currentTF = txtFields[btn.tag % 200 - 1]
        inputString = currentTF.text!
    }
    
    @IBAction func btnCurrencyAction(_ sender: Any) {
        currentCurrButton = sender as! UIButton
        let currencyListVC = storyboard?.instantiateViewController(withIdentifier: "CurrenciesListViewController") as! CurrenciesListViewController
        currencyListVC.delegate = self
        navigationController?.pushViewController(currencyListVC, animated: false)
    }
    
    @IBAction func btnDigitAction(_ sender: Any) {
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
    
    func updateUI() {
        for tf in txtFields {
            tf.text = "0"
        }
    }
    
    func fetchRate() {
        let curr1Code = btnCurrencyCodes[0].title(for: .normal)!
        let curr2Code = btnCurrencyCodes[1].title(for: .normal)!
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
    
    @IBAction func btnResetAction(_ sender: Any) {
        currentOperation = .none
        op1Str = "0"
        inputString = "0"
        for tf in txtFields {
            tf.text = "0"
        }
        lblToPay.text = "Pay 0 \(btnCurrencyCodes[0].title(for: .normal)!), 0 \(btnCurrencyCodes[1].title(for: .normal)!)"
        lblToPay.textColor = UIColor.green
    }
    
    @IBAction func btnRefreshAction(_ sender: Any) {
    }
    
    @IBAction func btnEditAction(_ sender: Any) {
    }
    
    @IBAction func btnMultiplyAction(_ sender: Any) {
        performMathOperation()
        currentOperation = .multiply
        op1Str = currentTF.text!
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
    
    //MARK: currency list delegate
    func selectedCurrency(currencyCode: String, countryCode: String) {
        navigationController?.popViewController(animated: false)
        currentCurrButton.setTitle(currencyCode, for: .normal)
        if currentCurrButton == btnCurrencyCodes[0] || currentCurrButton == btnCurrencyCodes[2] {
            btnCurrencyCodes[0].setTitle(currencyCode, for: .normal)
            btnCurrencyCodes[2].setTitle(currencyCode, for: .normal)
        }else {
            btnCurrencyCodes[1].setTitle(currencyCode, for: .normal)
            btnCurrencyCodes[3].setTitle(currencyCode, for: .normal)
        }
        fetchRate()
    }
    
}
