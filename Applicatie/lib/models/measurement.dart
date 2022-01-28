import 'dart:convert';

List<Measurement> postFromJson(String str) =>
    List<Measurement>.from(json.decode(str).map((x) => Measurement.fromMap(x)));

class Measurement {
  final int id;
  final String pubnubId;
  final double distance;
  final String timestamp;

  const Measurement({
    required this.id,
    required this.pubnubId,
    required this.distance,
    required this.timestamp,
  });

  factory Measurement.fromMap(Map<String, dynamic> json) {
    return Measurement(
      id: json['id'],
      pubnubId: json['pubnub_id'],
      distance: json['distance'].toDouble(),
      timestamp: json['timestamp'],
    );
  }
}