// To parse this JSON data, do
//
//     final placeIdResponse = placeIdResponseFromJson(jsonString);

import 'dart:convert';

PlaceIdResponse placeIdResponseFromJson(String str) =>
    PlaceIdResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String placeIdResponseToJson(PlaceIdResponse data) =>
    json.encode(data.toJson());

class PlaceIdResponse {
  PlaceIdResponse({
    required this.htmlAttributions,
    required this.result,
    required this.status,
  });

  factory PlaceIdResponse.fromJson(Map<String, dynamic> json) =>
      PlaceIdResponse(
        htmlAttributions: json['html_attributions'] != null
            ? List<String>.from(json['html_attributions'] as List)
            : [],
        result: Result.fromJson(json['result'] as Map<String, dynamic>),
        status: json['status'] as String,
      );
  List<dynamic> htmlAttributions;
  Result result;
  String status;

  Map<String, dynamic> toJson() => {
        'html_attributions': List<dynamic>.from(htmlAttributions.map((x) => x)),
        'result': result.toJson(),
        'status': status,
      };
}

class Result {
  Result({
    required this.geometry,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        geometry: Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
      );
  Geometry geometry;

  Map<String, dynamic> toJson() => {
        'geometry': geometry.toJson(),
      };
}

class Geometry {
  Geometry({
    required this.location,
    required this.viewport,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        location: Location.fromJson(json['location'] as Map<String, dynamic>),
        viewport: Viewport.fromJson(json['viewport'] as Map<String, dynamic>),
      );
  Location location;
  Viewport viewport;

  Map<String, dynamic> toJson() => {
        'location': location.toJson(),
        'viewport': viewport.toJson(),
      };
}

class Location {
  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        lat: (json['lat'] as num?)?.toDouble() ?? 0.0, // Default to 0.0 if null
        lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      );
  double lat;
  double lng;

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
      };
}

class Viewport {
  Viewport({
    required this.northeast,
    required this.southwest,
  });

  factory Viewport.fromJson(Map<String, dynamic> json) => Viewport(
        northeast: Location.fromJson(json['northeast'] as Map<String, dynamic>),
        southwest: Location.fromJson(json['southwest'] as Map<String, dynamic>),
      );
  Location northeast;
  Location southwest;

  Map<String, dynamic> toJson() => {
        'northeast': northeast.toJson(),
        'southwest': southwest.toJson(),
      };
}
