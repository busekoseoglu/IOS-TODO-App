//
//  DetailsViewController.swift
//  ToDoApp
//
//  Created by Buse Köseoğlu on 16.12.2021.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController {

    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var taskDetail: UITextView!
    @IBOutlet weak var saveBarBtn: UIBarButtonItem!
    
    var chosenTaskId : UUID?
    var chosenTask = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleText.layer.borderWidth = 0.3
        
        taskDetail.text = ""
        taskDetail.layer.borderWidth = 0.3
        taskDetail.layer.cornerRadius = 5.0
        
        if chosenTask != ""{
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")

            let idString = chosenTaskId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let title = result.value(forKey: "title") as? String{
                            titleText.text = title
                        }
                        if let details = result.value(forKey: "details") as? String{
                            taskDetail.text = details
                        }
                    }
                }
            }catch{
                print("error 2")
            }
        }
    }
    
   
    @IBAction func saveBarBtnClicked(_ sender: Any) {
        
        if titleText.text != "" && taskDetail.text != ""{
            
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            
            let newTask = NSEntityDescription.insertNewObject(forEntityName: "Tasks", into: context)
            
            newTask.setValue(UUID(), forKey: "id")
            newTask.setValue(titleText.text, forKey: "title")
            newTask.setValue(taskDetail.text, forKey: "details")
            
            do{
                try context.save()
                print("success")
            }catch{
                print("error")
            }
            
            // bütün appin içinde new data diye bir mesaj yollar ve yeni data geldiğini söyler
            NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
            // bir önceki viewcontrollera geri gider
            self.navigationController?.popViewController(animated: true)
            
        }
        
    }
    
    
    

}
