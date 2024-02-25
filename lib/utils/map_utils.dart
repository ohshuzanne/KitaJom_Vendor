import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  MapUtils._();

  static Future<void> openMap(String address) async {
    Uri googleMapUrl =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$address");

    if (await canLaunchUrl(googleMapUrl)) {
      await launchUrl(googleMapUrl);
    } else {
      throw 'Could not open the map';
    }
  }
}
