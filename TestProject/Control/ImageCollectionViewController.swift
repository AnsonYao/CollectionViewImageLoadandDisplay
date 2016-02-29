//
//  ViewController.swift
//  TestProject
//
//  Created by Anson on 2015-12-09.
//  Copyright © 2015 SparrowMobile. All rights reserved.
//

import UIKit
import CoreData

let Collection_Cell_Reuse_Identifier = "collection_cell_reuse_identifier"
let Preload_Limit = 15
let Cache_Expire_Time_Interval = 60 * 60 * 24.0 // in seconds
let Scale_Factor = 0.4

class ImageCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate{
    
    //Data for cells
    var photos = [Photo]()
    // Lower bound for the data loaded or loading
    var lb = 0
    //upper bound
    var ub = 0
    
    var indexsNeedtoBeUpdated = [NSIndexPath]()
    var lastObservedIndex = NSIndexPath(forItem: 0, inSection: 0)
    var isScrolling = false
    
    @IBOutlet weak var reorderButton: UIButton!
    
    @IBAction func reorderAction(sender: UIButton) {
        photos = ReOrder.random(self.photos, lb: 0, ub: self.photos.count-1)
        if let index = self.getCurrentIndex(){
            dynamicLoadImages(center: index, radius: Preload_Limit)
        }
        else{
            dynamicLoadImages(center: lastObservedIndex, radius: Preload_Limit)
        }
        collectionView.reloadData()
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "CollectionCell", bundle: nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: Collection_Cell_Reuse_Identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        photos.removeAll()
        NetworkManager.getPhotosinBackground(url: Constants.jsonPlaceHolderPhotosURL) {[weak self] (photos) -> Void in
            if let this = self{
                this.photos = photos
                this.collectionView.reloadData()
                this.dynamicLoadImages(center: NSIndexPath(forItem: 0, inSection: 0), radius: Preload_Limit)
                this.reorderButton.enabled = true
                this.reorderButton.alpha = 1.0
            }
        }
        
        reorderButton.enabled = false
        reorderButton.alpha = 0.5
    }
    // Do any additional setup after loading the view, typically from a nib.
    
    override func viewWillDisappear(animated: Bool) {
        do{
            try ContextManager.getMainContext().save()
        }
        catch{
            NSLog("data storage failed")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        if let index = getCurrentIndex(){
            clearMemeory(index, reserve: Preload_Limit)
        }
        else{
            clearMemeory(NSIndexPath(forItem: 0, inSection: 0), reserve: Preload_Limit)
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(ub, photos.count)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(Collection_Cell_Reuse_Identifier, forIndexPath: indexPath) as? CollectionViewCell
        if cell == nil{
            cell = NSBundle.mainBundle().loadNibNamed("CollectionCell", owner: self, options: nil)[0] as? CollectionViewCell
        }
        let photo = photos[indexPath.row]
        if let record = photo.imageRecord{
            if let image = record.image{
                cell!.updateImage(image)
            }
            else{
                cell!.updateImage(UIImage())
            }
        }
        else{
            cell!.updateImage(UIImage())
        }
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: photos[indexPath.row].size.width * CGFloat(Scale_Factor), height: collectionView.bounds.height)
    }
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        isScrolling = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        isScrolling = true
    }
    
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        if let path = getCurrentIndex(){
            if (path.row + Preload_Limit > ub) || (max(0, path.row - Preload_Limit) < lb){
                dynamicLoadImages(center: path, radius: Preload_Limit)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        CoreDataManager.mergeAndSaveContext()
        isScrolling = false
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let path = getCurrentIndex(){
            if (path.row + Preload_Limit > ub) || (max(0, path.row - Preload_Limit) < lb){
                dynamicLoadImages(center: path, radius: Preload_Limit)
            }
        }
        CoreDataManager.mergeAndSaveContext()
        isScrolling = false
    }
    
    
    func getCurrentIndex() -> NSIndexPath?{
        let offset = self.collectionView.contentOffset
        let size = self.collectionView.bounds.size
        let pt = CGPoint(x: Int(offset.x + size.width/2), y: Int(offset.y + size.height/2))
        if let result = self.collectionView.indexPathForItemAtPoint(pt){
            lastObservedIndex = result
        }
        return self.collectionView.indexPathForItemAtPoint(pt)
    }
    
    func dynamicLoadImages(center center: NSIndexPath, radius: Int){
        NSLog("dynamic load with center #\(center.row) start")
        ub = max(ub, center.row + radius)
        lb = max(0, min(lb, center.row - radius))
        //Load images of nearby cells. maximum \(radius) cells on left and maximum \(radius) cells on right
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){[weak self] in
            if let this = self{
                for i in 0...radius{
                    if this.isImageNeedstoBeLoad(atIndex: center.row + i){
                        NSLog("#\(center.row + i + 1) image start")
                        this.loadImageinBackground(atIndex: NSIndexPath(forItem: center.row+i, inSection: center.section), onComplete: this.markCellToBeUpdated)
                    }
                    if this.isImageNeedstoBeLoad(atIndex: center.row - i){
                        NSLog("#\(center.row - i + 1) image start")
                        this.loadImageinBackground(atIndex: NSIndexPath(forItem: center.row-i, inSection: center.section), onComplete: this.markCellToBeUpdated)
                    }
                }
            }
        }
        
        //        clearMemeory(center, reserve: radius)
    }
    
