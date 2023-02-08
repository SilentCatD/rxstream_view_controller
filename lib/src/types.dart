import 'package:flutter/widgets.dart';

typedef BuildWhen<T> = bool Function(T prevState, T currentState);
typedef RxWidgetBuilder<T> = Widget Function(BuildContext context, T state);
typedef RxStateCallback<T> = void Function(T state);
typedef StateSelector<S, T> = T Function(S state);
typedef Create<T> = T Function(BuildContext context);
