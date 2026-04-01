import 'package:flutter/material.dart';

//This function recieves the amount of effort the user
//has entered on their drawing entry and then to account for the possibility
//that the string entered (if any) has any capital letters the case is swapped
//to lower so all characters have the same case to match the strings of the 
//test statments for each case

//It then asigns a color to each case (default if nothing was given, high effort
// medium effort, or low effort)
//In this context effort means how much the user thought they tried on making
//the drawing
Color getEffortColor(String effort) {
  switch (effort.toLowerCase()) { 
    case 'high':
      return Colors.redAccent;
    case 'medium':
      return Colors.orangeAccent;
    case 'low':
      return Colors.greenAccent;
    default:
      return Colors.blueAccent;
  }
}
