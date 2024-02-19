import 'package:flutter/material.dart';
import 'package:kitajomvendor/utils/colors.dart';

class AccommodationTypeDropdown extends StatefulWidget {
  final Function(String)? onChanged;
  const AccommodationTypeDropdown({
    Key? key,
    this.onChanged,
  }) : super(key: key);

  @override
  _AccommodationTypeDropdownState createState() =>
      _AccommodationTypeDropdownState();
}

class _AccommodationTypeDropdownState extends State<AccommodationTypeDropdown> {
  String? _selectedAccommodationType;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedAccommodationType,
      style: const TextStyle(color: darkGreen),
      icon: const Icon(
        Icons.arrow_drop_down,
        color: darkGreen,
      ),
      decoration: InputDecoration(
        labelText: 'Accommodation Type',
        labelStyle: TextStyle(color: darkGreen),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(
            color: darkGreen,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(
            color: Colors.grey[200]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(
            color: darkGreen,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      itemHeight: 50,
      items: [
        DropdownMenuItem(
          value: 'airbnb',
          child: Text("AirBnB"),
        ),
        DropdownMenuItem(
          value: 'hotel',
          child: Text("Hotel"),
        ),
      ],
      onChanged: (value) {
        setState(
          () {
            _selectedAccommodationType = value;
            if (widget.onChanged != null) {
              widget.onChanged!(value!);
            }
          },
        );
      },
    );
  }
}
