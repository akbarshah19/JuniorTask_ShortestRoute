//
//  ViewController.swift
//  Junior-Task_ShortestRouteOnMap
//
//  Created by Akbarshah Jumanazarov on 6/9/23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    let mapView: MKMapView = {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add", for: .normal)
        button.backgroundColor = .secondaryLabel
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        return button
    }()
    
    let routeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Route", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.backgroundColor = .secondaryLabel
        button.layer.cornerRadius = 8
        button.isHidden = true
        return button
    }()
    
    let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.backgroundColor = .secondaryLabel
        button.layer.cornerRadius = 8
        button.isHidden = true
        return button
    }()

    var annotationsArray = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        mapView.delegate = self
        setConstraints()
        
        addButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(didTapRoute), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
    }

    @objc private func didTapAdd() {
        alertAdd(title: "Add", placdeHolder: "Address") { text in
            self.setupPlaceMark(addressPlace: text)
        }
    }
    
    @objc private func didTapRoute() {
        for i in 0...annotationsArray.count - 2 {
            createDirectionRequest(startCoordinate: annotationsArray[i].coordinate, destinationCoordinate: annotationsArray[i + 1].coordinate)
        }
        
        mapView.showAnnotations(annotationsArray, animated: true)
    }
    
    @objc private func didTapReset() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationsArray = [MKPointAnnotation]()
        routeButton.isHidden = true
        resetButton.isHidden = true
    }
    
    private func setupPlaceMark(addressPlace: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressPlace) { [self] placeMarks, error in
            if let error = error {
                print(error)
                alertError(title: "Error", message: "Something went wrong. Please try again.")
                return
            }
            
            guard let placeMarks = placeMarks else { return }
            let placeMark = placeMarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = addressPlace
            guard let placeMarkLocation = placeMark?.location else { return }
            annotation.coordinate = placeMarkLocation.coordinate
            
            annotationsArray.append(annotation)
            if annotationsArray.count > 2 {
                routeButton.isHidden = false
                resetButton.isHidden = false
            }
            
            mapView.showAnnotations(annotationsArray, animated: true)
        }
    }
    
    private func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate:  CLLocationCoordinate2D) {
        let startCLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startCLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: request)
        direction.calculate { response, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.alertError(title: "Error", message: "Directions unavailable, please try again later.")
                return
            }
            
            var minRoute = response.routes[0]
            for route in response.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            self.mapView.addOverlay(minRoute.polyline)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .green
        return renderer
    }
}

extension ViewController {
    func setConstraints() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
        ])
        
        mapView.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            addButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            addButton.heightAnchor.constraint(equalToConstant: 35),
            addButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        mapView.addSubview(routeButton)
        NSLayoutConstraint.activate([
            routeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 10),
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -70),
            routeButton.heightAnchor.constraint(equalToConstant: 35),
            routeButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        mapView.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -70),
            resetButton.heightAnchor.constraint(equalToConstant: 35),
            resetButton.widthAnchor.constraint(equalToConstant: 70)
        ])
    }
}

