import 'dart:async';
import 'dart:typed_data';

import 'package:appflowy_backend/protobuf/flowy-error/errors.pb.dart';
import 'package:appflowy_backend/protobuf/flowy-notification/protobuf.dart';
import 'package:appflowy_backend/protobuf/flowy-search/entities.pbenum.dart';
import 'package:appflowy_backend/rust_stream.dart';
import 'package:appflowy_result/appflowy_result.dart';

import 'notification_helper.dart';

typedef SearchNotificationCallback = void Function(
  SearchNotification,
  FlowyResult<Uint8List, FlowyError>,
);

class SearchNotificationParser
    extends NotificationParser<SearchNotification, FlowyError> {
  SearchNotificationParser({
    super.id,
    required super.callback,
  }) : super(
          tyParser: (ty) => SearchNotification.valueOf(ty),
          errorParser: (bytes) => FlowyError.fromBuffer(bytes),
        );
}

typedef SearchNotificationHandler = Function(
  SearchNotification ty,
  FlowyResult<Uint8List, FlowyError> result,
);

class SearchNotificationListener {
  SearchNotificationListener({
    required String objectId,
    required SearchNotificationHandler handler,
  }) : _parser = SearchNotificationParser(id: objectId, callback: handler) {
    _subscription =
        RustStreamReceiver.listen((observable) => _parser?.parse(observable));
  }

  StreamSubscription<SubscribeObject>? _subscription;
  SearchNotificationParser? _parser;

  Future<void> stop() async {
    _parser = null;
    await _subscription?.cancel();
    _subscription = null;
  }
}
