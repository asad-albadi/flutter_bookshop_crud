import 'package:flutter/material.dart';

import 'homepage.dart';

void main() {
  runApp(const MyApp());
}

// const Text('House Of Wisdom Bookshop')

const String title = 'House Of Wisdom Bookshop';
const Color background = Color(0xFF282a36);
const Color currentLine = Color(0xFF44475a);
const Color foreground = Color(0xFFF8F8F2);
const Color comment = Color(0xFF6272A4);
const Color cyan = Color(0xFF8BE9FD);
const Color green = Color(0xFF50FA7B);
const Color orange = Color(0xFFFFB86C);
const Color pink = Color(0xFFFF79C6);
const Color purple = Color(0xFFBD93F9);
const Color red = Color(0xFFFF5555);
const Color yellow = Color(0xFFF1FA8C);

// ignore: constant_identifier_names
const String API_URL = 'http://192.168.100.64:5000';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        dialogBackgroundColor: background,
        canvasColor: background,
        menuButtonTheme: MenuButtonThemeData(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(background))),
        dropdownMenuTheme: DropdownMenuThemeData(
            menuStyle: MenuStyle(
                backgroundColor: MaterialStateProperty.all(background))),
        cardTheme: const CardTheme(color: currentLine, elevation: 5),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: purple),
        navigationRailTheme: const NavigationRailThemeData(
          unselectedIconTheme: IconThemeData(color: comment),
          unselectedLabelTextStyle: TextStyle(color: comment),
          selectedIconTheme: IconThemeData(color: purple),
          selectedLabelTextStyle: TextStyle(color: purple),
          backgroundColor: background,
        ),
        appBarTheme:
            const AppBarTheme(backgroundColor: background, elevation: 0),
        // Define your custom DataTableTheme
        dataTableTheme: DataTableThemeData(
          dataRowColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                // Use the selectedRowColor for selected rows
                return background;
              }
              // Use the default background color for other rows
              return background;
            },
          ),
          dataTextStyle: const TextStyle(
            color: foreground,
          ),
          headingRowColor: MaterialStateProperty.all<Color>(currentLine),
          headingTextStyle: const TextStyle(
            color: foreground,
            fontWeight: FontWeight.bold,
          ),
          dividerThickness: 1.0,
        ),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        // backgroundColor: background,
        textSelectionTheme:
            const TextSelectionThemeData(cursorColor: foreground),
        /* textTheme: GoogleFonts.ubuntuMonoTextTheme(
          Theme.of(context).textTheme,
        ), */
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(background),
          backgroundColor:
              MaterialStateProperty.all(purple), // Button background color
          textStyle: MaterialStateProperty.all(const TextStyle(
            fontSize: 16,
          )), // Button text style
          padding: MaterialStateProperty.all(const EdgeInsets.all(16.0)),
        )), // Button padding
        // Add more properties as needed
        buttonTheme: ButtonThemeData(
          buttonColor: cyan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              color: cyan,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: green,
            ),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: orange,
          contentTextStyle: TextStyle(
            color: background,
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}
