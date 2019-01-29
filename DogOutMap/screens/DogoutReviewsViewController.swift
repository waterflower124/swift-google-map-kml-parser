//
//  DogoutReviewsViewController.swift
//  DogOutMap
//
//  Created by Water Flower on 2019/1/28.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit

class DogoutReviewsViewController: UIViewController {

    
    var address: String = ""
    var place_name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         self.performSegue(withIdentifier: "dogoutreviewtowritingreview_segue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "dogoutreviewtowritingreview_segue") {
            
            let WritingReviewVC = segue.destination as! WritingReviewViewController
            WritingReviewVC.address = self.address
            WritingReviewVC.place_name = self.place_name
//            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    

}
