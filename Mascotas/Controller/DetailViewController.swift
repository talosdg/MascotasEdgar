//
//  ViewController.swift
//  Mascotas
//
//  Created by Ángel González on 26/04/25.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
   

    var laMascota : Mascota!
    var elResponsable: Responsable!
    var detalle: DetailView!
    
    var pickerData: [String] = []
    var responsables: [Responsable] = []
    
    var toolbar: UIToolbar!
    var doneButton: UIBarButtonItem!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        detalle = DetailView(frame:view.bounds.insetBy(dx: 40, dy: 40))
        view.addSubview(detalle)
        
        // Configuración del picker
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = .arena

        hiddenTextField.inputView = pickerView
        hiddenTextField.isHidden = true
        view.addSubview(hiddenTextField)

        toolbar = UIToolbar()
        toolbar.sizeToFit()
        doneButton = UIBarButtonItem(title: "Elegir", style: .done, target: self, action: #selector(donePicker))
        doneButton.tintColor = .cream
        let cancelButton = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(cancelarPicker))
        cancelButton.tintColor = .red

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)

        hiddenTextField.inputAccessoryView = toolbar

        
        cargarResponsables()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: - Obtener y presentar la información de la mascota
        detalle.txtNombre.text = laMascota.nombre ?? ""
        detalle.txtGenero.text = laMascota.genero ?? ""
        detalle.txtTipo.text = laMascota.tipo ?? ""
        detalle.txtEdad.text = "\(laMascota.edad)"
        detalle.btnDelete.addTarget(self, action:#selector(borrar), for:.touchUpInside)
        detalle.btnAdopt.addTarget(self, action:#selector(adoptar), for:.touchUpInside)
        
        // TODO: - Si la mascota ya tiene un responsable, ocultar el botón
        if laMascota.responsable != nil {
            detalle.btnAdopt.isHidden = true
        }
        else{
            detalle.btnAdopt.isHidden = false
        }
    }
    
    @objc
    func borrar () {
        let ac = UIAlertController(title: "CONFIRME", message:"Desea borrar este registro?", preferredStyle: .alert)
        let action = UIAlertAction(title: "SI", style: .destructive) {
            alertaction in
            DataManager.shared.borrar(objeto:self.laMascota)
            self.dismiss(animated: true)
        }
        let action2 = UIAlertAction(title: "NO", style:.cancel)
        ac.addAction(action)
        ac.addAction(action2)
        self.present(ac, animated: true)

    }
    
    func cargarResponsables() {
        let context = DataManager.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Responsable> = Responsable.fetchRequest()
        
        do {
            self.responsables = try context.fetch(fetchRequest) // <-- PROPIEDAD
            // ORIGINAL let responsables = try context.fetch(fetchRequest)
            pickerData = responsables.compactMap { $0.nombre }
            pickerView.reloadAllComponents()
        } catch {
            print("Error al obtener responsables: \(error)")
        }
    }
   
    
      // picker responsables
      let pickerView = UIPickerView()
      let hiddenTextField = UITextField()
     // let btnAdopt = UIButton(type: .system)
    
        @objc func adoptar() {
            // Ocultar el botón
            detalle.btnAdopt.isHidden = true

            // Mostrar el picker
            hiddenTextField.becomeFirstResponder()
        }

        @objc func donePicker() {
            print("donePicker ejecutado")
            hiddenTextField.resignFirstResponder()
            let selectedIndex = pickerView.selectedRow(inComponent: 0)
            print("selectedIndex:", selectedIndex)
            print("responsables count:", responsables.count)
            
            guard responsables.indices.contains(selectedIndex) else {
                print("Índice fuera de rango, cancelando.")
                return
            }

            let responsableSeleccionado = responsables[selectedIndex]
            print("Responsable seleccionado \(responsableSeleccionado.nombre ?? "")")
            laMascota.responsable = responsableSeleccionado
            
            // Guarda el cambio en Core Data
            DataManager.shared.saveContext()

            print("Responsable \(responsableSeleccionado.nombre ?? "") asignado a \(laMascota.nombre ?? "")")
        }
        @objc func cancelarPicker() {
            hiddenTextField.resignFirstResponder()
            detalle.btnAdopt.isHidden = false
            print("Selección cancelada")
        }

        // MARK: - UIPickerView Delegate y DataSource

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return pickerData.count
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return pickerData[row]
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
           // print("Preseleccionado: \(pickerData[row])")
        }
}

