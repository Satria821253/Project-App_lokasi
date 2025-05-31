import 'package:app_location/screens/get_location.dart';
import 'package:app_location/screens/home_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MapPage extends StatefulWidget {

  final String locationId;

  const MapPage({super.key, required this.locationId});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late ApiService _service;
  LocationItem? _locationItem;
  bool _isLoading = true;
  String _errorMessage = '';
  final MapController _mapController = MapController();
  final LatLng _fallbackPosition = LatLng(-6.200000, 106.816666);
 

  @override
  void initState() {
    super.initState();
    _service = ApiService(accessToken: widget.locationId);
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final locationData = await _service.getlokasibyId(widget.locationId);
      setState(() {
        _locationItem = locationData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }
    void _centerMap() {
    if (_locationItem == null || _locationItem!.polygon.coordinates.isEmpty) return;
    
    final coords = _locationItem!.polygon.coordinates.first;
    if (coords.isEmpty) return;

    // Calculate center point
    double latSum = 0, lngSum = 0;
    for (var coord in coords) {
      latSum += coord[1];
      lngSum += coord[0];
    }
    final center = LatLng(latSum / coords.length, lngSum / coords.length);
    
    _mapController.move(center, 15);
  }

  List<LatLng> _getPolygonPoints() {
    if (_locationItem == null || _locationItem!.polygon.coordinates.isEmpty) {
      return [];
    }
    return _locationItem!.polygon.coordinates.first
        .map((coord) => LatLng(coord[1], coord[0]))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 25, top: 60, right: 25),
          width: 400,
          height: 203,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade800.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              )
            ],
            border: Border.all(color: Colors.blue.shade800, width: 2),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsetsGeometry.only(left: 30)),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreens(accessToken: widget.locationId,)
                          ),
                        );
                      },
                      child: FaIcon(FontAwesomeIcons.arrowLeft,
                          color: Colors.white, size: 20)),
                  SizedBox(width: 20),
                  Text(
                    _locationItem!.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Icon(Icons.location_on,
                                color: Colors.white, size: 24),
                            Text(
                              'Total Titik',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ),
                            SizedBox(height: 4),
                            Text(
                            _locationItem?.polygon.coordinates.first.length.toString() ?? '0',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ],
                        ),
                        SizedBox(width: 130),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            FaIcon(FontAwesomeIcons.book,
                                size: 20, color: Colors.white),
                            Text(
                              'Wilayah',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _locationItem?.area ?? '-',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text('Error: $_errorMessage'))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blue,
                              width: 3,
                            ),
                          ),
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              center: _fallbackPosition,
                              zoom: 15.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.app',
                              ),
                              PolygonLayer(
                                polygons: [
                                   Polygon(
                                    points: _getPolygonPoints(),
                                    color: Colors.blue.withOpacity(0.3),
                                    borderColor: Colors.blue,
                                    borderStrokeWidth: 2,
                                    isFilled: true,
                                  ),
                                ],
                              ),
                              MarkerLayer(
                                markers: _getPolygonPoints().map((point) => Marker(
                                  point: point,
                                  builder: (ctx) => const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
    
  }
}
