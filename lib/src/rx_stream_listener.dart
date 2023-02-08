import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rx_builder/src/types.dart';

class RxStreamListener<T> extends StatefulWidget {
  const RxStreamListener({
    Key? key,
    required this.stream,
    required this.listen,
    required this.child,
  }) : super(key: key);
  final Stream<T> stream;
  final RxStateCallback<T> listen;
  final Widget child;

  @override
  State<RxStreamListener> createState() => _RxStreamListenerState<T>();
}

class _RxStreamListenerState<T> extends State<RxStreamListener<T>> {
  StreamSubscription<T>? _subscription;

  void _subscribe(Stream<T> stream) {
    _subscription = stream.listen((event) {
      _handleEvent(event);
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _handleEvent(T state) {
    if (!mounted) return;
    widget.listen.call(state);
  }

  @override
  void initState() {
    super.initState();
    _subscribe(widget.stream);
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RxStreamListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stream != oldWidget.stream) {
      _unsubscribe();
      _subscribe(widget.stream);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
