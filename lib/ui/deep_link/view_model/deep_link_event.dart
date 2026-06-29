part of 'deep_link_bloc.dart';

abstract class DeepLinkEvent {}

/// Fired when any zplit:// URI is received (cold or warm start)
class DeepLinkReceived extends DeepLinkEvent {
  final Uri uri;
  DeepLinkReceived(this.uri);
}
