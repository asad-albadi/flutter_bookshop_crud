import 'package:flutter/material.dart';
import 'package:flutter_bookshop_crud/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:motion_toast/motion_toast.dart';

import 'WIDGETS/books.dart';
import 'WIDGETS/dashboard.dart';
import 'WIDGETS/orders.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

bool _isExpanded = false; //NEW VARIABLE

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // Define a list of pages for each destination
  final List<Widget> _pages = [
    const Dashboard(),
    const Books(),
    const Orders(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        leading: IconButton(
          color: _isExpanded ? purple : foreground,
          icon: const Icon(FontAwesomeIcons.bookOpenReader),
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
      ),
      body: Row(
        children: <Widget>[
          NavigationRail(
            extended: _isExpanded,
            labelType: _isExpanded
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.book),
                selectedIcon: Icon(Icons.book),
                label: Text('Books'),
              ),
              NavigationRailDestination(
                icon: Icon(FontAwesomeIcons.cartShopping),
                selectedIcon: Icon(FontAwesomeIcons.cartShopping),
                label: Text('Orders'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 0),
          Expanded(
            child: _pages[_selectedIndex], // Show the selected page
          ),
        ],
      ),
    );
  }
}
