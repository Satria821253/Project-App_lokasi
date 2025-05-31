import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationResponse {
  final String message;
  final int statusCode;
  final dynamic error;
  final LocationData data;

  LocationResponse({
    required this.message,
    required this.statusCode,
    this.error,
    required this.data,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      message: json['message'],
      statusCode: json['statusCode'],
      error: json['error'],
      data: LocationData.fromJson(json['data']),
    );
  }
}

class LocationData {
  final int total;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final String lastSyncTime;
  final List<LocationItem> locations;

  LocationData({
    required this.total,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.lastSyncTime,
    required this.locations,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    var list = json['locations'] as List;
    List<LocationItem> locationsList =
        list.map((i) => LocationItem.fromJson(i)).toList();

    return LocationData(
      total: json['total'],
      totalItems: json['totalItems'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      lastSyncTime: json['lastSyncTime'],
      locations: locationsList,
    );
  }
}

class LocationItem {
  final String id;
  final String name;
  final String area;
  final CustomPolygon polygon;

  LocationItem(
      {required this.id,
      required this.name,
      required this.area,
      required this.polygon});

  factory LocationItem.fromJson(Map<String, dynamic> json) {
    return LocationItem(
      id: json['id'],
      name: json['name'],
      area: json['area'],
      polygon: CustomPolygon.fromJson(json['polygon']),
    );
  }
}

class CustomPolygon {
  final String type;
  final List<List<List<double>>> coordinates;

  CustomPolygon({
    required this.type,
    required this.coordinates,
  });

  factory CustomPolygon.fromJson(Map<String, dynamic> json) {
    return CustomPolygon(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((outer) => (outer as List<dynamic>)
              .map((middle) => (middle as List<dynamic>)
                  .map((inner) => inner as double)
                  .toList())
              .toList())
          .toList(),
    );
  }
}

class ApiService {
  final String baseUrl = 'https://api-vatsubsoil-dev.ggfsystem.com';
  final String accessToken;

  ApiService({required this.accessToken});

  Future<LocationData> getLocations({
    int page = 1,
    required String query,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/locations?page=$page'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return LocationData.fromJson(json.decode(response.body));
    } else {
      throw Exception('gagal menggambil data lokasi: ${response.statusCode}');
    }
  }

  Future<LocationItem> getlokasibyId(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/locations/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return LocationItem.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load location data');
    }
  }
}
