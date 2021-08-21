//
//
//  AlbumViewController.swift

//
//  Created by ابرار on ٢٧ جما١، ١٤٤٠ هـ.
//  Copyright © ١٤٤٠ هـ Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class AlbumViewController: UIViewController ,  UICollectionViewDataSource,  UICollectionViewDelegate ,NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noImageLable: UILabel!
    
    var pin: Pin!
    
    var Urlimage = [URL]()
    var Photos = [IndexPath]()
    
    
    private var blockOperations: [BlockOperation] = []
    
    var dataController:CDataViewController!
    
    var fetchController:NSFetchedResultsController<ImageOb>!
    
    fileprivate func configFetchedResultsController() {
        let Request:NSFetchRequest<ImageOb> = ImageOb.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", self.pin)
        Request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        Request.sortDescriptors = [sortDescriptor]
        fetchController = NSFetchedResultsController(fetchRequest: Request, managedObjectContext: dataController.Context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchController.delegate = self
        
        do {
            try fetchController.performFetch()
            
        } catch {
            fatalError("have error in resbonse: \(error.localizedDescription)")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchController = nil
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newCollectionButton.isEnabled = false
        
       configFetchedResultsController()

        //If it's 0 that mean there're no images downloaded yet !
        if self.fetchController.fetchedObjects?.count == 0 {
            PhotosFlikr()
        }
        
        createAnnotation()
        Flow_Layout()
 
        collectionView.allowsMultipleSelection = true
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configFetchedResultsController()
        
        
    }
    func PhotosFlikr(){
        FlickrUser.sharedInstance().getPhotosFormFlicker(latitude: pin.latitude, longitude: pin.longitude, { (success, photoData,NoPhotoMessage, errorString)  in
            
            if success {
                
                if NoPhotoMessage == nil {
                    
                    DispatchQueue.main.async {
                        self.noImageLable.isHidden = true
                    }
                    
                    if let photo = photoData as? [FParse] {
                        
                        for i in photo {
                            self.Urlimage.append(URL(string: i.url_m)!)
                            
                        }
                        
                        self.downloadPhoto()
                        
        
                    }
                }else {
                    DispatchQueue.main.async {
                        self.noImageLable.isHidden = false
                        self.noImageLable.text = NoPhotoMessage
                    }
                }
                
                
                
            }
        })
    }
    
    func Flow_Layout(){
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    
    @IBAction func newCollectionTapped(_ sender: UIButton) {
        
        if sender.currentTitle == "New Collection" {
          
            guard let fetchedResults = self.fetchController.fetchedObjects else {
                return
            }
            
            Urlimage.removeAll()
            
            for i in fetchedResults {
                dataController.Context.delete(i)
                try? dataController.Context.save()
            }
            
            PhotosFlikr()
            
        } else if sender.currentTitle == "Remove Selected Pictures" {
            
            sender.setTitle("New Collection", for: .normal)
            
            deletePhotos()
            
            
        }
        
    }

    
    func createAnnotation(){
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        self.mapView.addAnnotation(annotation)
        
        
        //zooming to location
        let coredinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        let sp = MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)
        let location = MKCoordinateRegion(center: coredinate, span: sp)
        self.mapView.setRegion(location, animated: true)
        
    }
    
    func updateVc(cell:PhotoinlocationCell, status:Bool) {
        
        if status == false {
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            
        } else {
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
            
            
        }
    }
    
    func downloadPhoto(){
        
        if ((fetchController.fetchedObjects?.isEmpty)!) {
            
            for url in Urlimage {
                
                let dataTask = URLSession.shared.dataTask(with: url) {
                    data, response, error in
                    
                    if error == nil {
                        if let data = data {
                            
                            self.addimages(data:data)
                            
                            
                            
                        }
                        
                    }else {
                        print(error!)
                    }
                    
                }
                dataTask.resume()
                
            }
            
            
            
            
        }
        
    }
    
    func addimages(data:Data) {
        let image = ImageOb(context: dataController.Context)
        
       image.imageData = data
        image.creationDate = Date()
        image.pin = pin
        
        do
        {
            try dataController.Context.save()
        }
        catch
        {
            //ERROR
            print(error)
        }
 
    }
    
    func deletePhotos() {
        
        var photosisdeleted: [ImageOb] = [ImageOb]()
        
        for i in Photos {
            photosisdeleted.append(fetchController.object(at: i))
        }
        
        for i in photosisdeleted {
            dataController.Context.delete(i)
            try? dataController.Context.save()
        }
        
        Photos.removeAll()

    }

    
    deinit {
        // Cancel all block operations when VC deallocates
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        if let sectionInfo = self.fetchController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCell", for: indexPath) as! PhotoinlocationCell
        
        cell.selectedView.isHidden = true
        
        self.updateVc(cell: cell, status: false)
        
        
        
        let arrayData = self.fetchController.fetchedObjects!
        cell.imageFlikr.image =  UIImage(data: arrayData[indexPath.row].imageData!)
        
        
        self.updateVc(cell: cell, status: true)
        
        newCollectionButton.isEnabled = true
        
        
        
        
        
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoinlocationCell
        
        cell.selectedView.isHidden = false
        newCollectionButton.setTitle("Remove Selected Pictures", for: .normal)
        
        Photos.append(indexPath)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoinlocationCell
        
        cell.selectedView.isHidden = true
        
        Photos.remove(at: indexPath.startIndex)
        
        if Photos.count == 0 {
            newCollectionButton.setTitle("New Collection", for: .normal)
        }
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        let op: BlockOperation
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            op = BlockOperation { self.collectionView.insertItems(at: [newIndexPath]) }
            
        case .delete:
            guard let indexPath = indexPath else { return }
            op = BlockOperation { self.collectionView.deleteItems(at: [indexPath]) }
        case .move:
            guard let indexPath = indexPath,  let newIndexPath = newIndexPath else { return }
            op = BlockOperation { self.collectionView.moveItem(at: indexPath, to: newIndexPath) }
        case .update:
            guard let indexPath = indexPath else { return }
            op = BlockOperation { self.collectionView.reloadItems(at: [indexPath]) }
        }
        
        blockOperations.append(op)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            self.blockOperations.forEach { $0.start() }
        }, completion: { finished in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
    
}












