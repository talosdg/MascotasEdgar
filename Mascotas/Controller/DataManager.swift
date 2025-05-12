//
//  DataManager.swift
//  Mascotas
//
//  Created by Ángel González on 26/04/25.
//

import Foundation
import CoreData

class DataManager : NSObject {
    static let shared = DataManager()

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Mascotas")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Custom methods
    func llenaBD () {
        // validar si la BD ya se sincronizo
        let ud = UserDefaults.standard
        if ud.integer(forKey: "BD-OK") != 1 {
            if let url = URL (string:"http://janzelaznog.com/DDAM/iOS/mascotas.json") {
                let sesion = URLSession(configuration:.default)
                let task = sesion.dataTask(with: URLRequest(url: url)) {
                    datos, respuesta, err in
                    if err != nil && datos == nil {
                        print ("no se pudo descargar el feed de mascotas")
                        return
                    }
                    // parece que todo bien
                    do {
                        // si no se quieren utilizar estructuras que implementen Codable:
                        //let tmp = try JSONSerialization.jsonObject(with: datos!) as! [[String:Any]]
                        let arreglo = try JSONDecoder().decode([MascotaVO].self, from: datos!)
                        self.guardaMascotas (arreglo)
                        // TODO: implementa la parte de descarga y guardado de los responsables
                        self.obtenResponsables()
                    }
                    catch {
                        print ("algo falló \(error.localizedDescription)")
                    }
                }
                task.resume()
            }
            ud.setValue(1, forKey: "BD-OK")
        }
        // La BD ya fue sincronizada anteriormente
    }
    
    func guardaMascotas (_ mascotas:[MascotaVO]) {
        guard let entidadDesc = NSEntityDescription.entity(forEntityName: "Mascota", in: persistentContainer.viewContext) else { return }
        mascotas.forEach { mascotaVO in   // for m in mascotas { ... }
            let mascota = NSManagedObject(entity: entidadDesc, insertInto:persistentContainer.viewContext) as! Mascota
            mascota.inicializa(mascotaVO)
        }
        saveContext()
    }
    
