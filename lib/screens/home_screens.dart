import 'dart:async';
import 'package:app_location/screens/get_location.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_location/screens/koordinat.dart';
import 'package:app_location/screens/map.dart';

class HomeScreens extends StatefulWidget {
  final String accessToken;
  const HomeScreens({Key? key, required this.accessToken}) : super(key: key);

  @override
  _HomeScreensState createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  late ApiService _service;
  late Future<LocationData> _locationsFuture;
  int _currentPage = 1;
  int _totalLocations = 0;
  int _totalPages = 6;
  String _lastUpdate = '-';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _service = ApiService(accessToken: widget.accessToken);
    _fetchLocations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchLocations() async {
    setState(() {
      _locationsFuture = _service.getLocations(
        page: _currentPage,
        query: _searchQuery,
      );
    });

    _locationsFuture.then((data) {
      setState(() {
        _totalLocations = data.total;
        _totalPages = data.totalPages;
        _lastUpdate = data.lastSyncTime;
      });
    }).catchError((error) {
      print('Error fetching locations: $error');
    });
  }

  void _onSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
        _currentPage = 1;
        _fetchLocations();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: <Widget>[
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
              Text(
                'Manajemen Lokasi',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
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
                              'Total Lokasi',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _totalLocations.toString(),
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
                            Icon(Icons.calendar_month_sharp,
                                color: Colors.white, size: 24),
                            Text(
                              'Terakhir Perbarui',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _lastUpdate.toString(),
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Cari Lokasi...',
              suffixIcon: _searchController.text.isEmpty
                  ? Icon(Icons.search, color: Colors.blue.shade800)
                  : IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearch('');
                      },
                    ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue.shade800, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue.shade800, width: 1),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<LocationData>(
              future: _locationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.locations.isEmpty) {
                  return Center(child: Text('Tidak ada data'));
                }

                final locations = snapshot.data!.locations;

                return ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    final location = locations[index];

                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          children: [
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    location.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    location.area,
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MapPage(locationId: location.id)),
                                );
                              },
                              child: Icon(Icons.location_on,
                                  color: Colors.blue, size: 24),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Koordinat(locationId: location.id)),
                                );
                              },
                            ),
                            FaIcon(
                              FontAwesomeIcons.book,
                              size: 16,
                              color: Colors.yellow.shade800,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
        ),
        _buildPagination(),
      ]),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
          ),
          ...List.generate(_currentPage, (index) {
            final pageNumber = _currentPage + index;
            final isCurrentPage = _currentPage == pageNumber;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentPage = pageNumber;
                  _fetchLocations();
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: isCurrentPage ? 32 : 28,
                height: isCurrentPage ? 32 : 28,
                decoration: BoxDecoration(
                  color: isCurrentPage
                      ? Colors.blue.shade700
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                  boxShadow: isCurrentPage
                      ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                            offset: Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$pageNumber',
                    style: TextStyle(
                      color: isCurrentPage ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: isCurrentPage ? 14 : 13,
                    ),
                  ),
                ),
              ),
            );
          }),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
