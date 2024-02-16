import 'package:flutter/material.dart';
import 'package:kitajomvendor/utils/colors.dart';

class PricePointDropDown extends StatefulWidget {
  final Function(String)? onChanged;
  const PricePointDropDown({Key? key, this.onChanged}) : super(key: key);

  @override
  _PricePointDropDownState createState() => _PricePointDropDownState();
}

class _PricePointDropDownState extends State<PricePointDropDown> {
  String? _selectedPricePoint;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedPricePoint,
      style: TextStyle(color: darkGreen),
      icon: Icon(Icons.arrow_drop_down, color: darkGreen),
      decoration: InputDecoration(
        labelText: "Price Point",
        labelStyle: TextStyle(color: darkGreen),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: darkGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: darkGreen),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      itemHeight: 50,
      items: [
        DropdownMenuItem(
          value: '\$',
          child: Text('\$'),
        ),
        DropdownMenuItem(
          value: '\$\$',
          child: Text('\$\$'),
        ),
        DropdownMenuItem(
          value: '\$\$\$',
          child: Text('\$\$\$'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedPricePoint = value;
          if (widget.onChanged != null) {
            widget.onChanged!(value!);
          }
        });
      },
    );
  }
}
