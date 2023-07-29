import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobix/src/components/production_module_info.dart';
import 'package:jobix/src/routing.dart';

import '../constants.dart';

class ProductionCard extends StatelessWidget {
  const ProductionCard({
    Key? key,
    required this.info,
  }) : super(key: key);

  final ProductionModuleInfo info;

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);

    return TextButton(
      onPressed: () {
        routeState.go(info.linkScreen ?? "/home");
      },
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(defaultPadding * 0.75),
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: info.color!.withOpacity(0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: SvgPicture.asset(
                  info.svgSrc!,
                  colorFilter: ColorFilter.mode(
                      info.color ?? Colors.black, BlendMode.srcIn),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    info.title!,
                    style: const TextStyle(color: Colors.white),
                  )
                ],
              ),
            ]),
      ),
    );
  }
}
