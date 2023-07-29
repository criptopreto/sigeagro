import 'package:redux/redux.dart';
import 'actions.dart';
import 'app_state.dart';

AppState stringReducer(AppState state, dynamic action) {
  if (action is UpdateFarmAction) {
    return AppState(action.newFarm);
  }
  return state;
}
