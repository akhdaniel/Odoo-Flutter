import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'data.dart';

class Many2OneField extends StatelessWidget {

  const Many2OneField({
    Key? key,
    required this.object,
    required this.value,
    required this.controller,
    required this.hint,
    required this.label,
    required this.icon,
    required this.onSelect,
  }) : super(key: key);

  final TextEditingController controller;
  final String object;
  final String label;
  final String hint;
  final IconData icon;
  final List value;
  final Function onSelect;

  @override
  Widget build(BuildContext context) {
    controller.text = (value.isNotEmpty) ? value[1] : '';
    return TypeAheadField(
      textFieldConfiguration: TextFieldConfiguration(
        // autofocus: true,
        controller: controller,
        decoration: InputDecoration(
            icon: Icon(icon),  
            labelText: label,  
            hintText: hint),
      ),
      suggestionsCallback: (pattern) async {
        return await BackendService.getMasterData(object,pattern);
      },
      itemBuilder: (context, Map<String, String> master) {
        return ListTile(
          // leading: Icon(Icons.air_sharp),
          title: Text(master['name']!),
          subtitle: Text('${master['id']}'),
        );
      },
      onSuggestionSelected: (Map<String, String> master) {
        // controller.text = "${master['name']}";
        onSelect(master);
      },
    );
  }
}

class AmountField extends StatelessWidget {
  const AmountField({
    Key? key,
    required this.currency_id,
    required this.value,
    required this.hint,
  }) : super(key: key);

  final List currency_id;
  final double value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(  
      initialValue: "${currency_id[1]} $value",
      readOnly: true,
      decoration: const InputDecoration(  
        icon: Icon(Icons.money_rounded),  
        // hintText: hint,  
        labelText: 'Total',  
      ),   
    );
  }
}
