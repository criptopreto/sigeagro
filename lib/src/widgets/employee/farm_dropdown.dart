import 'package:flutter/material.dart';

class FarmDropdown extends StatelessWidget {
  final List<String> farms;
  final String? farm;
  final void Function(String?) onChanged;

  const FarmDropdown({
    required this.farms,
    required this.farm,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      height: 40.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: farm,
          items: farms
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 12.0,
                          child: Image.asset(
                            'assets/images/logo.png',
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          e,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
