//
//  SignUpViewController.swift
//  DogOutMap
//
//  Created by Water Flower on 2019/1/9.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var termsRectangleButton: UIButton!
    
    var checkTerms = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        termsRectangleButton.backgroundColor = UIColor.white
    }
    

    @IBAction func termsRectangleButtonAction(_ sender: Any) {
        checkTerms = !checkTerms
        if(checkTerms) {
            termsRectangleButton.backgroundColor = UIColor.black
        } else {
            termsRectangleButton.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func TermsAndConditionAction(_ sender: Any) {
    }
    
}
