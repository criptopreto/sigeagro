import 'package:flutter_redux/flutter_redux.dart';
import 'package:jobix/src/components/employees/employee_panel_card.dart';
import 'package:jobix/src/components/employees/employee_panel_info.dart';
import 'package:jobix/src/responsive.dart';
import 'package:flutter/material.dart';
import 'package:jobix/src/routing.dart';
import 'package:jobix/src/store/actions.dart';
import 'package:jobix/src/store/app_state.dart';
import 'package:jobix/src/widgets/employee/farm_dropdown.dart';
import 'package:redux/redux.dart';
import '../../constants.dart';

class EmployeeHomePanel extends StatefulWidget {
  const EmployeeHomePanel({
    Key? key,
  }) : super(key: key);

  @override
  State<EmployeeHomePanel> createState() => _EmployeeHomePanelState();
}

class _EmployeeHomePanelState extends State<EmployeeHomePanel> {
  String? _country = 'Todas';

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Gestión de Empleados",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StoreConnector<AppState, Function(String)>(
                converter: (Store<AppState> store) {
                  return (newValue) =>
                      store.dispatch(UpdateFarmAction(newValue));
                },
                builder: (context, updateString) {
                  return FarmDropdown(
                    farms: const [
                      'Todas',
                      'San Gonzalo',
                      'Paso Largo',
                      'Campo Rojo',
                      'Mene Mauroa',
                      'Barinesa',
                    ],
                    farm: _country,
                    onChanged: (val) => {updateString(val ?? "Todas")},
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: defaultPadding),
        Responsive(
          mobile: CardGridView(
            crossAxisCount: size.width < 650 ? 2 : 3,
            childAspectRatio: size.width < 650 ? 1.3 : 1,
          ),
          tablet: const CardGridView(),
          desktop: CardGridView(
            childAspectRatio: size.width < 1400 ? 1.1 : 1.4,
          ),
        ),
      ],
    );
  }
}

class CardGridView extends StatelessWidget {
  const CardGridView({
    Key? key,
    this.crossAxisCount = 5,
    this.childAspectRatio = 1,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: listEmployeePanel.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => EmployeePanelCard(
        info: listEmployeePanel[index],
      ),
    );
  }
}
