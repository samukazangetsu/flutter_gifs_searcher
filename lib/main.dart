import 'package:flutter/material.dart';

// Da o import no arquivo home_page.dart dentro da pasta UI
import 'package:gifs_searcher/UI/home_page.dart';

import 'package:gifs_searcher/UI/gif_page.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
    theme: ThemeData(
        hintColor: Colors.white,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            hintStyle: TextStyle(color: Colors.white))),
  ));
}
