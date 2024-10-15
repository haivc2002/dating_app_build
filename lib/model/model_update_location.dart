class ModelUpdateLocation {
  int idUser;
  double lat, lon;
  String token;

  ModelUpdateLocation({
    required this.idUser,
    required this.lat,
    required this.lon,
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'lat': lat,
      'lon': lon,
      'token': token
    };
  }
  factory ModelUpdateLocation.fromJson(Map<String, dynamic> json) {
    return ModelUpdateLocation(
      idUser: json['idUser'],
      lat: json['lat'],
      lon: json['lon'],
      token: json['token'],
    );
  }
}