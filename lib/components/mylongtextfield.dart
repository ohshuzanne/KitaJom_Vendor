import 'package:flutter/material.dart';
import 'package:kitajomvendor/utils/colors.dart';

class MyLongTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const MyLongTextField({
    Key? key,
    required this.controller,
    required this.hintText,
  }) : super(key: key);

  @override
  _MyLongTextFieldState createState() => _MyLongTextFieldState();
}

class _MyLongTextFieldState extends State<MyLongTextField> {
  bool _isFilled = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        height: 80, // Adjust the height as needed
        child: TextFormField(
          controller: widget.controller,
          maxLines: null, // Allow multiple lines
          keyboardType: TextInputType.multiline, // Enable multiline keyboard
          onChanged: (value) {
            setState(() {
              _isFilled = value.isNotEmpty;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Field is required';
            }
            return null;
          },
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: darkGreen),
              borderRadius: BorderRadius.circular(20.0),
            ),
            fillColor: Colors.grey[200],
            filled: true,
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            labelText: _isFilled ? null : '*Field is required',
            labelStyle: TextStyle(
              color: darkGreen.withOpacity(0.5),
              fontSize: 14,
              fontFamily: 'Lexend',
            ),
          ),
        ),
      ),
    );
  }
}
