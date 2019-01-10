//
//  TermsAndConditionsViewController.swift
//  DogOutMap
//
//  Created by Water Flower on 2019/1/10.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit

class TermsAndConditionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "termstosignup_segue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "termstosignup_segue") {
            var signupVC = segue.destination as! SignUpViewController
            signupVC.checkTerms = true
        }
    }

}