    func obtenResponsables() {
        print("ejecutando obtension rersponsables")
        if let laURL = URL(string: "https://chocodelizzia.com/data/responsables2.json") {
            let sesion = URLSession(configuration: .default)
            let tarea = sesion.dataTask(with:URLRequest(url:laURL)) { data, response, error in
                if error != nil {
                    print ("no se pudo descargar el feed de responsables \(error?.localizedDescription ?? "")")
                    return
                }

                // Verificar que 'data' no sea nil
                if let data = data {
                    // Mostrar el contenido de 'data' en formato String (UTF-8)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Datos descargados respoinsables OK")  //   print("Datos descargados: \(jsonString)")  mostrando el contenido en formato de texto
                    } else {
                        print("Error al convertir los datos a String.")
                    }
                } else {
                    print("No se recibieron datos.")
                }

                
                do {
                    let tmp = try JSONDecoder().decode([ResponsableVO].self, from:data!)
                    print(tmp)
                    self.guardaResponsables (tmp)
                }
                catch { print ("no se obtuvo un JSON en la respuesta") }
            }
            tarea.resume()
        }
    }
    

    func guardaResponsables (_ responsables:[ResponsableVO]) {
        guard let entidadDesc = NSEntityDescription.entity(forEntityName: "Responsable", in: persistentContainer.viewContext) else { return }
        responsables.forEach { responsableVO in
            let responsable = NSManagedObject(entity: entidadDesc, insertInto:persistentContainer.viewContext) as! Responsable
            responsable.inicializa(responsableVO)
           /*
            if let nombre = responsable.duenio_de {
                print("Leyendo responsableVO: \(nombre)")
            }*/
            if let idMascota = responsableVO.duenoDe, idMascota != 0{ // se valida que existe el dueño
                print("Leyendo idMascota: \(idMascota) ")
                if let miMascota = buscaMascotaConId(idMascota){ // si existe
                    responsable.mascotas?.adding(miMascota) // se asigna mascota a responsable
                    miMascota.responsable = responsable // y responsable a mascota
                }
            } 
        }
        saveContext()
    }
    
    func buscaMascotaConId(_ idMascota:Int) -> Mascota?{
        let elQuery = Mascota.fetchRequest()
        let elFiltro = NSPredicate(format: "id == %d", idMascota)
        elQuery.predicate = elFiltro
        do {
            let tmp = try persistentContainer.viewContext.fetch(elQuery)
            return tmp.first // primer objeto del arreglo
        }
        catch {
            
            print ("no se puede ejecutar el query SELECT * FROM Mascota WHERE tipo='%'")
        }
        return nil
    }
    
    
    func todasLasMascotas() -> [Mascota] {
        var arreglo = [Mascota]()
        let elQuery = Mascota.fetchRequest()
        do {
            arreglo = try persistentContainer.viewContext.fetch(elQuery)
        }
        catch {
            print ("no se puede ejecutar el query SELECT * FROM Mascota")
        }
        return arreglo
    }
    
    func todasLasMascotas(num: Int, tipo:String, fil1: String = "", fil2: String = "", fil3: String = "", fil4: String = "") -> [Mascota] {
        
        print(num)
        
        var arreglo = [Mascota]()
        let elQuery = Mascota.fetchRequest()
        // [c] significa "case insensitive"
        let tipoInicial = NSPredicate(format:"tipo =[c] %@", tipo)
        let filter1 = NSPredicate(format:"tipo =[c] %@", fil1)
        let filter2 = NSPredicate(format:"tipo =[c] %@", fil2)
        let filter3 = NSPredicate(format:"tipo =[c] %@", fil3)
        let filter4 = NSPredicate(format:"tipo =[c] %@", fil4)
        let cPredicado = NSCompoundPredicate(orPredicateWithSubpredicates: [tipoInicial, filter1, filter2, filter3, filter4]) //
        elQuery.predicate = cPredicado
        do {
            arreglo = try persistentContainer.viewContext.fetch(elQuery)
        }
        catch {
            print ("no se puede ejecutar el query SELECT * FROM Mascota WHERE tipo='%'")
        }
        let sortedA = arreglo.sorted {m1, m2  in
            return m1.nombre ?? "" > m2.nombre ?? ""  // Descendente
        }
        return sortedA
    }
    
    func resumenMascotas() -> String {
        var resumen = ""
        let queryM = Mascota.fetchRequest()
        let queryR = Responsable.fetchRequest()
        do {
            let cuenta = try persistentContainer.viewContext.count(for:queryR)
            resumen = "Hay \(cuenta) responsables\n"
            let cuenta2 = try persistentContainer.viewContext.count(for:queryM)
            resumen += "Hay \(cuenta2) mascotas\n"
            // SELECT tipo, count(id) as cuantos FROM Mascota GROUP BY tipo
            // gato, 34
            // perro, 45
            let keypathExp = NSExpression(forKeyPath: "id")
            let expression = NSExpression(forFunction: "count:", arguments: [keypathExp])
            let countDesc = NSExpressionDescription()
            countDesc.expression = expression
            countDesc.name = "cuantos"
            countDesc.expressionResultType = .integer64AttributeType
            let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Mascota")
            //request.resultType = .countResultType
            request.returnsObjectsAsFaults = false
            request.propertiesToFetch = ["tipo", countDesc]
            request.propertiesToGroupBy = ["tipo"]
            request.resultType = .dictionaryResultType
            let dict = try persistentContainer.viewContext.fetch(request)
            for dictTipo in dict {
                let d = dictTipo as! Dictionary<String, Any>
                let t = d["tipo"] ?? ""
                let c = d["cuantos"] ?? 0
                resumen += "      \(c) \(t)\n"
            }
        }
        catch {
            
        }
        return resumen
    }
    
    func borrar(objeto:NSManagedObject){
        persistentContainer.viewContext.delete(objeto)
        saveContext()
        NotificationCenter.default.post(name: NSNotification.Name("DELETED_OBJECT"), object:nil)
    }
    func adoptar(){
        
        print("debe lanzar la adopcón")

    }
}
