//
//  GallerySelectorTableViewController.swift
//  ImageGallery
//
//  Created by sam hastings on 17/10/2023.
//

import UIKit

class GallerySelectorTableViewController: UITableViewController, ImageGalleryViewControllerDelegate {
    
    /// List of image galleries used to popualte the cells in the first section of the tableView
    ///  Initialised with an empty image gallery as it only element.
    // TODO: consider making this optional, and then in the ImageGalleryVC making the gallery inherti from this propertu or else take an empty gallery.
    var galleryList = GalleryList(galleries: [ImageGallery(images: [], name: "New Gallery")])
    
    var recentlyDeleted = GalleryList()
    
    @IBAction func newGallery(_ sender: UIBarButtonItem) {
        let newGallery = ImageGallery(images: [], name: "New Gallery".madeUnique(withRespectTo: galleryList.galleries.map { $0.name } + recentlyDeleted.galleries.map { $0.name }) )
        galleryList.galleries += [newGallery]
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .secondaryOnly {
            splitViewController?.preferredDisplayMode = .secondaryOnly
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performSegue(withIdentifier: "selectionSegue", sender: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // TODO: change to 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return galleryList.galleries.count
        } else {
            return recentlyDeleted.galleries.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Recently deleted"
        } else {
            return ""
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // TODO: use modern cell configuration approach
        let section = indexPath.section
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GalleryCell", for: indexPath)
            if let cell = cell as? ImageGalleryTableViewCell {
                let tempName = galleryList.galleries[indexPath.row].name
                cell.galleryTitle.text = galleryList.galleries[indexPath.row].name
                cell.resignationHandler = {
                    if let text = cell.galleryTitle.text, let galleryIndex = self.galleryList.galleries.firstIndex(where: {$0.name == tempName}) {
                        self.galleryList.galleries[galleryIndex].name = text
                    }
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeletedCell", for: indexPath)
            cell.textLabel?.text = recentlyDeleted.galleries[indexPath.row].name
            return cell
        }
        

        
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let section = indexPath.section
            if section == 0 {
                tableView.performBatchUpdates {
                    let deletedGallery = galleryList.galleries.remove(at: indexPath.row)
                    recentlyDeleted.galleries.append(deletedGallery)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.insertRows(at: [IndexPath(row: recentlyDeleted.galleries.count - 1, section: 1)], with: .fade)
                }
            } else if section == 1 {
                recentlyDeleted.galleries.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let section = indexPath.section
        if section == 1 {
            let swipeAction = UIContextualAction(style: .destructive, title: "Restore") { action, sourceView, completionHandler in
                tableView.performBatchUpdates {
                    let deletedGallery = self.recentlyDeleted.galleries.remove(at: indexPath.row)
                    self.galleryList.galleries.append(deletedGallery)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.insertRows(at: [IndexPath(row: self.galleryList.galleries.count - 1, section: 0)], with: .fade)
                }
                completionHandler(true)
            }
            let swipeActionConfiguration = UISwipeActionsConfiguration(actions: [swipeAction])
            return swipeActionConfiguration
        } else {
            return nil
        }
    }

    // MARK: - Navigation
    
    func imageGalleryViewController(didUpdateGallery gallery: ImageGallery) {
        if let index = galleryList.galleries.firstIndex(where:  {$0.name == gallery.name} ) {
            galleryList.galleries[index] = gallery
        }
        tableView.reloadData()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "selectionSegue" {
                let navVC = segue.destination as? UINavigationController
                let destinationVC = navVC?.viewControllers[0] as? ImageGalleryViewController
                destinationVC?.delegate = self
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                    destinationVC?.imageGallery = galleryList.galleries[indexPath.row]
                } else {
                    destinationVC?.imageGallery = galleryList.galleries[0]
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        if selectedCell?.reuseIdentifier == "GalleryCell" {
            performSegue(withIdentifier: "selectionSegue", sender: selectedCell)
        }
    }
}
