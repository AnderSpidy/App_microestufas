import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String title;
  final List<Map<String, String>> data;

  const DetailScreen({
    Key? key,
    required this.title,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(data[index]['time']!),
            subtitle: Text(data[index]['value']!),
          );
        },
      ),
    );
  }
}
