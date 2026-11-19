import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:location/location.dart';
import 'package:watermangment/theme.dart';
import 'package:watermangment/widgets/glass_container.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Location location = Location();
  latlong.LatLng _currentLocation = const latlong.LatLng(19.2952, 72.8544); // Bhayandar, Mumbai
  bool _isLoading = true;
  bool _useGoogleMaps = false; // Vector Dark map works 100% instantly without API key!

  final MapController _vectorMapController = MapController();
  gmaps.GoogleMapController? _gmapsController;

  final String _darkMapStyle = '''
  [
    {"elementType": "geometry", "stylers": [{"color": "#1d2c4d"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#8ec3b9"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#1a3646"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#0e1626"}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#2c3e50"}]}
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  _getLocation() async {
    Timer(const Duration(seconds: 2), () {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    });

    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
      }

      if (permissionGranted == PermissionStatus.granted) {
        LocationData locationData = await location.getLocation().timeout(const Duration(seconds: 3));
        if (mounted && locationData.latitude != null && locationData.longitude != null) {
          setState(() {
            _currentLocation = latlong.LatLng(locationData.latitude!, locationData.longitude!);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }

      location.onLocationChanged.listen((LocationData currentLocation) {
        if (mounted && currentLocation.latitude != null && currentLocation.longitude != null) {
          setState(() {
            _currentLocation = latlong.LatLng(currentLocation.latitude!, currentLocation.longitude!);
          });
        }
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppTheme.cyanAccent),
                      SizedBox(height: 12),
                      Text('Loading Live Map...', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                )
              : _useGoogleMaps 
                  ? gmaps.GoogleMap(
                      onMapCreated: (controller) {
                        _gmapsController = controller;
                        try {
                          _gmapsController?.setMapStyle(_darkMapStyle);
                        } catch (_) {}
                      },
                      initialCameraPosition: gmaps.CameraPosition(
                        target: gmaps.LatLng(_currentLocation.latitude, _currentLocation.longitude),
                        zoom: 14.5,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      markers: {
                        gmaps.Marker(
                          markerId: const gmaps.MarkerId('user_loc'),
                          position: gmaps.LatLng(_currentLocation.latitude, _currentLocation.longitude),
                          infoWindow: const gmaps.InfoWindow(title: 'Your Location'),
                          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueAzure),
                        ),
                        gmaps.Marker(
                          markerId: const gmaps.MarkerId('area_low'),
                          position: gmaps.LatLng(_currentLocation.latitude + 0.005, _currentLocation.longitude + 0.005),
                          infoWindow: const gmaps.InfoWindow(title: 'Low Pressure Area'),
                          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueOrange),
                        ),
                        gmaps.Marker(
                          markerId: const gmaps.MarkerId('area_nowater'),
                          position: gmaps.LatLng(_currentLocation.latitude - 0.003, _currentLocation.longitude + 0.002),
                          infoWindow: const gmaps.InfoWindow(title: 'No Water Outage'),
                          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueRed),
                        ),
                      },
                    )
                  : FlutterMap(
                      mapController: _vectorMapController,
                      options: MapOptions(
                        initialCenter: _currentLocation,
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          // Standard OpenStreetMap vector tiles - 100% reliable tile download without API key!
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.watermangment',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentLocation,
                              width: 50,
                              height: 50,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.cyanAccent, width: 2),
                                ),
                                child: const Center(
                                  child: Icon(Icons.my_location, color: AppTheme.cyanAccent, size: 26),
                                ),
                              ),
                            ),
                            Marker(
                              point: latlong.LatLng(_currentLocation.latitude + 0.004, _currentLocation.longitude + 0.003),
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.water_drop, color: AppTheme.statusOrange, size: 32),
                            ),
                            Marker(
                              point: latlong.LatLng(_currentLocation.latitude - 0.003, _currentLocation.longitude + 0.002),
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.water_drop, color: AppTheme.statusRed, size: 32),
                            ),
                          ],
                        ),
                      ],
                    ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Search Bar
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GlassContainer(
                    color: const Color(0xFF082746).withOpacity(0.95),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.white70),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search area...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        // Toggle Button to switch between Live Map & Google Map
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _useGoogleMaps = !_useGoogleMaps;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.cyanAccent.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                Icon(_useGoogleMaps ? Icons.map : Icons.layers, color: AppTheme.cyanAccent, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  _useGoogleMaps ? 'Google' : 'Live Map', 
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                
                // Bottom Legend Container
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 90.0),
                  child: GlassContainer(
                    color: const Color(0xFF082746).withOpacity(0.95),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Area Water Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            GestureDetector(
                              onTap: () {
                                if (_useGoogleMaps && _gmapsController != null) {
                                  _gmapsController!.animateCamera(gmaps.CameraUpdate.newLatLng(
                                    gmaps.LatLng(_currentLocation.latitude, _currentLocation.longitude),
                                  ));
                                } else {
                                  _vectorMapController.move(_currentLocation, 15.0);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.my_location, color: AppTheme.cyanAccent, size: 20),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildLegendItem(AppTheme.statusGreen, 'Normal'),
                            _buildLegendItem(AppTheme.statusOrange, 'Low Press.'),
                            _buildLegendItem(AppTheme.statusRed, 'No Water'),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}
