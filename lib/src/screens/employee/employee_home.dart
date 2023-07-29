import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jobix/src/components/employees/employee_home_panel.dart';
import 'package:jobix/src/constants.dart';
import 'package:jobix/src/store/app_state.dart';
import 'package:jobix/src/widgets/header_widget.dart';
import 'package:redux/redux.dart';
import '../../responsive.dart';

class EmployeeHome extends StatelessWidget {
  const EmployeeHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        child: Column(
          children: [
            const SizedBox(
              height: 100,
              child: HeaderWidget(100, false, Icons.house_rounded),
            ),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      EmployeeHomePanel(),
                      SizedBox(height: defaultPadding),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  const SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we don't want to show it
              ],
            ),
            StoreConnector<AppState, String>(
              converter: (Store<AppState> store) => store.state.farm,
              builder: (context, stringValue) {
                return Text('Value: $stringValue');
              },
            )
          ],
        ),
      ),
    );
  }
}
