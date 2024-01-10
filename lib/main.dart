import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:js' as js;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search App',
      home: SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _searchResults = [];

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse(
          'https://wordshk.ap-southeast-1.elasticbeanstalk.com/search?query=${_searchController.text}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _searchResults =
            json.decode(const Utf8Decoder().convert(response.bodyBytes));
        _isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Semantic Search for words.hk'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search any English words or phrases',
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                ),
                        ),
                        onSubmitted: (_) {
                          debugPrint("submitted!");
                          _performSearch();
                        },
                        onChanged: (value) {
                          // Add setState to rebuild the widget with the clear button when there's text
                          setState(() {});
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _performSearch,
                    ),
                  ],
                ),
              ),
              _isLoading
                  ? CircularProgressIndicator()
                  : Expanded(
                      child: SelectionArea(
                        child: ListView.separated(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            return ListTile(
                                leading: Text(result['variant'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!),
                                title: Text(result['eng']),
                                onTap: () {
                                  js.context.callMethod('open', [
                                    'https://words.hk/zidin/${result['variant']}#w${result['entry_id']}'
                                  ]);
                                });
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
