//
//  CurrenciesListViewController.swift
//  CurrencyConverter
//
//  Created by Snehil on 09/08/18.
//  Copyright © 2018 Snehil. All rights reserved.
//

import UIKit

protocol CurrenciesListViewControllerDelegate {
    func selectedCurrency(currencyCode: String, countryCode: String)
}

class CurrenciesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    var delegate: CurrenciesListViewControllerDelegate?
    var dictCurrencies = [String:[String:String]]()
    var arrCurrencies = [String]()
    var arrFilteredCurrencties = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
        let jsonStr = try String.init(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Countries_Currencies", ofType: "txt")!))
            let data = jsonStr.data(using: .utf8)
            do {
            let jsonObj = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                dictCurrencies = (jsonObj as! [String: AnyObject])["results"] as! [String: [String:String]]
                arrCurrencies = dictCurrencies.keys.sorted()
                arrFilteredCurrencties = arrCurrencies
                tblView.reloadData()
            }catch {
                
            }
        }catch {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnCloseAction(_ sender: Any) {
    }
    
    //MARK: tableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFilteredCurrencties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let code = arrFilteredCurrencties[indexPath.row]
        let dictCurrency = dictCurrencies[code]
        let cellId = "CurrencyCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        let imgFlag = cell?.contentView.viewWithTag(101) as! UIImageView
        imgFlag.image = UIImage(named: code.lowercased())
        let lblCurrencyCode = cell?.contentView.viewWithTag(102) as! UILabel
        lblCurrencyCode.text = dictCurrency!["currencyId"]
        let lblCountryName = cell?.contentView.viewWithTag(103) as! UILabel
        lblCountryName.text = dictCurrency!["name"]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dictSel = dictCurrencies[arrFilteredCurrencties[indexPath.row]]
        
        self.delegate?.selectedCurrency(currencyCode: dictSel!["currencyId"]!, countryCode: dictSel!["id"]!)
    }
    
    //MARK: searchbar delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            self.arrFilteredCurrencties = self.arrCurrencies
        }else {
//        self.arrFilteredCurrencties = arrCurrencies.filter({$0.hasPrefix(searchText.uppercased())})
            self.arrFilteredCurrencties = arrCurrencies.filter({(dictCurrencies[$0]!["currencyId"]!).hasPrefix(searchText.uppercased())})
        }
        tblView.reloadData()
    }
}
