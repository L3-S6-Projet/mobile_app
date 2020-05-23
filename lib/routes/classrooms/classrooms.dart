import 'package:flutter/material.dart';
import 'package:mobile_scolendar/components/app_drawer.dart';
import 'package:mobile_scolendar/routes/classrooms/classroom.dart';
import 'package:mobile_scolendar/routes/classrooms/classroom_create.dart';
import 'package:openapi/api.dart';
import 'package:mobile_scolendar/api_exception.dart';

const PER_PAGE = 10;

class ClassroomsRoute extends StatefulWidget {
  static const ROUTE_NAME = '/classrooms';

  @override
  _ClassroomsRouteState createState() => _ClassroomsRouteState();
}

class _ClassroomsRouteState extends State<ClassroomsRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Scolendar'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchDelegate());
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final SimpleSuccessResponse result = await Navigator.pushNamed(
                  context, ClassroomCreateRoute.ROUTE_NAME)
              as SimpleSuccessResponse;

          if (result == null) return;

          // TODO : not working, use a key
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: const Text('Compte créé')));
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: Results(query: null),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
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
    return Results(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (!shouldSearch)
      return Center(
        child: Text('Start typing to search'),
      );

    return Container();
  }
}

class Results extends StatefulWidget {
  final String query;

  const Results({Key key, @required this.query}) : super(key: key);

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
  List<Classroom> data = [];
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
    //responseFuture = loadClassrooms();
  }

  loadNextPage() async {
    if (isLoading || end) return;
    isLoading = true;
    page += 1;
    loadClassrooms();
  }

  Future<void> loadClassrooms() async {
    var apiInstance = ClassroomApi();
    var currentPage = page;
    print('LOAD page=$currentPage, query=${widget.query}');

    final response =
        await apiInstance.classroomsGet(query: widget.query, page: currentPage);
    setState(() {
      isLoading = false;
      if (response.classrooms.length < PER_PAGE) end = true;
      data.addAll(response.classrooms);
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
    // TODO : set refresh indicator on initial load
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () async {
        data.clear();
        page = 1;
        end = false;
        await loadClassrooms();
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

          final classroom = data[index];
          final name = classroom.name;

          return ListTile(
            title: Text(name),
            subtitle: Text('${classroom.capacity} places'),
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                ClassroomRoute.ROUTE_NAME,
                arguments: ClassroomRouteParameters(classroom.id, name),
              );

              if (result == null) return;

              if (result == ClassroomRouteResult.DELETED) {
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Classe supprimé'))); // TODO : not working (invalid context reference), use a key
                this._refreshIndicatorKey.currentState.show();
              }
            },
          );
        },
      ),
    );
  }
}
