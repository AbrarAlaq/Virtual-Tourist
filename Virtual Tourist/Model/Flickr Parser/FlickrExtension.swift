
import UIKit
import Foundation


extension FlickrUser {
    

    
    func getPhotosFormFlicker(latitude:Double ,longitude:Double, _ completionHandlerForFlickerPhoto: @escaping (_ success: Bool,_ photoData: [Any]?,_   :String?, _ errorString: String?) -> Void) {
        
        
        let bBox = self.bboxString(latitude: latitude, longitude: longitude)

        let parameters = [
            FlickrUser.ParameterKeys.Method           : FlickrUser.ParameterValues.SearchMethod
            , FlickrUser.ParameterKeys.APIKey         : FlickrUser.ParameterValues.APIKey
            , FlickrUser.ParameterKeys.Format         : FlickrUser.ParameterValues.ResponseFormat
            , FlickrUser.ParameterKeys.Extras         : FlickrUser.ParameterValues.MediumURL
            , FlickrUser.ParameterKeys.NoJSONCallback : FlickrUser.ParameterValues.DisableJSONCallback
            , FlickrUser.ParameterKeys.SafeSearch     : FlickrUser.ParameterValues.UseSafeSearch
            , FlickrUser.ParameterKeys.BoundingBox    : bBox
            , FlickrUser.ParameterKeys.PhotosPerPage  : FlickrUser.ParameterValues.PhotosPerPage
            ] as [String : Any]
        
        /* 2. Make the request */
        
        _ = taskForGETMethod( parameters: parameters as [String : AnyObject] , decode: Resbonse.self) { (result, error) in
            
            
            if let error = error {
                
                completionHandlerForFlickerPhoto(false ,nil ,nil,"\(error.localizedDescription)")
            }else {
                
             let newResult = result as! Resbonse
                
               let resultData = newResult.photos.photo
                
                if newResult.photos.photo.isEmpty {

                    let noPhotoMessage = "This pin has no images!"

                    completionHandlerForFlickerPhoto(true ,nil ,noPhotoMessage,nil)

                } else {
                    completionHandlerForFlickerPhoto(true ,resultData,nil,nil)

                }
                

                
                
            }
        }
        
    }
    
    
    
    
    
}


