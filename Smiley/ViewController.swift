//
//  ViewController.swift
//  Smiley
//
//  Created by Deeksha Prabhakar on 11/2/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var trayOriginalCenter: CGPoint!
    var trayCenterWhenOpen: CGPoint!
    var trayCenterWhenClose: CGPoint!
    
    var newlyCreatedFace: UIImageView!
    var smileyOriginalCenter: CGPoint!
    
    var smileyRotation:CGFloat!
    var smileyScale:CGFloat!
    
    
    @IBOutlet weak var trayView: UIView!
    
    @IBOutlet weak var downArrowImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trayCenterWhenOpen = CGPoint.init(x: trayView.center.x, y: view.frame.size.height - (trayView.frame.size.height/2))
        trayCenterWhenClose = CGPoint.init(x: trayView.center.x, y: view.frame.size.height + (trayView.frame.size.height/2) - 44)
        trayView.center = trayCenterWhenClose
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTrayPanGesture(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: view)
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        if sender.state == .began {
            print("began \(point)")
            trayOriginalCenter = trayView.center
        } else if sender.state == .changed {
            print("changed \(point)")
            //trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y)// + translation.y)
        } else if sender.state == .ended {
            print("ended \(point)")
            if (velocity.y > 0){//moving down
                UIView.animate(withDuration: 0.3, animations: {
                    self.trayView.center = self.trayCenterWhenClose
                    self.downArrowImageView.transform = CGAffineTransform.init(rotationAngle: 0)
                })
            }
            else{//moving up
                UIView.animate(withDuration: 0.3, animations: {
                    self.trayView.center = self.trayCenterWhenOpen
                    
                    self.downArrowImageView.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
                })
                
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func newFacePanned(sender: UIPanGestureRecognizer){
        let point = sender.location(in: view)
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        if sender.state == .began {
            print("began \(point)")
            smileyOriginalCenter = sender.view?.center
            
            
            
        } else if sender.state == .changed {
            print("changed \(point)")
            sender.view?.center = CGPoint(x: smileyOriginalCenter.x + translation.x, y: smileyOriginalCenter.y + translation.y)
            
        } else if sender.state == .ended {
            
        }
    }
    
    func newFacePinched(sender: UIPinchGestureRecognizer){
        var scale = sender.scale
        
        if sender.state == .began {
            print("began: \(scale)")
        } else if sender.state == .changed {
            print("changed: \(scale)")
            smileyScale = scale
            handlePinchNRotate()
            
        } else if sender.state == .ended {
            print("end: \(scale)")
        }
        
    }
    
    func newFaceRotated(sender: UIRotationGestureRecognizer){
        var rotation = sender.rotation
        
        if sender.state == .began {
            print("began: \(rotation)")
        } else if sender.state == .changed {
            print("changed: \(rotation)")
            smileyRotation = rotation
            handlePinchNRotate()
        } else if sender.state == .ended {
            print("end: \(rotation)")
        }
        
    }
    
    func handlePinchNRotate(){
        var transform = CGAffineTransform.identity
        if let smileyRotation = smileyRotation{
            transform = transform.rotated(by: smileyRotation)
        }
        if let smileyScale = smileyScale{
            transform = transform.scaledBy(x: smileyScale, y: smileyScale)
        }
        
        UIView.animate(withDuration: 0.1, animations: {
            self.newlyCreatedFace.transform = transform
            
        })
        
    }
    
    @IBAction func onSmileyImagePanGesture(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: view)
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        if sender.state == .began {
            print("Began \(point)")
            let imageView = sender.view as! UIImageView
            
            newlyCreatedFace = UIImageView(image: imageView.image)
            
            view.addSubview(newlyCreatedFace)
            
            newlyCreatedFace.center = imageView.center
            
            newlyCreatedFace.center.y += trayView.frame.origin.y
            
            smileyOriginalCenter = newlyCreatedFace.center
            newlyCreatedFace.isUserInteractionEnabled = true
            newlyCreatedFace.isMultipleTouchEnabled = true
            
            UIView.animate(withDuration: 0.1, animations: {
                self.newlyCreatedFace.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            })
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.newFacePanned))
            panGestureRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(panGestureRecognizer)
            
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.newFacePinched))
            pinchGestureRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(pinchGestureRecognizer)
            
            let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(ViewController.newFaceRotated))
            rotationGestureRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(rotationGestureRecognizer)
            
        } else if sender.state == .changed {
            print("Changed \(point)")
            newlyCreatedFace.center = CGPoint.init(x: smileyOriginalCenter.x + translation.x, y: smileyOriginalCenter.y + translation.y)
            
        } else if sender.state == .ended {
            print("Ended \(point)")
            UIView.animate(withDuration: 0.1, animations: {
                self.newlyCreatedFace.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
    }
    
    
}

