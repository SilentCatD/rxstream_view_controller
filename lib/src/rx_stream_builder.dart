import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rx_builder/src/types.dart';
import 'package:rxdart/rxdart.dart';

class RxStreamBuilder<T> extends StatefulWidget {
  const RxStreamBuilder({
    Key? key,
    this.buildWhen,
    required this.builder,
    required this.stream,
  }) : super(key: key);
  final BuildWhen<T>? buildWhen;
  final RxWidgetBuilder<T> builder;
  final ValueStream<T> stream;

  @override
  State<RxStreamBuilder> createState() => _RxStreamBuilderState<T>();
}

class _RxStreamBuilderState<T> extends State<RxStreamBuilder<T>> {
  late T _state;
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
    if (widget.buildWhen?.call(_state, state) ?? true) {
      setState(() {
        _state = state;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    assert(widget.stream.hasValue,
        "subject must have initial value eg: ${BehaviorSubject.seeded(0)}");
    _state = widget.stream.value;
    _subscribe(widget.stream);
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RxStreamBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stream != oldWidget.stream) {
      _unsubscribe();
      _subscribe(widget.stream);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder.call(context, _state);
  }
}
