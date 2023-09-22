import 'package:flutter/material.dart';
import 'package:flutter_bookshop_crud/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DashboardState createState() => _DashboardState();
}

List<dynamic> booksData = [];
Map<String, dynamic> summaryData = {};

String getTitleAuthorById(List<dynamic> booksData, String id) {
  for (var book in booksData) {
    if (book["_id"] == id) {
      return '${book["title"]} | ${book["author"]}';
    }
  }
  return id;
}

class _DashboardState extends State<Dashboard> {
  Future<void> fetchBooks() async {
    var response;
    try {
      response = await http.get(
        Uri.parse(
          '$API_URL/get_data',
        ),
        headers: {"Access-Control-Allow-Origin": "*"},
      );
    } catch (e) {
      //print(e);
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

  Future<void> fetchSummary() async {
    var response;
    try {
      response = await http.get(
        Uri.parse(
          '$API_URL/get_summary',
        ),
        headers: {"Access-Control-Allow-Origin": "*"},
      );
    } catch (e) {
      //print(e);
    }

    if (response != null && response.statusCode == 200) {
      final Map<String, dynamic> newData = json.decode(response.body);
      //print(response.body);
      setState(() {
        summaryData = newData; // Append new data to the existing list
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSummary();
    fetchBooks();
  }

  @override
  void dispose() {
    booksData = [];
    summaryData = {};

    super.dispose();
  }

  Widget topCard(Color color, String title, String content) {
    return SizedBox(
      height: 90,
      child: Card(
        // Wrap the Card in a Stack to overlay the IconButton
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 3.0, color: color),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Text(
                    title,
                    softWrap: false,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Text(
                    content,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 30.0,
                    ),
                  ),
                ),
                // Positioned widget to place the IconButton at the top-left corner
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sideTableCard(sideTableWidth, String title, String firstColumn,
      int limit, sort, Map<String, dynamic>? content) {
    try {
      // Sort the data by value in descending order
      var sortedData;
      if (sort == 'asc') {
        sortedData = Map.fromEntries(content!.entries.toList()
          ..sort((a, b) => (b.value as int).compareTo(a.value as int)));
      } else {
        sortedData = Map.fromEntries(content!.entries.toList()
          ..sort((b, a) => (b.value as int).compareTo(a.value as int)));
      }

      // Get the top 3 entries
      final topData = sortedData.entries.take(limit).toList();

      List<DataColumn> columns = [];
      List<DataRow> rows = [];
      if (!title.contains('Books') && !title.contains('Stock')) {
        columns = [
          DataColumn(
              label: SizedBox(
                  width: sideTableWidth - 150, child: Text(firstColumn))),
          const DataColumn(label: SizedBox(width: 150, child: Text('Count'))),
        ];

        topData.forEach((entry) {
          rows.add(DataRow(cells: [
            DataCell(Text(entry.key)),
            DataCell(Text(entry.value.toString())),
          ]));
        });
      } else {
        columns = [
          DataColumn(
              label: SizedBox(
                  width: (sideTableWidth - 100) / 3,
                  child: const Text('Title'))),
          DataColumn(
              label: SizedBox(
                  width: (sideTableWidth - 100) / 3,
                  child: const Text('Author'))),
          const DataColumn(label: SizedBox(width: 100, child: Text('Count'))),
        ];

        topData.forEach((entry) {
          rows.add(DataRow(cells: [
            DataCell(
                Text(getTitleAuthorById(booksData, entry.key).split(' | ')[0])),
            DataCell(
                Text(getTitleAuthorById(booksData, entry.key).split(' | ')[1])),
            DataCell(Text(entry.value.toString())),
          ]));
        });
      }

      return Card(
        // Wrap the Card in a Stack to overlay the IconButton
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                softWrap: false,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: sideTableWidth,
              child: DataTable(
                columns: columns,
                rows: rows,
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return Text('Error $e');
    }
  }

  String getMonthShortName(String dateStr) {
    try {
      final date = DateFormat('yyyy-M').parse(dateStr);
      final monthShortName = DateFormat.MMM().format(date);
      String year = DateFormat('yy').format(date);
      return '$monthShortName-$year';
    } catch (e) {
      // Handle invalid input format
      return 'Invalid Date Format';
    }
  }

  Widget generateOrdersLineChart(
      // ignore: non_constant_identifier_names
      Map<String, dynamic>? ordersData,
      Map<String, dynamic>? bookCountData,
      Map<String, dynamic>? revenueData) {
    try {
      List<DataPoint> orderChartData = [];
      final orderSortedData = Map.fromEntries(
          ordersData!.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
      orderSortedData.forEach((key, value) {
        orderChartData.add(
            DataPoint(date: getMonthShortName(key.toString()), value: value));
      });

      List<DataPoint> bookCountChartData = [];
      final bookCountSortedData = Map.fromEntries(
          bookCountData!.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key)));
      bookCountSortedData.forEach((key, value) {
        bookCountChartData.add(
            DataPoint(date: getMonthShortName(key.toString()), value: value));
      });

      List<DataPoint> revenueChartData = [];
      final revenueSortedData = Map.fromEntries(revenueData!.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)));
      revenueSortedData.forEach((key, value) {
        revenueChartData.add(
            DataPoint(date: getMonthShortName(key.toString()), value: value));
      });

      return Card(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Monthly Statistics (Orders Count | Books Sold Count | Revenue)',
                softWrap: false,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SfCartesianChart(
                legend: const Legend(isVisible: true),
                tooltipBehavior: TooltipBehavior(enable: true),
                primaryXAxis: CategoryAxis(
                  plotBands: <PlotBand>[
                    PlotBand(
                      isVisible: true,
                      color: background,
                      borderWidth: 1,
                      borderColor: foreground,
                    )
                  ],
                  title: AxisTitle(
                      textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(
                      textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
                ),
                series: <ChartSeries<DataPoint, String>>[
                  LineSeries<DataPoint, String>(
                    enableTooltip: true,
                    legendIconType: LegendIconType.diamond,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    dataSource: orderChartData,
                    xValueMapper: (DataPoint data, _) => data.date,
                    yValueMapper: (DataPoint data, _) => data.value,
                    name: 'Orders',
                    color: pink,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<DataPoint, String>(
                    enableTooltip: true,
                    legendIconType: LegendIconType.diamond,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    dataSource: bookCountChartData,
                    xValueMapper: (DataPoint data, _) => data.date,
                    yValueMapper: (DataPoint data, _) => data.value,
                    name: 'Books',
                    color: cyan,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<DataPoint, String>(
                    enableTooltip: true,
                    legendIconType: LegendIconType.diamond,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    dataSource: revenueChartData,
                    xValueMapper: (DataPoint data, _) => data.date,
                    yValueMapper: (DataPoint data, _) => data.value,
                    name: 'Money',
                    color: green,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return Text('Error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final sideTableWidth = screenWidth / 4;
    final sideTableHeight = screenHeight - 150;
    final graphWidth = screenWidth - sideTableWidth - 85;
    final graphHeight = screenHeight - 150;
    final total_revenue = summaryData['total_revenue'] ?? 0;
    final average_order_value = summaryData['average_order_value'] ?? 0;
    final customer_retention_rate = summaryData['customer_retention_rate'] ?? 0;

    return Scaffold(
      body: summaryData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      flex: 1,
                      child: topCard(pink, 'Total Orders',
                          summaryData['total_orders'].toString()),
                    ),
                    Expanded(
                      flex: 1,
                      child: topCard(green, 'Total Revenue',
                          '${total_revenue.toStringAsFixed(3)} OMR'),
                    ),
                    Expanded(
                      flex: 1,
                      child: topCard(cyan, 'Sold Books',
                          summaryData['sold_books'].toString()),
                    ),
                    Expanded(
                      flex: 1,
                      child: topCard(orange, 'Average Order Value',
                          '${average_order_value.toStringAsFixed(3)} OMR'),
                    ),
                    Expanded(
                      flex: 1,
                      child: topCard(yellow, 'Retention Rate',
                          customer_retention_rate.toStringAsFixed(3)),
                    ),
                    Expanded(
                      flex: 1,
                      child: topCard(pink, 'Books In Stock',
                          '${summaryData['unique_books_in_stock']} | ${summaryData['total_books_in_stock']}'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: sideTableWidth,
                      height: sideTableHeight,
                      child: SingleChildScrollView(
                        child: Wrap(
                          children: [
                            SizedBox(
                              width: sideTableWidth,
                              child: sideTableCard(
                                  sideTableWidth,
                                  'Top Selling Books',
                                  'Book',
                                  3,
                                  'asc',
                                  summaryData['top_selling_books']),
                            ),
                            SizedBox(
                              width: sideTableWidth,
                              child: sideTableCard(
                                  sideTableWidth,
                                  'Sales By Genre',
                                  'Genre',
                                  3,
                                  'asc',
                                  summaryData['sales_by_genre']),
                            ),
                            SizedBox(
                              width: sideTableWidth,
                              child: sideTableCard(
                                  sideTableWidth,
                                  'Top Order Locations',
                                  'Location',
                                  3,
                                  'asc',
                                  summaryData['customer_locations']),
                            ),
                            SizedBox(
                              width: sideTableWidth,
                              child: sideTableCard(
                                  sideTableWidth,
                                  'Most Frequent Customers',
                                  'Customer',
                                  3,
                                  'asc',
                                  summaryData['most_frequent_customers']),
                            ),
                            SizedBox(
                              width: sideTableWidth,
                              child: sideTableCard(
                                  sideTableWidth,
                                  'Stock',
                                  'Book',
                                  10,
                                  'desc',
                                  summaryData['inventory_management']),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: graphWidth,
                      height: graphHeight,
                      child: Column(
                        children: [
                          SizedBox(
                            width: graphWidth,
                            height: graphHeight,
                            child: generateOrdersLineChart(
                                summaryData['monthly_orders'],
                                summaryData['monthly_sold_books'],
                                summaryData['monthly_revenue']),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class DataPoint {
  DataPoint({required this.date, required this.value});

  final String date;
  final dynamic value;
}
