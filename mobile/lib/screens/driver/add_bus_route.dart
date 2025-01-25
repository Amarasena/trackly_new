import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddBusRoute extends StatefulWidget {
  const AddBusRoute({Key? key}) : super(key: key);

  @override
  _AddBusRouteState createState() => _AddBusRouteState();
}

class _AddBusRouteState extends State<AddBusRoute> {
  late GoogleMapController _mapController;
  late TextEditingController _startController;
  late TextEditingController _endController;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng _startLocation = LatLng(6.9271, 79.8612);
  LatLng _endLocation = LatLng(0.0, 0.0);
  List<LatLng> _waypoints = [];
  List<LatLng> _polylinePoints = [];

  // Temporary storage for route details
  Map<String, dynamic> _routeDetails = {};

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController();
    _endController = TextEditingController();
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  // Function to add markers to the map
  void _addMarker(LatLng position, String title) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          infoWindow: InfoWindow(title: title),
          onTap: () {
            _removeMarker(position);
          },
        ),
      );
    });
  }

  // Function to remove a marker and update routes
  void _removeMarker(LatLng position) {
    setState(() {
      _markers.removeWhere((marker) => marker.position == position);
      _waypoints.remove(position);
      _fetchRoutes();
    });
  }

  Future<void> _fetchRoutes() async {
    if (_startLocation.latitude == 0.0 || _endLocation.latitude == 0.0) return;

    final apiKey = 'AIzaSyAOEatSLRac4OG2bfIySYe6l8aV61Fm_rc';
    final baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
    final origin = 'origin=${_startLocation.latitude},${_startLocation.longitude}';
    final destination = 'destination=${_endLocation.latitude},${_endLocation.longitude}';
    final waypointParam = _waypoints.isNotEmpty
        ? 'waypoints=${_waypoints.map((point) => '${point.latitude},${point.longitude}').join('|')}'
        : '';
    final avoidHighways = 'avoid=highways';
    final alternatives = 'alternatives=true';
    final apiKeyParam = 'key=$apiKey';

    final url = '$baseUrl?$origin&$destination&$waypointParam&$avoidHighways&$alternatives&$apiKeyParam';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['routes'] != null && data['routes'].isNotEmpty) {
        setState(() {
          _polylines.clear();
          _polylinePoints.clear();
          final route = data['routes'][0];
          _polylinePoints = _decodePolyline(route['overview_polyline']['points']);

          final polyline = Polyline(
            polylineId: PolylineId('route_0'),
            points: _polylinePoints,
            color: Colors.blue,
            width: 5,
          );

          _polylines.add(polyline);
        });
      }
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  void _saveRoute() {
    if (_startLocation.latitude == 0.0 ||
        _endLocation.latitude == 0.0 ||
        _polylinePoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set Start, End locations, and fetch routes first.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _routeDetails = {
      'start': {'lat': _startLocation.latitude, 'lng': _startLocation.longitude},
      'end': {'lat': _endLocation.latitude, 'lng': _endLocation.longitude},
      'waypoints': _waypoints
          .map((point) => {'lat': point.latitude, 'lng': point.longitude})
          .toList(),
      'polyline': _polylinePoints
          .map((point) => {'lat': point.latitude, 'lng': point.longitude})
          .toList(),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Route details saved temporarily.'),
        duration: Duration(seconds: 2),
      ),
    );
  }


  void _onMapTapped(LatLng position) {
    if (_startLocation.latitude != 0.0 && _endLocation.latitude != 0.0) {
      setState(() {
        _waypoints.add(position);
        _addMarker(position, 'Waypoint');
        _fetchRoutes();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both Start and End locations before adding waypoints.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _startLocation,
              zoom: 12,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: _onMapTapped,
          ),
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(8),
                  child: GooglePlaceAutoCompleteTextField(
                    textEditingController: _startController,
                    googleAPIKey: 'AIzaSyAOEatSLRac4OG2bfIySYe6l8aV61Fm_rc',
                    inputDecoration: const InputDecoration(
                      labelText: 'Start Location',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    debounceTime: 800,
                    isLatLngRequired: true,
                    countries: ["lk"],
                    getPlaceDetailWithLatLng: (Prediction prediction) {
                      setState(() {
                        _startLocation = LatLng(double.parse(prediction.lat!), double.parse(prediction.lng!));
                        _addMarker(_startLocation, 'Start Location');
                        _mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: _startLocation,
                              zoom: 15,
                            ),
                          ),
                        );
                        _fetchRoutes();
                      });
                    },
                    itemClick: (prediction) {
                      _startController.text = prediction.description!;
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(8),
                  child: GooglePlaceAutoCompleteTextField(
                    textEditingController: _endController,
                    googleAPIKey: 'AIzaSyAOEatSLRac4OG2bfIySYe6l8aV61Fm_rc',
                    inputDecoration: const InputDecoration(
                      labelText: 'End Location',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    debounceTime: 800,
                    isLatLngRequired: true,
                    countries: ["lk"],
                    getPlaceDetailWithLatLng: (Prediction prediction) {
                      setState(() {
                        _endLocation = LatLng(double.parse(prediction.lat!), double.parse(prediction.lng!));
                        _addMarker(_endLocation, 'End Location');
                        _mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: _endLocation,
                              zoom: 15,
                            ),
                          ),
                        );
                        _fetchRoutes();
                      });
                    },
                    itemClick: (prediction) {
                      _endController.text = prediction.description!;
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              bottom: 50,
              left: 16,
              right: 16,
              child: ElevatedButton(
                  onPressed: _saveRoute,
                  child: const Text('Save Route')
              )
          ),
        ],
      ),
    );
  }
}
