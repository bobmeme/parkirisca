import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'model/directions_model.dart';

/* example direction 
{"geocoded_waypoints":[{"geocoder_status":"OK","place_id":"ChIJfyerXIAyZUcRtQVRnjALb5s","types":["street_address"]},{"geocoder_status":"OK","place_id":"EixTbG92ZW5za2EgY2VzdGEgNTgsIDEwMDAgTGp1YmxqYW5hLCBTbG92ZW5pYSIaEhgKFAoSCf8_b46eMmVHEehwMtNsrPl7EDo","types":["street_address"]}],"routes":[{"bounds":{"northeast":{"lat":46.0569547,"lng":14.5228294},"southwest":{"lat":46.0529372,"lng":14.5048182}},"copyrights":"Map data ©2022","legs":[{"distance":{"text":"2.1 km","value":2110},"duration":{"text":"8 mins","value":478},"end_address":"Slovenska cesta 58, 1000 Ljubljana, Slovenia","end_location":{"lat":46.0569547,"lng":14.5057591},"start_address":"Šlajmerjeva ulica 1c, 1000 Ljubljana, Slovenia","start_location":{"lat":46.0535718,"lng":14.5228294},"steps":[{"distance":{"text":"0.2 km","value":213},"duration":{"text":"1 min","value":54},"end_location":{"lat":46.0553982,"lng":14.522374},"html_instructions":"Head <b>northwest</b> on <b>Korytkova ulica</b> toward <b>Bohoričeva ulica</b><div style=\"font-size:0.9em\">Partial restricted usage road</div>","polyline":{"points":"yyaxGunswAEDIFEHCFCFMJQNQH{ABgCFy@@"},"start_location":{"lat":46.0535718,"lng":14.5228294},"travel_mode":"DRIVING"},{"distance":{"text":"0.3 km","value":264},"duration":{"text":"1 min","value":49},"end_location":{"lat":46.05523609999999,"lng":14.5189826},"html_instructions":"Turn <b>left</b> onto <b>Bohoričeva ulica</b>","maneuver":"turn-left","polyline":{"points":"gebxGykswAAdD@~@@^?h@@n@@PFl@Dn@Bd@HrA@X@P?NARCJ"},"start_location":{"lat":46.0553982,"lng":14.522374},"travel_mode":"DRIVING"},{"distance":{"text":"0.1 km","value":149},"duration":{"text":"1 min","value":31},"end_location":{"lat":46.0538962,"lng":14.5190646},"html_instructions":"Turn <b>left</b> onto <b>Njegoševa cesta</b>","maneuver":"turn-left","polyline":{"points":"gdbxGsvrwAp@AvAE`CG"},"start_location":{"lat":46.05523609999999,"lng":14.5189826},"travel_mode":"DRIVING"},{"distance":{"text":"0.2 km","value":173},"duration":{"text":"1 min","value":46},"end_location":{"lat":46.0538468,"lng":14.5168265},"html_instructions":"Turn <b>right</b> onto <b>Vrhovčeva ulica</b>","maneuver":"turn-right","polyline":{"points":"{{axGcwrwABvFDdE"},"start_location":{"lat":46.0538962,"lng":14.5190646},"travel_mode":"DRIVING"},{"distance":{"text":"0.1 km","value":102},"duration":{"text":"1 min","value":29},"end_location":{"lat":46.0529372,"lng":14.5166786},"html_instructions":"Turn <b>left</b> onto <b>Rozmanova ulica</b>","maneuver":"turn-left","polyline":{"points":"q{axGeirwAtD\\"},"start_location":{"lat":46.0538468,"lng":14.5168265},"travel_mode":"DRIVING"},{"distance":{"text":"0.3 km","value":260},"duration":{"text":"1 min","value":49},"end_location":{"lat":46.052994,"lng":14.5133155},"html_instructions":"Turn <b>right</b> at the 1st cross street onto <b>Ilirska ulica</b>","maneuver":"turn-right","polyline":{"points":"{uaxGghrwA?l@AlC?~A?jC?BEpCA`B"},"start_location":{"lat":46.0529372,"lng":14.5166786},"travel_mode":"DRIVING"},{"distance":{"text":"0.4 km","value":369},"duration":{"text":"1 min","value":68},"end_location":{"lat":46.0538777,"lng":14.5087157},"html_instructions":"Continue onto <b>Komenskega ulica</b>","polyline":{"points":"evaxGgsqwAMlBeBdM}@bJ"},"start_location":{"lat":46.052994,"lng":14.5133155},"travel_mode":"DRIVING"},{"distance":{"text":"34 m","value":34},"duration":{"text":"1 min","value":7},"end_location":{"lat":46.0541365,"lng":14.5086569},"html_instructions":"At the roundabout, take the <b>1st</b> exit onto <b>Kolodvorska ulica</b>","maneuver":"roundabout-right","polyline":{"points":"w{axGovpwAAAAAA?AAA?A?A?A??@A?A@A??@A??@A??@A@?@A@?@?@?@?@A?SE"},"start_location":{"lat":46.0538777,"lng":14.5087157},"travel_mode":"DRIVING"},{"distance":{"text":"0.3 km","value":310},"duration":{"text":"1 min","value":73},"end_location":{"lat":46.0549427,"lng":14.5048182},"html_instructions":"Turn <b>left</b> onto <b>Tavčarjeva ulica</b>","maneuver":"turn-left","polyline":{"points":"k}axGcvpwAy@rGq@~Fo@xECP"},"start_location":{"lat":46.0541365,"lng":14.5086569},"travel_mode":"DRIVING"},{"distance":{"text":"0.2 km","value":236},"duration":{"text":"1 min","value":72},"end_location":{"lat":46.0569547,"lng":14.5057591},"html_instructions":"Turn <b>right</b> onto <b>Slovenska cesta</b>","maneuver":"turn-right","polyline":{"points":"kbbxGc~owA_Bk@iA][KqBs@g@OSISOIG"},"start_location":{"lat":46.0549427,"lng":14.5048182},"travel_mode":"DRIVING"}],"traffic_speed_entry":[],"via_waypoint":[]}],"overview_polyline":{"points":"yyaxGunswAOLIPQRc@XcFJy@@AdDB~A@xARtCLnCE^hCG`CGBvFDdEtD\\AzD?jFEtCA`BMlBeBdM}@bJAAAAGAE@IJCHSEy@rGaBxMCP_Bk@eBi@yCcAg@YIG"},"summary":"Komenskega ulica","warnings":[],"waypoint_order":[]}],"status":"OK"}
*/

class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  final Dio _dio;

  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await _dio.get(
      _baseUrl,
      queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': 'AIzaSyAoReA-gAKgeLqqnyLtefb6mtJm-Ze_ZTA',
      },
    );
    print(response);
    // Check if response is successful
    if (response.statusCode == 200) {
      return Directions.fromMap(response.data);
    }
    return null;
  }
}
