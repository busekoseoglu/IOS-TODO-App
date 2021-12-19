//
//  ViewController.swift
//  ToDoApp
//
//  Created by Buse Köseoğlu on 16.12.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    
    var tasks = [String]()
    var idArray = [UUID]()
    var selectedRows = [IndexPath]()
    
    var selectedTask = ""
    var selectedTaskId : UUID?
    
    var todoStruct = Todo(isMarked: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(clickedAddBtn))
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Bu fonksiyon her viewcontroller açıldıında çağrılır
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    
    @objc func getData(){
        
        tasks.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            
            for result in results as! [NSManagedObject]{
                if let title = result.value(forKey: "title") as? String{
                    self.tasks.append(title)
                }
                if let id = result.value(forKey: "id") as? UUID{
                    self.idArray.append(id)
                }
                self.tableView.reloadData()
            }
        }catch{
            print("view contr error")
        }
        
    }
    
    @objc func clickedAddBtn(){
        selectedTask = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC"{
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.chosenTask = selectedTask
            destinationVC.chosenTaskId = selectedTaskId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTask = tasks[indexPath.row]
        selectedTaskId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskTableViewCell
        cell.taskLabel?.text = tasks[indexPath.row]
        
        
        if selectedRows.contains(indexPath){
            cell.checkMark.setImage(UIImage(named: "marked"), for: .normal)
            self.todoStruct.isMarked = true
        }
        else{
            cell.checkMark.setImage(UIImage(named: "unmarked"), for: .normal)
            self.todoStruct.isMarked = false
        }
        cell.checkMark.tag = indexPath.row
        cell.checkMark.addTarget(self, action: #selector(checkBoxSelection(_:)), for: .touchUpInside)
        return cell
    }
    
   
    @objc func checkBoxSelection(_ sender:UIButton)
      {
        let selectedIndexPath = IndexPath(row: sender.tag, section: 0)
        if self.selectedRows.contains(selectedIndexPath)
        {
          self.selectedRows.remove(at: self.selectedRows.firstIndex(of: selectedIndexPath)!)
        }
        else
        {
          self.selectedRows.append(selectedIndexPath)
        }
        self.tableView.reloadData()
      }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
            
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            do{
                let results = try context.fetch(fetchRequest) // results array dönüyo
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row]{
                                //core datadan silme
                                context.delete(result)
                                
                                // arrayden silme
                                tasks.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                }catch{
                                    print("error")
                                }
                            }
                        }
                    }
                }
            }
            catch{
                print("error")
            }
        }
    }
    
    


}

