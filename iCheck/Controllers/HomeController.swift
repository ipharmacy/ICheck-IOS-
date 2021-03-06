//
//  HomeController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 20/11/2020.
//

import UIKit
import CoreData



class HomeController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var Search: UISearchBar!
    
    @IBOutlet weak var Category1: UIImageView!
    @IBOutlet weak var categoryName1: UILabel!
    @IBOutlet weak var filterCategory1: UIImageView!
    
    @IBOutlet weak var Category2: UIImageView!
    @IBOutlet weak var filterCategory2: UIImageView!
    @IBOutlet weak var categoryName2: UILabel!
    
    @IBOutlet weak var Category3: UIImageView!
    @IBOutlet weak var filterCategory3: UIImageView!
    @IBOutlet weak var categoryName3: UILabel!
   
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    
    var connectedUser:Customer = Customer(_id: "notyet", firstName: "", lastName: "", email: "", password: "", phone: "", sexe: "", avatar: "", favorites: [])
    
    var customers = [Friendship]()
    var products = [Product]()
    var categories = [Category]()

    @IBOutlet weak var trendingProducts: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "trendingCell")
        
        return cv
    }()
    
    @IBOutlet weak var Friends: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "friendCell")
        
        return cv
    }()
    
 
    
    @IBAction func seeAllProduct(_ sender: UIButton) {
        performSegue(withIdentifier: "toPostsSegue", sender: sender)
    }
    
    
    @IBAction func seeAllCategories(_ sender: UIButton) {
        
    }
    
    
    @IBAction func seeAllFriends(_ sender: UIButton) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Search.endEditing(true)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Search.endEditing(true)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar==Search {
            self.tabBarController?.selectedIndex = 2
        }
        
        //self.present(UINavigationController(rootViewController: SearchViewController()), animated: false, completion: nil)
        
    }
    
    func getCategories() -> Void {
        let productsUrl = URL(string: baseURL+"api/categories/")
        URLSession.shared.dataTask(with: productsUrl!) { (data,response,error) in
            if error == nil{
                do {
                    self.categories = try JSONDecoder().decode([Category].self, from: data!)
                } catch {
                    print("parse category error")
                }
                
                DispatchQueue.main.async {
                    print(self.categories)
                    let category1Url = self.baseURL + "uploads/categories/" + self.categories[0].image
                    let category2Url = self.baseURL + "uploads/categories/" + self.categories[1].image
                    let category3Url = self.baseURL + "uploads/categories/" + self.categories[2].image
                    
                    self.filterCategory1.alpha = 1
                    self.Category1.sd_setImage(with: URL(string: category1Url), placeholderImage: UIImage(named: "Rectangle 393"), options: [.continueInBackground, .progressiveLoad])
                    self.categoryName1.text = self.categories[0].name
                    
                    self.filterCategory2.alpha = 1
                    self.Category2.sd_setImage(with: URL(string: category2Url), placeholderImage: UIImage(named: "Rectangle 393"), options: [.continueInBackground, .progressiveLoad])
                    self.categoryName2.text = self.categories[1].name
                    
                    
                    self.filterCategory3.alpha = 1
                    self.Category3.sd_setImage(with: URL(string: category3Url), placeholderImage: UIImage(named: "Rectangle 393"), options: [.continueInBackground, .progressiveLoad])
                    self.categoryName3.text = self.categories[2].name
                }
            }
        }.resume()
    }
    
    func getConnectedUser() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Connected")
        do {
            let result = try managedContext.fetch(fetchRequest)
            for obj in result {
                self.connectedUser._id=(obj.value(forKey: "id") as! String)
                self.connectedUser.firstName=(obj.value(forKey: "firstName") as! String)
                self.connectedUser.lastName=(obj.value(forKey: "lastName") as! String)
                self.connectedUser.email=(obj.value(forKey: "email") as! String)
                self.connectedUser.password=(obj.value(forKey: "password") as! String)
                self.connectedUser.phone=(obj.value(forKey: "phone") as! String)
                self.connectedUser.sexe=(obj.value(forKey: "sexe") as! String)
                self.connectedUser.avatar=(obj.value(forKey: "avatar") as! String)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        getConnectedUser()
        
        Search.delegate = self
        trendingProducts.delegate = self
        trendingProducts.dataSource = self

        Friends.delegate = self
        Friends.dataSource = self
        
        getCategories()
        /*Search.layer.masksToBounds = true
        Search.layer.borderWidth = 1
        Search.layer.borderColor = UIColor(red: 55/255, green: 59/255, blue: 100/255, alpha: 1).cgColor
        Search.layer.cornerRadius = 5*/
        
        
        
        let productsUrl = URL(string: baseURL+"api/products/trending")
        URLSession.shared.dataTask(with: productsUrl!) { (data,response,error) in
            if error == nil{

                do {
                    self.products = try JSONDecoder().decode([Product].self, from: data!)
                } catch {
                    print("parse product json error")
                }
                
                DispatchQueue.main.async {
                    self.trendingProducts.performBatchUpdates(
                      {
                        self.trendingProducts.reloadSections(NSIndexSet(index: 0) as IndexSet)
                      }, completion: { (finished:Bool) -> Void in
                    })
                }
            }
        }.resume()
        
        

        let parameters = ["userId" : connectedUser._id]
        guard let url = URL(string: baseURL+"api/user/getFriendship") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil{
                do {
                    self.customers = try JSONDecoder().decode([Friendship].self, from: data!)
                } catch {
                    print("parse backend error")
                }
        
                DispatchQueue.main.async {
                    self.Friends.performBatchUpdates(
                      {
                        self.Friends.reloadSections(NSIndexSet(index: 0) as IndexSet)
                      }, completion: { (finished:Bool) -> Void in
                    })
                }
            }
        }.resume()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var newList:[Friendship]=[]
        
        let parameters = ["userId" : connectedUser._id]
        guard let url = URL(string: baseURL+"api/user/getFriendship") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil{
                do {
                    newList = try JSONDecoder().decode([Friendship].self, from: data!)
                } catch {
                    print("parse backend error")
                }
        
                DispatchQueue.main.async {
                    if(newList.count==self.customers.count){
                        var changed=false
                        for i in 0..<newList.count {
                            if !(newList[i]._id==self.customers[i]._id) {
                                changed=true
                            }
                        }
                        if changed {
                            self.customers=newList
                            self.Friends.performBatchUpdates(
                              {
                                self.Friends.reloadSections(NSIndexSet(index: 0) as IndexSet)
                              }, completion: { (finished:Bool) -> Void in
                            })
                        }
                    }else{
                        self.customers=newList
                        self.Friends.performBatchUpdates(
                          {
                            self.Friends.reloadSections(NSIndexSet(index: 0) as IndexSet)
                          }, completion: { (finished:Bool) -> Void in
                        })
                    }
                }
            }
        }.resume()
    }

    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer =     UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}











