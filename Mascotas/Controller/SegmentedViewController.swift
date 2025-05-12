//
//  SegmentedViewController.swift
//  Mascotas
//
//  Created by Edgar Vargas on 08/05/25.
//

import UIKit

class SegmentedViewController: UIViewController {

    @IBOutlet weak var perros: UIView!
    @IBOutlet weak var aves: UIView!
    @IBOutlet weak var tvAves: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func switchViews(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0{
            perros.isHidden = false
            aves.isHidden = true
            tvAves.isHidden = true
            
        }
        if sender.selectedSegmentIndex == 1{
            perros.isHidden = true
            aves.isHidden = false
            tvAves.isHidden = true
        }
        if sender.selectedSegmentIndex == 2{
            perros.isHidden = true
            aves.isHidden = true
            tvAves.isHidden = false
        }
    }
    


}
