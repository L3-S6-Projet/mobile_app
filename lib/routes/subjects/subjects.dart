import 'package:flutter/material.dart';
import 'package:mobile_scolendar/components/app_drawer.dart';
import 'package:mobile_scolendar/routes/subjects/subject.dart';
import 'package:mobile_scolendar/routes/subjects/subject_create.dart';
import 'package:openapi/api.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:mobile_scolendar/utils.dart';

const PER_PAGE = 10;

class SubjectsRoute extends StatefulWidget {
  static const ROUTE_NAME = '/subjects';

  @override
  _SubjectsRouteState createState() => _SubjectsRouteState();
}

class _SubjectsRouteState extends State<SubjectsRoute> {
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
          final AccountCreatedResponse result =
              await Navigator.pushNamed(context, SubjectCreateRoute.ROUTE_NAME)
                  as AccountCreatedResponse;

          if (result == null) return;

          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Compte créé'),
                  content: Text(
                      'Veuillez transmettre les informations suivantes :\nNom d\'utilisateur : ${result.username}\nMot de passe : ${result.password}'),
                  actions: [
                    FlatButton(
                      child: Text('OK'),
                      textColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              });
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
  List<SubjectListResponseSubjects> data = [];
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
    //responseFuture = loadSubjects();
  }

  loadNextPage() async {
    if (isLoading || end) return;
    isLoading = true;
    page += 1;
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    var apiInstance = SubjectsApi();
    var currentPage = page;
    print('LOAD page=$currentPage, query=${widget.query}');

    final response =
        await apiInstance.subjectsGet(query: widget.query, page: currentPage);
    setState(() {
      isLoading = false;
      if (response.subjects.length < PER_PAGE) end = true;
      data.addAll(response.subjects);
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
        await loadSubjects();
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

          final subject = data[index];
          final name = subject.name.capitalize();

          return ListTile(
            title: Text(name),
            subtitle: Text(subject.className),
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                SubjectRoute.ROUTE_NAME,
                arguments: SubjectRouteParameters(subject.id, name),
              );

              if (result == null) return;

              if (result == SubjectRouteResult.DELETED) {
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Sujet supprimé')));
                this._refreshIndicatorKey.currentState.show();
              }
            },
          );
        },
      ),
    );
  }
}