extension HomeController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
            if collectionView == trendingProducts {
                if products[indexPath.row].ARModelId == -1 {
                    return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
                        

                        let rename = UIAction(title: "Details", image: UIImage(systemName: "arrowshape.turn.up.right")) { action in
                            self.performSegue(withIdentifier: "prodDetailSegue", sender: indexPath.row)
                        }

                        let delete = UIAction(title: "Reviews", image: UIImage(systemName: "star")) { action in
                            self.performSegue(withIdentifier: "homeToReviewsSegue", sender: indexPath.row)
                        }

                        return UIMenu(title: "", children: [rename, delete])
                    }
                }else{
                    return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
                        
                        let share = UIAction(title: "Check it", image: UIImage(systemName: "sparkles")) { action in
                            self.performSegue(withIdentifier: "homeToAR", sender: indexPath.row)
                        }

                        let rename = UIAction(title: "Details", image: UIImage(systemName: "arrowshape.turn.up.right")) { action in
                            self.performSegue(withIdentifier: "prodDetailSegue", sender: indexPath.row)
                        }

                        let delete = UIAction(title: "Reviews", image: UIImage(systemName: "star")) { action in
                            self.performSegue(withIdentifier: "homeToReviewsSegue", sender: indexPath.row)
                        }

                        return UIMenu(title: "", children: [share, rename, delete])
                    }
                }

            }else{
                return nil
            }
        }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView==Friends){
            
            return CGSize(width: 55, height:55)
        }
        return CGSize(width: 310, height:237)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView==Friends) {
            return customers.count
        }
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView==Friends) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendCell", for: indexPath)
            let contentView = cell.contentView
            
            contentView.layer.cornerRadius = cell.bounds.width/2
            let borderView = contentView.viewWithTag(2) as! UIView
            borderView.layer.cornerRadius = borderView.bounds.width/2
            let imageView = contentView.viewWithTag(1) as! UIImageView
            imageView.layer.cornerRadius = imageView.bounds.width/2

            
            let avatarUrl = baseURL + "uploads/users/" + customers[indexPath.row].user.avatar
            //imageView.sd_setImage(with: URL(string: avatarUrl) )
            imageView.sd_setImage(with: URL(string: avatarUrl), placeholderImage: UIImage(named: "youssef.marzouk"), options: [.continueInBackground, .progressiveLoad])
            
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingCell", for: indexPath)
        
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 0.4
        cell.layer.borderColor = UIColor(red: 55/255, green: 59/255, blue: 100/255, alpha: 1).cgColor
        
        let contentView = cell.contentView
        let backgroundImage = contentView.viewWithTag(1) as! UIImageView
        let BrandLogo = contentView.viewWithTag(2) as! UIImageView
        let name = contentView.viewWithTag(3) as! UILabel
        let description = contentView.viewWithTag(4) as! UILabel
        let arLogo = contentView.viewWithTag(5) as! UIImageView
       
        let imgUrl = baseURL + "uploads/products/" + products[indexPath.row].image[0]
        
        
        backgroundImage.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])
        backgroundImage.contentMode = .scaleAspectFill
        
        BrandLogo.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "nikeair"), options: [.continueInBackground, .progressiveLoad])
        
        
        BrandLogo.contentMode = .scaleAspectFill
        name.text = products[indexPath.row].name
        description.text = products[indexPath.row].description
        if products[indexPath.row].ARModelId == -1 {
            arLogo.alpha=0
        }else{
            arLogo.alpha=1
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier=="prodDetailSegue" {
            let indexPath = sender as! Int
            let product = products[indexPath]
            let destination = segue.destination as! ProductDetailsController
            
            destination.Prod = product
        }
        if segue.identifier=="homeToAR" {
            let indexPath = sender as! Int
            let product = products[indexPath]
            let destination = segue.destination as! ARController
            
            destination.Prod = product
        }
        if segue.identifier=="homeToReviewsSegue" {
            let indexPath = sender as! Int
            let product = products[indexPath]
            let destination = segue.destination as! ProductReviewsController
            
            destination.Prod = product
        }
        if segue.identifier=="chatBotSegue" {
            let index = sender as! Int
            let friend = customers[index].user
            let destination  = segue.destination as! ChatBotController
            
            destination.friend = friend
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView==trendingProducts {
            performSegue(withIdentifier: "prodDetailSegue", sender: indexPath.row)
        }
        if collectionView==Friends {
            performSegue(withIdentifier: "chatBotSegue", sender: indexPath.row)
        }
    }
}

