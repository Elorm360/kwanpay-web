import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordTextField({
    super.key,
    required this.controller,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {

  bool obscure = true;

  @override
  Widget build(BuildContext context) {

    return TextField(

      controller: widget.controller,

      obscureText: obscure,

      decoration: InputDecoration(

        labelText: "Password",

        prefixIcon: const Icon(Icons.lock_outline),

        suffixIcon: IconButton(

          onPressed: () {

            setState(() {

              obscure = !obscure;

            });

          },

          icon: Icon(

            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,

          ),

        ),

        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(16),

        ),

      ),

    );

  }

}