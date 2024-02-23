import 'package:flutter/material.dart';
import 'package:kitajomvendor/utils/colors.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  }) : super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _isFilled = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        height: 50,
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
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

class MyUpdateTextField extends StatefulWidget {
  final TextEditingController controller;

  const MyUpdateTextField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  _MyUpdateTextFieldState createState() => _MyUpdateTextFieldState();
}

class _MyUpdateTextFieldState extends State<MyUpdateTextField> {
  bool _isFilled = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        height: 50,
        child: TextFormField(
          controller: widget.controller,
          onChanged: (value) {
            setState(() {
              _isFilled = value.isNotEmpty;
            });
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
