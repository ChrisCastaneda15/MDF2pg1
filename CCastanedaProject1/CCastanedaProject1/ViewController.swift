//
//  ViewController.swift
//  CCastanedaProject1
//
//  Created by Chris Castaneda on 4/14/15.
//  Copyright (c) 2015 Chris Castaneda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var cardCollection: [UIView]!
    @IBOutlet weak var timerLabel: UILabel!
    
    
    var dictionary : [UIView : (fView: UIView, bView: UIView)] = [:];
    var images = ["military pistol", "military piercing ammo", "military knife", "military machine gun", "military chainsaw", "military helmet", "military strategy", "military truck", "misc first aid kit", "misc game missions", "weapons katana", "weapons medieval sword", "misc game coop", "misc game combat", "powerups super jump"];
    var usedImages = [String]();
    var mixArray = [String]();
    var usedCards = [UIView]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        for var i = 0; i < cardCollection.count/2; i++ {
            var n = Int(arc4random_uniform(UInt32(images.count)));
            var werd = images[n];
            usedImages.append(werd);
            usedImages.append(werd);
            images.removeAtIndex(n);
        };
        
        var count = usedImages.count
        
        for var i = 0; i < count; i++ {
            var num = Int(arc4random_uniform(UInt32(usedImages.count)));
            
            var img = usedImages[num];
            
            mixArray.append(img);
            
            usedImages.removeAtIndex(num);
        }
        
        println("THIS IS THE MIXED ARRAY:\n\(mixArray)");
        
        
    }
    
    @IBOutlet weak var startView: UIView!
    
    @IBAction func StartGame(sender: AnyObject) {

        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true);
        
        for i in cardCollection {
            i.hidden = false;
        }
        
        startView.hidden = true;
    }
    
    var seconds = 0;
    var minutes = 0;
    var timer = "";
    
    func update() {
        var ser = dispatch_queue_create("com.castaneda.timer", DISPATCH_QUEUE_SERIAL);
        
        dispatch_async(ser, { () -> Void in
            self.seconds++
            
            if self.seconds == 60 {
                self.minutes++;
                self.seconds = 0;
            }
            if self.seconds < 10 {
                self.timer = "\(self.minutes):0\(self.seconds)";
            }
            else {
                self.timer = "\(self.minutes):\(self.seconds)";
            }


           dispatch_sync(dispatch_get_main_queue(), { () -> Void in
               //self.timerLabel.text = self.timer;
            })
            
            println(self.timer);
        })
        
        
    }
    
    var runOnce = false;
    
    override func viewDidLayoutSubviews() {
        var count = 0;
        for i in cardCollection {
            var frontSquare = UIView(frame: CGRect(x: 0, y: 0, width: i.frame.width, height: i.frame.height))
            var blueSquare = UIView(frame: frontSquare.frame);
            var image = UIImageView(frame: blueSquare.frame);
            image.image = UIImage(named: mixArray[count]);
            frontSquare.backgroundColor = UIColor.blueColor();
            frontSquare.tag = 0;
            blueSquare.backgroundColor = UIColor.whiteColor();
            blueSquare.tag = 1;
            blueSquare.addSubview(image);
            
            var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "CardFlip:");
            frontSquare.addGestureRecognizer(tapGesture);
            tapGesture = UITapGestureRecognizer(target: self, action: "CardFlip:");
            blueSquare.addGestureRecognizer(tapGesture);
            
            count += 1;
            i.addSubview(blueSquare);
            i.addSubview(frontSquare);
            i.tag = count;
            
            
            dictionary.updateValue((frontSquare, blueSquare), forKey: i);
        }
        
    }
    
    
    
    
    
    func CardFlip (sender: UITapGestureRecognizer) {
    

        let s = sender.view?.superview;
        
        let v = dictionary[s!];
        var transition = UIViewAnimationOptions.TransitionCurlUp
        
        
        
        if sender.view?.tag == 1 {
            transition = UIViewAnimationOptions.TransitionCurlDown
        }
        else {
            transition = UIViewAnimationOptions.TransitionCurlUp
        }
        
        if self.usedCards.count < 2 {
            UIView.transitionWithView(s!, duration: 0.45, options: transition, animations: {
                        s!.bringSubviewToFront(v!.bView);
                        self.usedCards.append(s!);
                }, completion: nil);
        }
        if self.usedCards.count == 2 {
            var firstCard: UIImageView!
            for subView in self.usedCards[0].subviews as! [UIView] {
                for subsubView in subView.subviews {
                    if let imageView = subsubView as? UIImageView {
                        firstCard = imageView;
                        break;
                    }
                }
            }
            
               // var firstCard: UIImageView = self.usedCards[0].subviews[1].subviews[0] as! UIImageView;
                //var secondCard: UIImageView = self.usedCards[1].subviews[1].subviews[0] as! UIImageView;
            var secondCard: UIImageView!
            for subView in self.usedCards[1].subviews as! [UIView] {
                for subsubView in subView.subviews {
                    if let imageView = subsubView as? UIImageView {
                        secondCard = imageView;
                        break;
                    }
                }
            }
                
                if firstCard.image == secondCard.image {
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                        for i in self.usedCards {
                            i.hidden = true;
                            
                        }
                        self.usedCards.removeAll(keepCapacity: true);
                        self.checkWinner();
                    })
                    
                }
                else {
                    var firstCard: [UIView] = self.usedCards[0].subviews as! [UIView];
                    var secondCard: [UIView] = self.usedCards[1].subviews as! [UIView];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                        for i in self.usedCards {
                            UIView.transitionWithView(firstCard[0].superview!, duration: 0.45, options: UIViewAnimationOptions.TransitionCurlDown,
                                animations: {
                                    firstCard[0].superview!.bringSubviewToFront(firstCard[1])
                                }, completion: nil);
                            
                            UIView.transitionWithView(secondCard[0].superview!, duration: 0.45, options: UIViewAnimationOptions.TransitionCurlDown,
                                animations: {
                                    secondCard[0].superview!.bringSubviewToFront(secondCard[1])
                                }, completion: nil);
                        }
                        self.usedCards.removeAll(keepCapacity: true);
                        
                    })
    
                }
        }
       
    }
    
    func checkWinner (){
        var allCardsGone = [Bool]()
        
        for i in self.cardCollection {
            if i.hidden {
                allCardsGone.append(true);
            }
        }
        
        println(allCardsGone.count);
        if allCardsGone.count == self.cardCollection.count {
            println("WINNER");
            var winAlert = UIAlertController(title: "You WIN!!!", message: "Congratulations, you cleared the board in \(timer)!", preferredStyle: UIAlertControllerStyle.Alert);
            
            winAlert.addAction(UIAlertAction(title: "AWWWW YEAH!", style: UIAlertActionStyle.Default,handler: nil))
            
            
            self.presentViewController(winAlert, animated: true, completion: nil);
        }
        
        allCardsGone.removeAll(keepCapacity: true);
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

