import 'dart:async';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  Future<Uri?> getInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      print('INITIAL LINK: $uri');
      return uri;
    } catch (e) {
      print('INITIAL LINK ERROR: $e');
      return null;
    }
  }

  Stream<Uri> get linkStream => _appLinks.uriLinkStream;

  void listen(void Function(Uri uri) onLink) {
    _sub = _appLinks.uriLinkStream.listen((uri) {
      print('STREAM LINK: $uri');
      onLink(uri);
    });
  }

  void dispose() {
    _sub?.cancel();
  }
}
