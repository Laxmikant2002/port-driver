import 'dart:convert';

PlacesResponse placesResponseFromJson(String str) =>
    PlacesResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String placesResponseToJson(PlacesResponse data) => json.encode(data.toJson());

class PlacesResponse {

  PlacesResponse({
    required this.predictions,
    required this.status,
  });

  factory PlacesResponse.fromJson(Map<String, dynamic> json) => PlacesResponse(
        predictions: List<Prediction>.from((json['predictions'] as List)
            .map((x) => Prediction.fromJson(x as Map<String, dynamic>)),),
        status: json['status'] as String,
      );
  List<Prediction> predictions;
  String status;

  Map<String, dynamic> toJson() => {
        'predictions': List<dynamic>.from(predictions.map((x) => x.toJson())),
        'status': status,
      };
}

class Prediction {

  Prediction({
    required this.description,
    required this.matchedSubstrings,
    required this.placeId,
    required this.reference,
    required this.structuredFormatting,
    required this.terms,
    required this.types,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
        description: json['description'] as String,
        matchedSubstrings: List<MatchedSubstring>.from(
            (json['matched_substrings'] as List).map(
                (x) => MatchedSubstring.fromJson(x as Map<String, dynamic>),),),
        placeId: json['place_id'] as String,
        reference: json['reference'] as String,
        structuredFormatting: StructuredFormatting.fromJson(
            json['structured_formatting'] as Map<String, dynamic>,),
        terms: List<Term>.from((json['terms'] as List)
            .map((x) => Term.fromJson(x as Map<String, dynamic>)),),
        types: List<String>.from(json['types'] as List),
      );
  String description;
  List<MatchedSubstring> matchedSubstrings;
  String placeId;
  String reference;
  StructuredFormatting structuredFormatting;
  List<Term> terms;
  List<String> types;

  Map<String, dynamic> toJson() => {
        'description': description,
        'matched_substrings':
            List<dynamic>.from(matchedSubstrings.map((x) => x.toJson())),
        'place_id': placeId,
        'reference': reference,
        'structured_formatting': structuredFormatting.toJson(),
        'terms': List<dynamic>.from(terms.map((x) => x.toJson())),
        'types': List<dynamic>.from(types.map((x) => x)),
      };
}

class MatchedSubstring {

  MatchedSubstring({
    required this.length,
    required this.offset,
  });

  factory MatchedSubstring.fromJson(Map<String, dynamic> json) =>
      MatchedSubstring(
        length: json['length'] as int,
        offset: json['offset'] as int,
      );
  int length;
  int offset;

  Map<String, dynamic> toJson() => {
        'length': length,
        'offset': offset,
      };
}

class StructuredFormatting {

  StructuredFormatting({
    required this.mainText,
    required this.mainTextMatchedSubstrings,
    this.secondaryText,
  });

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) =>
      StructuredFormatting(
        mainText: json['main_text'] as String,
        mainTextMatchedSubstrings: List<MatchedSubstring>.from(
            (json['main_text_matched_substrings'] as List).map(
                (x) => MatchedSubstring.fromJson(x as Map<String, dynamic>),),),
        secondaryText: json['secondary_text'] as String?,
      );
  String mainText;
  List<MatchedSubstring> mainTextMatchedSubstrings;
  String? secondaryText;

  Map<String, dynamic> toJson() => {
        'main_text': mainText,
        'main_text_matched_substrings': List<dynamic>.from(
            mainTextMatchedSubstrings.map((x) => x.toJson()),),
        'secondary_text': secondaryText,
      };
}

class Term {

  Term({
    required this.offset,
    required this.value,
  });

  factory Term.fromJson(Map<String, dynamic> json) => Term(
        offset: json['offset'] as int,
        value: json['value'] as String,
      );
  int offset;
  String value;

  Map<String, dynamic> toJson() => {
        'offset': offset,
        'value': value,
      };
}