    //tries to load an image at an index
    func loadImageinBackground(atIndex index: NSIndexPath, onComplete handler: (NSIndexPath)->Void){
        let photo = photos[index.row]
        photo.isImageLoading = true
        ImageRecordMO.queryInBackground(url: photo.url) {(imageRecord, error) -> Void in
            if let record = imageRecord{
                    NSLog("#\(photo.id) Image Loaded from coredata")
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){
                    record.image = UIImage(data: record.data)?.convertImageAsRequired(photo.title)
                    photo.imageRecord = record
                    dispatch_async(dispatch_get_main_queue()){
                        handler(index)
                        if let record = photo.imageRecord{
                            if let image = record.image{
                                photo.size = image.size
                                photo.isImageLoading = false
                            }
                        }
                    }
                }
            }
            else{
                if let error = error{
                    NSLog(error.description)
                }
                NetworkManager.getImageRecordinBackground(url: photo.url) { (imageRecord) -> Void in
                    CoreDataManager.saveImageRecordInBackground(imageRecord)
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){
                        imageRecord.image = UIImage(data: imageRecord.data)?.convertImageAsRequired(photo.title)
                        photo.imageRecord = imageRecord
                        NSLog("#\(photo.id) Image Loaded from network")
                        dispatch_async(dispatch_get_main_queue()){
                            handler(index)
                            if let record = photo.imageRecord{
                                if let image = record.image{
                                    photo.size = image.size
                                    photo.isImageLoading = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    //update cell at index
    func markCellToBeUpdated(atIndex index: NSIndexPath){
        indexsNeedtoBeUpdated.append(index)
        if !isScrolling{
            updateCells()
        }
    }
    
    
    func updateCells(){
        UIView.setAnimationsEnabled(false)
        collectionView.performBatchUpdates({ [weak self]() -> Void in
            if let this = self{
                this.collectionView.reloadItemsAtIndexPaths(this.indexsNeedtoBeUpdated)
                this.indexsNeedtoBeUpdated.removeAll()
                this.collectionView.collectionViewLayout.invalidateLayout()
            }
        }, completion: { (_) -> Void in
                UIView.setAnimationsEnabled(true)
        })
    }
    
    func isImageNeedstoBeLoad(atIndex index: Int) -> Bool{
        return isValid(index: index) && !isImageLoaded(atIndex: index) && !isImageLoading(atIndex: index)
    }
    
    
    func isImageLoaded(atIndex index: Int) -> Bool{
        assert(isValid(index: index))
        return  photos[index].imageRecord != nil
    }
    
    func isImageLoading(atIndex index: Int) ->Bool{
        assert(isValid(index: index))
        return  photos[index].isImageLoading
    }
    
    func isValid(index index: Int) -> Bool{
        return index >= 0 && index < photos.count
    }
    
    func clearMemeory(center: NSIndexPath, reserve: Int){
        for i in 0...max(0, center.row - reserve - 1){
            if isValid(index: i){
                photos[i].clearMemory()
            }
        }
        
        for i in min(center.row + reserve + 1, photos.count-1)...(photos.count-1){
            if isValid(index: i){
                photos[i].clearMemory()
            }
        }
        lb = center.row - reserve - 1
        ub = center.row + reserve - 1
    }
    
}

