// lib/core/deeplink/app_link_listener.dart

import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/ui/deep_link/view_model/deep_link_bloc.dart';

class AppLinkListener extends StatefulWidget {
  final Widget child;
  const AppLinkListener({required this.child, super.key});

  @override
  State<AppLinkListener> createState() => _AppLinkListenerState();
}

class _AppLinkListenerState extends State<AppLinkListener> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // cold start
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _dispatch(initial);
    } catch (e) {
      debugPrint('[AppLinkListener] cold start error: $e');
    }

    // warm start
    _sub = _appLinks.uriLinkStream.listen(
      _dispatch,
      onError: (e) => debugPrint('[AppLinkListener] stream error: $e'),
    );
  }

  void _dispatch(Uri uri) {
    if (!mounted) return;
    context.read<DeepLinkBloc>().add(DeepLinkReceived(uri));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
