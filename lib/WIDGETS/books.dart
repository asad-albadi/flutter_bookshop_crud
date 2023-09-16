import 'dart:js';

import 'package:flutter/material.dart';
import 'package:flutter_bookshop_crud/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class Books extends StatefulWidget {
  const Books({super.key});

  @override
  _BooksState createState() => _BooksState();
}

bool _isLoading = false;
List<dynamic> booksData = []; // State variable to store fetched data

class _BooksState extends State<Books> {
  String selectedGenre = "All"; // Initialize with an empty string.
  String searchParameter = ""; // Initialize with an empty string.

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  String created_book_id = '';
  Future<String> createBook(data) async {
    String created_id = 'N/A';
    var response = await http.post(
      Uri.parse(API_URL + '/create_book'),
      headers: {
        "Access-Control-Allow-Origin": "*"
      }, // Replace with your actual API URL
      body: {
        'book_data': json.encode(data),
      },
    );

    if (response.statusCode == 200) {
      created_id = response.body;
      print('Book created successfully');
    } else {
      // Request failed
      print('Failed to create book. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
    return created_id;
  }

  Future<void> fetchData() async {
    booksData.clear();
    setState(() {
      _isLoading = true;
    });
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
    setState(() {
      _isLoading = false;
    });
  }

  List<dynamic> filterFull() {
    if (selectedGenre == 'All' && searchParameter.isEmpty) {
      return booksData.toList(); // Return a copy of the full list.
    }

    return booksData.where((book) {
      // Check if the book's genre matches the selected genre (if it's not "All").
      if (selectedGenre != 'All' && book["genre"] != selectedGenre) {
        return false;
      }

      // Check if the book's title or author contains the search query.
      final title = book["title"].toString().toLowerCase();
      final author = book["author"].toString().toLowerCase();
      final query = searchParameter.toLowerCase();

      return title.contains(query) || author.contains(query);
    }).toList();
  }

  void showNewBookDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController authorController = TextEditingController();
    final TextEditingController genreController = TextEditingController();
    final TextEditingController coverController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController countController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter New Book'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: authorController,
                      decoration: const InputDecoration(labelText: 'Author'),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: genreController,
                      decoration: const InputDecoration(labelText: 'Genre'),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: coverController,
                      decoration:
                          const InputDecoration(labelText: 'Cover(Link)'),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: countController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var newOrder = {
                  'title': titleController.text,
                  'author': authorController.text,
                  'genre': genreController.text.toString().split(','),
                  'cover': coverController.text,
                  'price': priceController.text,
                  'count': countController.text,
                };
                var response = await createBook(newOrder);

                setState(() {
                  created_book_id = response;
                  fetchData();
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: purple,
          onPressed: () async {
            showNewBookDialog(context);
            /*
          
          */
          },
          child: const Icon(
            Icons.add,
            color: background,
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: (value) {
                              // Update the searchText variable when the user types in the search field.
                              setState(() {
                                searchParameter = value;
                                print(value);
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Search by Title or Author',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField<String>(
                            value: selectedGenre,
                            onChanged: (value) {
                              // Update the selectedGenre variable when the user selects a genre.
                              setState(() {
                                selectedGenre = value!;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Filter by Genre',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              'All',
                              'قصص',
                              'فلسفة',
                              'مجتمع',
                              'نصوص',
                              'رواية',
                              'تطوير الذات',
                              'روايات مترجمة',
                              'صحة',
                              'إدارة أعمال',
                              'فكر',
                              'تربية',
                              'علم نفس',
                              'تاريخ',
                              'رحلات'
                            ] // Replace with your genre options.
                                .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: Column(
                          children: [
                            Wrap(
                              spacing:
                                  10.0, // Adjust the spacing between cards as needed
                              runSpacing:
                                  10.0, // Adjust the spacing between rows as needed
                              children: filterFull().map((book) {
                                return BookCard(book);
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ));
  }
}

class BookCard extends StatefulWidget {
  final Map<String, dynamic> bookData;

  const BookCard(this.bookData, {Key? key}) : super(key: key);

  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  String modifiedBook = '';
  Future<String> modifyBook(data) async {
    String modifiedBook = 'N/A';
    var response = await http.post(
      Uri.parse(API_URL + '/modify_book'),
      headers: {
        "Access-Control-Allow-Origin": "*"
      }, // Replace with your actual API URL
      body: {
        'book_data': json.encode(data),
      },
    );

    if (response.statusCode == 200) {
      modifiedBook = response.body;
      print('Book created successfully');
    } else {
      // Request failed
      print('Failed to create book. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
    return modifiedBook;
  }

  void showModifyBookDialog(
      BuildContext context, id, title, author, genre, cover, price, count) {
    final TextEditingController titleController =
        TextEditingController(text: title);
    final TextEditingController authorController =
        TextEditingController(text: author);
    final TextEditingController genreController =
        TextEditingController(text: genre);
    final TextEditingController coverController =
        TextEditingController(text: cover);
    final TextEditingController priceController =
        TextEditingController(text: price);
    final TextEditingController countController =
        TextEditingController(text: count);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modify $id'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: authorController,
                      decoration: const InputDecoration(labelText: 'Author'),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: genreController,
                      decoration: const InputDecoration(labelText: 'Genre'),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: coverController,
                      decoration:
                          const InputDecoration(labelText: 'Cover(Link)'),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: countController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var modifiedBook = {
                  '_id': id,
                  'title': titleController.text,
                  'author': authorController.text,
                  'genre': genreController.text,
                  'cover': coverController.text,
                  'price': double.parse(priceController.text),
                  'count': int.parse(countController.text),
                };
                modifyBook(modifiedBook);
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
    Widget myCard() {
      return Card(
        // Wrap the Card in a Stack to overlay the IconButton
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 150.0,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: widget.bookData['cover'] ??
                        'https://example.com/default_image.jpg',
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, size: 100.0, color: Colors.red),
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.bookData['title'],
                        softWrap: false,
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SelectableText(
                        widget.bookData['author'],
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 16.0,
                        ),
                      ),
                      SelectableText(
                        '${widget.bookData['genre']}',
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan,
                        ),
                      ),
                      Text(
                        'OMR ${widget.bookData['price']} | ${widget.bookData['count']} pc(s)',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Positioned widget to place the IconButton at the top-left corner
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.zero,
                    color: Colors.purple.withOpacity(0.5)),
                child: IconButton(
                  color:
                      Colors.white, // Change 'background' to the desired color
                  icon: const Icon(
                      Icons.edit), // Replace 'your_icon' with the desired icon
                  onPressed: () {
                    showModifyBookDialog(
                        context,
                        widget.bookData['_id'].toString(),
                        widget.bookData['title'].toString(),
                        widget.bookData['author'].toString(),
                        widget.bookData['genre'].toString(),
                        widget.bookData['cover'].toString(),
                        widget.bookData['price'].toString(),
                        widget.bookData['count'].toString());
                    // Add your onPressed logic here
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    int count = widget.bookData['count'];

    Widget fullCard() {
      return SizedBox(
        width: 200.0, // Set the width of the card
        height: 300.0, // Set the height of the card
        child: count == 0
            ? Banner(
                message: "Out Of Stock",
                location: BannerLocation.topEnd,
                color: Colors.red, // Change 'red' to the desired color
                child: myCard(),
              )
            : myCard(),
      );
    }

    return fullCard();
  }
}
