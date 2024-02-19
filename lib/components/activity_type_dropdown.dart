import 'package:flutter/material.dart';
import 'package:kitajomvendor/utils/colors.dart';

class ActivityTypeDropdown extends StatefulWidget {
  final Function(String)? onChanged;
  const ActivityTypeDropdown({Key? key, this.onChanged}) : super(key: key);

  @override
  _ActivityTypeDropdownState createState() => _ActivityTypeDropdownState();
}

class _ActivityTypeDropdownState extends State<ActivityTypeDropdown> {
  String? _selectedActivityType;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedActivityType,
      style: TextStyle(color: darkGreen),
      icon: Icon(
        Icons.arrow_drop_down,
        color: darkGreen,
      ),
      decoration: InputDecoration(
        labelText: 'Activity Type',
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
          value: 'attraction',
          child: Text("Attraction"),
        ),
        DropdownMenuItem(
          value: 'themepark',
          child: Text("Theme Park"),
        ),
        DropdownMenuItem(
          value: "workshop",
          child: Text("Workshop"),
        ),
        DropdownMenuItem(
          value: 'activity',
          child: Text("Activity"),
        ),
      ],
      onChanged: (value) {
        setState(
          () {
            _selectedActivityType = value;
            if (widget.onChanged != null) {
              widget.onChanged!(value!);
            }
          },
        );
      },
    );
  }
}
