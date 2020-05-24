import 'package:flutter/material.dart';
import 'package:mobile_scolendar/api_exception.dart';

const PER_PAGE = 10;

class AutoCompleteField extends StatefulWidget {
  final bool enabled;
  final String title;
  final Future<List> Function(String query, int page) loadItems;
  final Widget Function(
      BuildContext context, dynamic item, GestureTapCallback onTap) itemBuilder;
  final String initialLabel;
  final Function(dynamic selectedItem) onChange;
  final String Function(dynamic selectedItem) getLabel;
  final String validationMessage;
  final bool allowEmpty;

  const AutoCompleteField({
    Key key,
    @required this.enabled,
    @required this.title,
    @required this.loadItems,
    @required this.itemBuilder,
    this.initialLabel,
    @required this.onChange,
    @required this.getLabel,
    @required this.validationMessage,
    this.allowEmpty = false,
  }) : super(key: key);

  @override
  _AutoCompleteFieldState createState() =>
      _AutoCompleteFieldState(initialLabel);
}

class _AutoCompleteFieldState extends State<AutoCompleteField> {
  final controller;
  bool oneSelected = false;

  _AutoCompleteFieldState(initialLabel)
      : controller = TextEditingController(text: initialLabel);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      readOnly: true,
      controller: controller,
      decoration: InputDecoration(
        labelText: widget.title,
      ),
      validator: (value) {
        if (oneSelected || widget.allowEmpty) return null;
        return widget.validationMessage;
      },
      onTap: () async {
        final result = await showSearch(
            context: context,
            delegate: AutoCompleteSearchDelegate(
              loadItems: widget.loadItems,
              itemBuilder: widget.itemBuilder,
            ));

        if (result != null) {
          oneSelected = true;
          controller.text = widget.getLabel(result);
          widget.onChange(result);
        }
      },
    );
  }
}

class AutoCompleteSearchDelegate extends SearchDelegate {
  final Future<List> Function(String query, int page) loadItems;
  final Widget Function(
      BuildContext context, dynamic item, GestureTapCallback onTap) itemBuilder;

  AutoCompleteSearchDelegate({
    @required this.loadItems,
    @required this.itemBuilder,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  bool get shouldSearch => query.length >= 3;

  @override
  Widget buildResults(BuildContext context) {
    return Results(
      query: query,
      loadItems: loadItems,
      itemBuilder: itemBuilder,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (!shouldSearch)
      return Results(
        query: null,
        loadItems: loadItems,
        itemBuilder: itemBuilder,
      );

    return Container();
  }
}

class Results extends StatefulWidget {
  final String query;

  final Future<List> Function(String query, int page) loadItems;
  final Widget Function(
      BuildContext context, dynamic item, GestureTapCallback onTap) itemBuilder;

  const Results({
    Key key,
    @required this.query,
    @required this.loadItems,
    @required this.itemBuilder,
  }) : super(key: key);

  @override
  _ResultsState createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  Future<void> responseFuture;
  ScrollController scrollController = ScrollController(
    keepScrollOffset: false,
  );
  bool isLoading = false;
  int page = 1;
  List data = [];
  bool end = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  bool get isAtEnd => (scrollController == null)
      ? true
      : scrollController.offset == scrollController.position.maxScrollExtent;

  _ResultsState() {
    scrollController.addListener(() {
      if (isAtEnd) {
        loadNextPage();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      this._refreshIndicatorKey.currentState.show();
    });
    //responseFuture = loadTeachers();
  }

  loadNextPage() async {
    if (isLoading || end) return;
    isLoading = true;
    page += 1;
    loadData();
  }

  Future<void> loadData() async {
    List results = await widget.loadItems(widget.query, page);

    setState(() {
      isLoading = false;
      if (results.length < PER_PAGE) end = true;
      data.addAll(results);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: responseFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          var msg = getErrorMessageFromException(snapshot.error);

          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                msg,
                style: TextStyle(color: Theme.of(context).errorColor),
              ),
            ),
          );
        }

        return _buildList(context);
      },
    );
  }

  Widget _buildList(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () async {
        data.clear();
        page = 1;
        end = false;
        await loadData();
      },
      child: ListView.builder(
        itemCount: data.length + 1,
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == data.length && !end && index > 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (index >= data.length) {
            return null;
          }

          return widget.itemBuilder(context, data[index], () {
            Navigator.pop(context, data[index]);
          });
        },
      ),
    );
  }
}
