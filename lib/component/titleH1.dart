import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Titleh1 extends StatelessWidget {
  final String title;
  final bool astrick;
  const Titleh1({super.key,
  required this.title,
  this.astrick = false,});

  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        ),
        if(astrick)Text("*",
        style: TextStyle(
          backgroundColor: Colors.red,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        ),
      ],
    );
  }
}
