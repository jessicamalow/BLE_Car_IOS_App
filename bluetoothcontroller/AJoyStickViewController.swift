//
//  AJoyStickViewController.swift
//  bluetoothcontroller
//
//  Created by Jessica Malow and Nicole Malow on 4/8/21.
//

import UIKit

class AJoyStickViewController: UIViewController {
    //passer for data
    let vc = MainViewController()
    fileprivate let imageView = UIImageView(image: UIImage(named:"car"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       // Program the layout of the joystick
        view.addSubview((imageView))
        view.clipsToBounds = false
        view.layer.cornerRadius = 70
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
    
        
        //initiate gesture action
        imageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture)))
        imageView.isUserInteractionEnabled = true
        
    }
    
    //Implement joystick gesture movement
    @objc func handlePanGesture(gesture:UIPanGestureRecognizer) {
        let thresholdmagnitude = Float(84.5)
        if gesture.state == .began {
            print("began")
        } else if gesture.state == .changed {
            let translation = gesture.translation(in: self.view)
            //parse locations and set constraints
            print(NSCoder.string(for: translation))
            var digistring = NSCoder.string(for: translation)
            digistring.removeFirst()
            digistring.removeLast()
            var digits = digistring.split(separator: ",")
            digits[1].removeFirst()
            var theta = Double(atan((Float(digits[1])!)/(Float(digits[0])!)))
            let magnitude = Float(sqrt(pow((Float(digits[0])!), 2) + pow((Float(digits[1])!), 2)))
            if (magnitude > thresholdmagnitude) {
                if (Float(digits[0])!) < 0 && (Float(digits[1])!) >= 0 {
                    theta += Double.pi
                } else if (Float(digits[0])!) < 0 && (Float(digits[1])!) < 0 {
                    theta -= Double.pi
                } else if (Float(digits[0])!) == 0 && (Float(digits[1])!) > 0 {
                    theta = Double.pi/2
                } else if (Float(digits[0])!) == 0 && (Float(digits[1])!) < 0 {
                    theta = -Double.pi/2
                }
                let xposition = thresholdmagnitude * Float(cos(theta))
                let yposition = thresholdmagnitude * Float(sin(theta))
                
                imageView.transform = CGAffineTransform(translationX: CGFloat(xposition), y: CGFloat(yposition))
                NotificationCenter.default.post(name: MainViewController.notificationName, object: nil, userInfo: ["position" : String(Int(xposition))+"," + String(Int(yposition))])
                
            } else {
            //transform
            imageView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
                NotificationCenter.default.post(name: MainViewController.notificationName, object: nil, userInfo: ["position" : String(Int(translation.x)) + "," + String(Int(translation.y))])
            }
            
            print("changed")
            
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: { self.imageView.transform = .identity})
            NotificationCenter.default.post(name: MainViewController.notificationName, object: nil, userInfo: ["position" : String(Int(0)) + "," + String(Int(0))])
            print("ended")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}

