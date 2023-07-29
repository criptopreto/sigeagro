import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'app_state.dart';
import 'reducers.dart';

final store = Store<AppState>(
  stringReducer,
  initialState: AppState('Todas'),
);
