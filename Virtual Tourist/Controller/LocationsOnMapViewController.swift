//
//  LocationsOnMapViewController.swift

//
//  Created by ابرار on ٢٧ جما١، ١٤٤٠ هـ.
//  Copyright © ١٤٤٠ هـ Udacity. All rights reserved.

import UIKit
import MapKit
import CoreData

class LocationsOnMapViewController: UIViewController , NSFetchedResultsControllerDelegate,  MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    var cdataController:CDataViewController!
    var annotations = [MKAnnotation]()
    var pinclecked: Pin!
    
    var fetchController:NSFetchedResultsController<Pin>!
    
    fileprivate func ConfigFetchedResultsController() {
        let Request:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        Request.sortDescriptors = [sort]
        
        fetchController = NSFetchedResultsController(fetchRequest: Request, managedObjectContext: cdataController.Context, sectionNameKeyPath: nil, cacheName: "PinData")
        fetchController.delegate = self
        do{
            try fetchController.performFetch()
        }catch{
            fatalError("have error in resbonse: \(error.localizedDescription)")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longvar = UILongPressGestureRecognizer(target: self, action:
            #selector(Tap(_:)))
        mapView.addGestureRecognizer(longvar)
        ConfigFetchedResultsController()
        shownPinsOnMap()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ConfigFetchedResultsController()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchController = nil
    }
    
    //toPhotoAlbum
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "toPhotos" ) {
            if let vc = segue.destination as? AlbumViewController {
                
                vc.dataController = cdataController
                vc.pin = pinclecked
                
            }
        }
        
        
    }
    
    
    func shownPinsOnMap(){
        
        if let Pin = fetchController.fetchedObjects?.first {
            zoomOnPin(lastPin: Pin)
            
        }
        
        
        for location in fetchController.fetchedObjects! {
            
            let latitude = location.latitude
            let longitude = location.longitude
            
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            
            self.annotations.append(annotation)
            
        }
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.annotations)
            
        }
        
    }
    
    
    func zoomOnPin(lastPin:Pin){
        
        
        //zooming to location
        let coredinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lastPin.coordinate.latitude, lastPin.coordinate.longitude)
        let map_span = MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)
        let location = MKCoordinateRegion(center: coredinate, span: map_span)
        self.mapView.setRegion(location, animated: true)
        
    }
    
    
    @objc func Tap(_ sender: UIGestureRecognizer){
        if sender.state == .ended {
            
            //Do Whatever You want on End of Gesture
            let touchLocation = sender.location(in: mapView)
            let coordinate = mapView.convert(touchLocation,
                                             toCoordinateFrom: mapView)
 
            addNewPin(latitude: coordinate.latitude, longitude: coordinate.longitude)

        }
        
    }
    
    
    func addNewPin(latitude: Double ,longitude: Double) {
        let newpin = Pin(context: cdataController.Context)
        
        newpin.latitude = latitude
        newpin.longitude = longitude
        newpin.creationDate = Date()
        
        do
        {
            try cdataController.Context.save()
        }
        catch
        {
            
            print(error)
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        
        guard let pin = anObject as? Pin else {
            preconditionFailure("All changes observed in the map view controller should be for Point instances")
        }
        
        
        switch type {
        case .insert:
            DispatchQueue.main.async {
                self.mapView.addAnnotation(pin)
            }
            
        case .delete:
            mapView.removeAnnotation(pin)
            
        case .update:
            mapView.removeAnnotation(pin)
            mapView.addAnnotation(pin)
            
        case .move: break
            
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let Id = "pin"
        
        var pinMap = mapView.dequeueReusableAnnotationView(withIdentifier: Id) as? MKPinAnnotationView
        
        if pinMap == nil {
            pinMap = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Id)
            pinMap!.pinTintColor = .red
        }
        else {
            pinMap!.annotation = annotation
        }
        
        
        return pinMap
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        let annotations = view.annotation
        let annotation_lat = annotations?.coordinate.latitude
        let annotation_long = annotations?.coordinate.longitude
        if let result = fetchController.fetchedObjects {
            for pin in result {
                if pin.latitude == annotation_lat && pin.longitude == annotation_long {
                    pinclecked = pin
                    performSegue(withIdentifier: "toPhotos", sender: self)
                    
                    break
                }
            }
            
            
            
            
        }
        
        
        
    }
}





extension Pin: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        
        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
        
    }
}




