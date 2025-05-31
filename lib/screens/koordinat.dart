import 'package:app_location/screens/home_screens.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_location/screens/get_location.dart';

class Koordinat extends StatefulWidget {
  final String locationId;

  const Koordinat({super.key, required this.locationId});

  @override
  State<Koordinat> createState() => _KoordinatState();
}

class _KoordinatState extends State<Koordinat> {
  late final ApiService _apiService;
  LocationItem? _locationItem;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(accessToken: widget.locationId);
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    try {
      final locationData = await _apiService.getlokasibyId(widget.locationId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 25, top: 60, right: 25),
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
                  offset: const Offset(0, 3),
                )
              ],
              border: Border.all(color: Colors.blue.shade800, width: 2),
            ),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.only(left: 30)),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreens(
                                    accessToken: widget.locationId)),
                          );
                        },
                        child: FaIcon(FontAwesomeIcons.arrowLeft,
                            color: Colors.white, size: 20)),
                    const SizedBox(width: 20),
                    const Text(
                      'PT.MAKERINDO PRIMA SOLUSI',
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
                      padding: const EdgeInsets.only(top: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(Icons.location_on,
                                  color: Colors.white, size: 24),
                              const Text(
                                'Total Titik',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '10',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(width: 130),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const FaIcon(FontAwesomeIcons.book,
                                  size: 20, color: Colors.white),
                              const Text(
                                'Wilayah',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'MAKERINDO',
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
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage.isNotEmpty
                          ? Center(child: Text('Error: $_errorMessage'))
                          : _locationItem == null
                              ? const Center(
                                  child: Text('Data lokasi tidak tersedia'))
                              : _buildKoordinatCard(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKoordinatCard() {
    final polygon = _locationItem!.polygon;
    final koordinat = polygon.coordinates.first;
    return ListView.builder(
      itemCount: koordinat.length,
      itemBuilder: (context, index) {
        final koord = koordinat[index];
        final latitude = koord[1];
        final longitude = koord[0];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Text(
                  '${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${latitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Latitude',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Longitude',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
