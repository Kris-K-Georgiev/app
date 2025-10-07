import 'package:flutter/material.dart';

class CityDropdown extends StatelessWidget {
  final String? value;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  const CityDropdown({super.key, this.value, this.onChanged, this.validator});

  static const List<String> cities = [
    'София','Пловдив','Варна','Бургас','Русе','Стара Загора','Плевен','Сливен','Добрич','Шумен'
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value?.isEmpty==true? null : value,
      items: cities.map((c)=>DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: const InputDecoration(labelText: 'Град *'),
    );
  }
}
