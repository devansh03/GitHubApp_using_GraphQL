import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Widget buildError(BuildContext context, FlutterErrorDetails error) {
  return Scaffold(
    backgroundColor: Colors.redAccent.shade100,
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height / 4,),
              Image.asset("images/incorrect_username.jpg"),
              SizedBox(height: 30.0),
              Text("Please try a correct Username.",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
            ],
          ),
        ],
      ),
    ),
  );
}

void main() => runApp(MaterialApp(
      title: "GitHub_using_GraphQL",
      debugShowCheckedModeBanner: false,
      home: MyApp(),
      builder: (BuildContext context, Widget widget) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return buildError(context, errorDetails);
        };
        return widget;
      },
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  
  
  // Enter the Access Token you will get in the string.
  String personalAccessToken = "Place Your Access Token Here";

  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(uri: 'https://api.github.com/graphql',
        headers: {"authorization": "Bearer $personalAccessToken"});

    ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
        GraphQLClient(
            link: httpLink,
            cache:
                OptimisticCache(dataIdFromObject: typenameDataIdFromObject)));

    return GraphQLProvider(
      client: client,
      child: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController nameController = new TextEditingController();
  
  
  // In the String, enter your GitHub Username.
  String name = "Your Username";

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "GitHub",
            style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.black,
          centerTitle: false,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 175.0,
                color: Colors.tealAccent.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextField(
                    autocorrect: false,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        labelText: "Enter UserName",
                        border: OutlineInputBorder(
                            gapPadding: 3.3,
                            borderRadius: BorderRadius.circular(3.3))),
                    controller: nameController,
                  ),
                ),
              ),
            ),
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    name = nameController.text;
                    MyHomePage();
                  });
                })
          ],
        ),
        body: Query(
          options: QueryOptions(
            // ignore: deprecated_member_use
            document: """
    query Flutter_Github_GraphQL{
            user(login: "$name") {
                avatarUrl(size: 200)
                location
                name
                url
                email
                login
                repositories {
                  totalCount
                }
                followers {
                  totalCount
                }
                following {
                  totalCount
                }
              }
      viewer {
              starredRepositories(last: 100) {
                edges {
                  node {
                    id
                    name
                    nameWithOwner
                  }
                }
              }
            }
          }
      """,
            variables: {
              'name': name,
            },
          ),
          builder: (QueryResult result,
              {VoidCallback refetch, FetchMore fetchMore}) {
            if (result.hasException == null) {
              return Center(
                  child: Text(
                result.hasException.toString(),
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ));
            }

            if (result.loading) {
              return Center(child: CircularProgressIndicator());
            }

            final userDetails = result.data['user'];
            List starredRepositories =
                result.data['viewer']['starredRepositories']['edges'];

            return Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      color: Colors.black,
                      alignment: Alignment.center,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 2,
                          ),
                          ClipOval(
                            child: Image.network(
                              userDetails["avatarUrl"],
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.cover,
                              height: 100.0,
                              width: 100.0,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            userDetails['name'],
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            userDetails['login'],
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color: Colors.grey,
                                size: 16,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                userDetails['location'],
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.link,
                                color: Colors.grey,
                                size: 16,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                userDetails['url'],
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.email,
                                color: Colors.grey,
                                size: 16,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                userDetails['email'],
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(
                                      userDetails["repositories"]['totalCount']
                                          .toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Repositories",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey),
                                    )
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                      userDetails["followers"]['totalCount']
                                          .toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Followers",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey),
                                    )
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                      userDetails["following"]['totalCount']
                                          .toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Following",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10.0, bottom: 2, left: 10),
                      child: Text(
                        "Your Starred Repositories",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Divider(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 330.0),
                  child: ListView.builder(
                    itemCount: starredRepositories.length,
                    itemBuilder: (context, index) {
                      final repository = starredRepositories[index];
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 8, bottom: 8),
                          child: Card(
                            elevation: 0,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.collections_bookmark),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  repository['node']['nameWithOwner'],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
