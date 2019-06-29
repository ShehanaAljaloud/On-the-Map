//
//  ListViewController.swift
//  On The Map
//
//  Created by Shehana Aljaloud on 06/06/2019.
//  Copyright © 2019 Shehana Aljaloud. All rights reserved.
//

import Foundation
import UIKit

class ListViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Storage.studentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID = "studentTableViewCell"
        let cell =  tableView.dequeueReusableCell(withIdentifier: cellID) as! ListViewCell
        let student = Storage.studentLocations[(indexPath as NSIndexPath).row]
        cell.nameLabel.text = "\(student.firstName) \(student.lastName)"
        cell.URLLabel.text = "\(student.webURL)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = Storage.studentLocations[indexPath.row]
        if let url = URL(string: selectedCell.webURL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }else{
                executeOnMain {
                    self.displayAlert(title: "Invalid URL", message: "Can not open the URL")
                }
            }
            }else{
                 executeOnMain {
        
                     self.displayAlert(title: "Invalid URL", message: "Can not open the URL")
                 }
            }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            Storage.studentLocations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            print(Storage.studentLocations)
        }
        
        return [delete]
        
    }
    
    ///////////////////
    
    func displayAlert(title:String, message:String?) {
        
        if let message = message {
            let alert = UIAlertController(title: title, message: "\(message)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}
    
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }
 





