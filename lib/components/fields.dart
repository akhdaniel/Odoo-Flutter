import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';

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
    required this.fields,
    // required this.subTitleField,
  }) : super(key: key);

  final TextEditingController controller;
  final String object;
  final String label;
  final String hint;
  final IconData icon;
  final List value;
  final List fields;
  final Function onSelect;
  // final String subTitleField;

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
        return await BackendService.getMasterData(object,fields,pattern);
      },
      itemBuilder: (context, Map<String, String> master) {
        // var subtitle = master[subTitleField];
        return ListTile(
          // leading: Icon(Icons.air_sharp),
          title: Text(master['name']!),
          // subtitle: (subTitleField=='' ? const Text(''): Text(subtitle??'')),
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


class DateField extends StatelessWidget {
  DateField({
    Key? key,
    required this.initialValue,
    required this.controller,
    required this.onSelect,
  }) : super(key: key);

  String initialValue;
  TextEditingController controller;
  Function onSelect;

  @override
  Widget build(BuildContext context) {
    controller.text = initialValue;

    return TextFormField(  
      readOnly: true,
      controller: controller,
      decoration: const InputDecoration(  
        icon:  Icon(Icons.calendar_today),  
        hintText: 'Enter date order',  
        labelText: 'Order Date',  
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.parse(initialValue),
            firstDate: DateTime(1950),
            lastDate: DateTime(2100)
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(pickedDate);
          controller.text = formattedDate;
          onSelect(formattedDate);
        } else {
          print('cancel date select');
        }
      },
    );
  }
}
