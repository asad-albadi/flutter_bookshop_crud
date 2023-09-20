import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bookshop_crud/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OrdersState createState() => _OrdersState();
}

List<dynamic> booksData = []; // State variable to store fetched data
dynamic selectedBook;

String getCoverById(List<dynamic> booksData, String id) {
  for (var book in booksData) {
    if (book["_id"] == id) {
      return book["cover"];
    }
  }
  // If the book with the given _id is not found, you can return a default value or throw an exception.
  return 'https://example.com/default_image.jpg'; // Or you can throw an exception here to indicate that the book was not found.
}

String getTitleAuthorById(List<dynamic> booksData, String id) {
  for (var book in booksData) {
    if (book["_id"] == id) {
      return '${book["title"]} | ${book["author"]}';
    }
  }
  // If the book with the given _id is not found, you can return a default value or throw an exception.
  return 'Unknown | Unknown}'; // Or you can throw an exception here to indicate that the book was not found.
}

class _OrdersState extends State<Orders> {
  // You can define your internal state variables here.
  String created_order_id = '';
  List<dynamic> orderData = [];

  Future<String> createOrder(data) async {
    String created_id = 'N/A';
    var response = await http.post(
      Uri.parse(API_URL + '/create_order'),
      headers: {
        "Access-Control-Allow-Origin": "*"
      }, // Replace with your actual API URL
      body: {
        'order_data': json.encode(data),
      },
    );

    if (response.statusCode == 200) {
      created_id = response.body;
      print('Order created successfully');
    } else {
      // Request failed
      print('Failed to create order. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
    return created_id;
  }

  @override
  void initState() {
    super.initState();
    fetchBooks();
    fetchOrders();
  }

  @override
  void dispose() {
    booksData = [];
    selectedBook = null;

    super.dispose();
  }

  Future<void> fetchOrders() async {
    var response;
    orderData.clear();
    try {
      response = await http.get(
        Uri.parse(
          API_URL + '/get_orders',
        ),
        headers: {"Access-Control-Allow-Origin": "*"},
      );
    } catch (e) {
      print(e);
    }

    if (response != null && response.statusCode == 200) {
      final List<dynamic> newData = json.decode(response.body);
      setState(() {
        orderData.addAll(newData); // Append new data to the existing list
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchBooks() async {
    var response;
    try {
      response = await http.get(
        Uri.parse(
          API_URL + '/get_data',
        ),
        headers: {"Access-Control-Allow-Origin": "*"},
      );
    } catch (e) {
      print(e);
    }

    if (response != null && response.statusCode == 200) {
      final List<dynamic> newData = json.decode(response.body);
      setState(() {
        booksData.addAll(newData); // Append new data to the existing list
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  double getPriceById(List<dynamic> booksData, String id) {
    for (var book in booksData) {
      if (book["_id"] == id) {
        return book["price"];
      }
    }
    // If the book with the given _id is not found, you can return a default value or throw an exception.
    return -1; // Or you can throw an exception here to indicate that the book was not found.
  }

  String itemsText = ''; // Initialize it as an empty string
  void showOrderDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController deliveryFeeController = TextEditingController();
    final TextEditingController discountController = TextEditingController();
    final TextEditingController quantityController =
        TextEditingController(text: '1');
    final List<Map<String, dynamic>> items = [];
    String itemsText = ''; // Initialize it as an empty string
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter New Order'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: deliveryFeeController,
                      decoration:
                          const InputDecoration(labelText: 'Delivery Fee'),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: discountController,
                      decoration: const InputDecoration(labelText: 'Discount'),
                    ),
                    const SizedBox(height: 8),
                    const Text('Items:'),
                    Column(
                      children: [
                        const MyDropdownMenu(),
                        const SizedBox(
                          height: 8,
                        ),
                        TextField(
                          controller: quantityController,
                          decoration:
                              const InputDecoration(labelText: 'Quantity'),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    if (items.length < 5)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            items.add({
                              'item_id': selectedBook,
                              'price': getPriceById(booksData, selectedBook),
                              'quantity': int.parse(quantityController.text),
                            });

                            // Update the itemsText with the new item added
                            itemsText = items.map((item) {
                              return 'Item ID: ${item['item_id']}, Price: ${item['price']}, Quantity: ${item['quantity']}';
                            }).join('\n'); // Join the items with line breaks
                          });
                        },
                        child: const Text('Add Item'),
                      ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(itemsText),
                  ],
                ),
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var newOrder = {
                  'name': nameController.text,
                  'address': addressController.text,
                  'phone': phoneController.text,
                  'items': items,
                  'delivery_fee': deliveryFeeController.text,
                  'discount': discountController.text
                };
                var response = await createOrder(newOrder);

                setState(() {
                  created_order_id = response;
                  fetchOrders();
                });
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context)
            .size
            .width, // Set the width to the screen width
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 10.0, // Adjust the spacing between cards as needed
            runSpacing: 10.0, // Adjust the spacing between rows as needed
            children: orderData.map((order) {
              return OrderCard(order);
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: purple,
        onPressed: () async {
          showOrderDialog(context);
          /*
        
        */
        },
        child: const Icon(
          Icons.add,
          color: background,
        ),
      ),
    );
  }
}

class MyDropdownMenu extends StatefulWidget {
  const MyDropdownMenu({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyDropdownMenuState createState() => _MyDropdownMenuState();
}

class _MyDropdownMenuState extends State<MyDropdownMenu> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButtonFormField<dynamic>(
        decoration: const InputDecoration(
          labelText: 'Choose a Book to add',
          border: OutlineInputBorder(),
        ),
        value: selectedBook,
        onChanged: (dynamic newValue) {
          setState(() {
            selectedBook = newValue;
          });
        },
        items: booksData.map<DropdownMenuItem<dynamic>>((dynamic value) {
          return DropdownMenuItem<dynamic>(
            value: value['_id'],
            child: Text(
                '${value['title']} | ${value['author']} | ${value['price']} '),
          );
        }).toList(),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderCard(this.orderData, {super.key});

  @override
  Widget build(BuildContext context) {
    var itemsList = orderData['items'];

    return Card(
      elevation: 5, // Add a shadow to the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // Rounded corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order ID:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  orderData['_id'],
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 10.0), // Add some spacing
                const Text(
                  'Customer Name:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  orderData['name'],
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Delivery Address:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  orderData['address'],
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Contact Number:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  orderData['phone'],
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0, 0, 0),
            child: Text(
              'Order Items:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          DynamicDataTable(itemsList: itemsList),
        ],
      ),
    );
  }
}

class DynamicDataTable extends StatelessWidget {
  final List<dynamic> itemsList;

  const DynamicDataTable({super.key, required this.itemsList});
  @override
  Widget build(BuildContext context) {
    List<DataColumn> columns = [
      const DataColumn(label: Text('Item')),
      const DataColumn(label: Text('Price(OMR)')),
      const DataColumn(label: Text('Quantity')),
    ];

    double totalPrice = 0.0;
    int totalQuantity = 0;

    List<DataRow> rows = itemsList.map((item) {
      double price = item["price"];
      int quantity = item["quantity"];

      totalPrice += price * quantity;
      totalQuantity += quantity;

      return DataRow(cells: [
        DataCell(Text(getTitleAuthorById(booksData, item["item_id"]))),
        DataCell(Text(price.toString())),
        DataCell(Text(quantity.toString())),
      ]);
    }).toList();

    // Create a final DataRow for totals with a different color
    DataRow totalRow = DataRow(
      cells: [
        const DataCell(Text('Total', style: TextStyle(color: foreground))),
        DataCell(Text(
          totalPrice.toString(),
          style: const TextStyle(color: foreground),
        )),
        DataCell(Text(
          totalQuantity.toString(),
          style: const TextStyle(color: foreground),
        )),
      ],
      color: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            // Apply a different color when selected
            return cyan;
          }
          // Apply a different color for the normal state (not selected)
          return currentLine;
        },
      ),
    );

    rows.add(totalRow);

    return Column(
      children: [
        DataTable(columns: columns, rows: rows),
      ],
    );
  }
}
