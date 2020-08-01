//
//  ViewController.swift
//  200609
//
//  Created by 김성헌 on 2020/06/09.
//  Copyright © 2020 김성헌. All rights reserved.
//
import UIKit
import ARCL
import CoreLocation
import Foundation
import MapKit
import SceneKit

class ViewController: UIViewController {
     var info = [[127.07282707914266,37.53969283119606],[127.07307704187542,37.54020388741914],[127.07433249401548,37.53982062122785],[127.07576009134611,37.541598218141125],[127.07611559363336,37.54233425012056],[127.0764877759761,37.54254534340282],[127.07846537946708,37.54234262479629],[127.07829598278735,37.54120386518897],[127.07782103131206,37.54101776715057],[127.07780712909587,37.54153159607864]]
    let sceneLocationView = SceneLocationView()
    var routes: [MKRoute]?
    let locationNode = LocationNode(location: CLLocation(latitude: 37.783429, longitude: 126.991398))
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        let coordinate = CLLocationCoordinate2D(latitude: 37.539316, longitude: 127.077394)
        let location = CLLocation(coordinate: coordinate, altitude: 100)
        let image = UIImage(named: "pin.png")!
        let annotationNode = LocationAnnotationNode(location: location, image: image)
        var idx = 0;
        for item in info{
            let boxNode = SCNNode(geometry:SCNText(string: String(idx), extrusionDepth: 0.5))
            boxNode.scale = SCNVector3(0.3,0.3,0.3)
            let tempScene = SCNScene(named:"model.obj")!
            let material = SCNMaterial()
            var shape = tempScene.rootNode
            shape.childNode(withName: "model", recursively: true)
            shape.scale = SCNVector3(10,10,10)
            material.diffuse.contents = "materials.mtl"
            material.specular.contents = UIColor.white
            shape.geometry?.firstMaterial = material
            let locationnode = LocationNode(location: CLLocation(latitude:item[1],longitude:item[0]))
            let locationnode2 = LocationNode(location :CLLocation(coordinate: CLLocationCoordinate2D(latitude: item[1], longitude: item[0]), altitude: 10))
            locationnode.addChildNode(shape)
            locationnode2.addChildNode(boxNode)
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationnode)
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationnode2)
            idx += 1
        }
        locationNode.addChildNode(annotationNode)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationNode)
        addSceneModels()
    }
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      sceneLocationView.frame = view.bounds
    }
    func addSceneModels() {
        // 1. Don't try to add the models to the scene until we have a current location
        guard sceneLocationView.sceneLocationManager.currentLocation != nil else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.addSceneModels()
            }
            return
        }
        let box = SCNBox(width: 1, height: 0.2, length: 5, chamferRadius: 0.25)
        box.firstMaterial?.diffuse.contents = UIColor.gray.withAlphaComponent(0.5)
        // 2. If there is a route, show that
        var testcoords:[CLLocationCoordinate2D] = []
        var idx = 0;
        for item in info{
            testcoords.insert(CLLocationCoordinate2D(latitude: item[1],longitude: item[0]), at: idx)
            idx += 1;
        }
        let testline = MKPolyline(coordinates: testcoords, count: testcoords.count)
        sceneLocationView.addPolylines(polylines: [testline]){ distance->
            SCNBox in let box = SCNBox(width: 1, height: 0.5, length: distance, chamferRadius: 0.7)
                box.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(1)
                return box
        }
        sceneLocationView.autoenablesDefaultLighting = true
    }
    

}
