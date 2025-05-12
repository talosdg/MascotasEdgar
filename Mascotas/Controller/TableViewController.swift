//
//  TableViewController.swift
//  Mascotas
//
//  Created by Ángel González on 26/04/25.
//

import UIKit

class TableViewController: UITableViewController {
    
    var numElegido: Int = 0
    
    var mascotas = [Mascota]()
    
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        actualizar(numMasc: numElegido)
        NotificationCenter.default.addObserver(self, selector:#selector(actualizar), name: NSNotification.Name("DELETED_OBJECT"), object:nil)
    }
    
    @objc
    func actualizar(numMasc: Int) {
        // TODO: - Obtener todas las mascotas filtradas
        
        if numMasc == 0{
      
            mascotas = DataManager.shared.todasLasMascotas(num: 0, tipo: "perro")
        }
        if numMasc == 1{
           
            mascotas = DataManager.shared.todasLasMascotas(num: 1, tipo: "gato")
        }
        if numMasc == 2{
            
            mascotas = DataManager.shared.todasLasMascotas(num: 2, tipo: "perico", fil1: "canario")
        }
        if numMasc == 3{
            
            mascotas = DataManager.shared.todasLasMascotas(num: 3, tipo: "serpiente", fil1: "hurón", fil2: "tortuga", fil3: "conejo", fil4: "pez")
        }
        tableView.reloadData()
        
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mascotas.count
    }
    
    // TODO: - Implementar la presentación del nombre de la mascota
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"reuseCell", for:indexPath)
        let m = mascotas[indexPath.row]
        cell.textLabel?.text = m.nombre ?? "una mascota"
        return cell
    }

    // TODO: - Implementar que despliegue la información de la mascota en DetailView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let m = mascotas[indexPath.row]
        let dv = DetailViewController()
        dv.laMascota = m
        dv.modalPresentationStyle = .automatic
        self.present(dv, animated:true)
    }

    @IBAction func switchPets(_ sender: UISegmentedControl) {

        actualizar(numMasc: sender.selectedSegmentIndex)
  
    }
    

    
}
