import 'dart:async';

import 'package:flutter/material.dart';
import 'types.dart';
import 'package:rxdart/rxdart.dart';

class RxStreamSelector<S, T> extends StatefulWidget {
  const RxStreamSelector({
    Key? key,
    required this.builder,
    required this.stream,
    required this.selector,
  }) : super(key: key);
  final StateSelector<S, T> selector;
  final RxWidgetBuilder<T> builder;
  final ValueStream<S> stream;

  @override
  State<RxStreamSelector> createState() => _RxStreamSelectorState<S, T>();
}

class _RxStreamSelectorState<S, T> extends State<RxStreamSelector<S, T>> {
  late T _value;
  StreamSubscription<S>? _subscription;

  void _subscribe(Stream<S> stream) {
    _subscription = stream.listen((event) {
      _handleEvent(event);
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _handleEvent(S state) {
    if (!mounted) return;
    final newValue = widget.selector.call(state);
    if (_value != newValue) {
      setState(() {
        _value = newValue;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    assert(widget.stream.hasValue,
        "subject must have initial value eg: ${BehaviorSubject.seeded(0)}");
    _value = widget.selector(widget.stream.value);
    _subscribe(widget.stream);
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RxStreamSelector<S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stream != oldWidget.stream) {
      _unsubscribe();
      _subscribe(widget.stream);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder.call(context, _value);
  }
}
