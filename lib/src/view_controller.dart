import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:rx_builder/src/types.dart';

class ViewControllerProviderNotInScope implements Exception {
  ViewControllerProviderNotInScope(this.type);

  final Type type;

  @override
  String toString() {
    return "Can't find $ViewControllerProvider of type $type";
  }
}

abstract class ViewController {
  Future<void> init() async {}

  Future<void> dispose() async {}
}

/// Optional DI and base view controller for inherited access
class ViewControllerProvider<T extends ViewController>
    extends SingleChildStatefulWidget {
  const ViewControllerProvider({
    Key? key,
    required Create<T> create,
    Widget? child,
  })  : _isCreated = true,
        _create = create,
        _controller = null,
        super(key: key, child: child);

  const ViewControllerProvider.value({
    Key? key,
    required T value,
    Widget? child,
  })  : _isCreated = false,
        _create = null,
        _controller = value,
        super(key: key, child: child);

  final bool _isCreated;
  final Create<T>? _create;
  final T? _controller;

  static T of<T extends ViewController>(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<
        _InheritedViewControllerScope<T>>();
    if (element == null) {
      throw ViewControllerProviderNotInScope(T);
    }
    return (element.widget as _InheritedViewControllerScope<T>).controller;
  }

  @override
  State<StatefulWidget> createState() => _ViewControllerProviderState();
}

class _ViewControllerProviderState<T extends ViewController>
    extends SingleChildState<ViewControllerProvider<T>> {
  late final T _controller;
  late final bool _isCreated;

  @override
  void initState() {
    super.initState();
    _isCreated = widget._isCreated;
    if (_isCreated) {
      _controller = widget._create!.call(context);
      _controller.init();
    } else {
      _controller = widget._controller!;
    }
  }

  @override
  void dispose() {
    if (_isCreated) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(child != null,
        "usage outside of $MultiViewControllerProvider not allowed");
    return _InheritedViewControllerScope(
      controller: _controller,
      child: child!,
    );
  }
}

class _InheritedViewControllerScope<T extends ViewController>
    extends InheritedWidget {
  final T controller;

  const _InheritedViewControllerScope({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

class MultiViewControllerProvider extends Nested {
  MultiViewControllerProvider({
    Key? key,
    required List<ViewControllerProvider> controllers,
    required Widget child,
  }) : super(key: key, children: controllers, child: child);
}

extension GetController on BuildContext {
  T get<T extends ViewController>() {
    return ViewControllerProvider.of<T>(this);
  }
}
