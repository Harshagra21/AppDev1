import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }

  var isMenuOpen = false;

  void toggleMenu() {
    isMenuOpen = !isMenuOpen;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    Widget page;

    if (appState.isMenuOpen) {
      page = Container(
        width: 200,
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              title: Text('Home'),
              onTap: () {
                setState(() {
                  selectedIndex = 0;
                  appState.toggleMenu();
                });
              },
            ),
            ListTile(
              title: Text('Favorites'),
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                  appState.toggleMenu();
                });
              },
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                setState(() {
                  selectedIndex = 2;
                  appState.toggleMenu();
                });
              },
            ),
          ],
        ),
      );
    } else {
      switch (selectedIndex) {
        case 0:
          page = GeneratorPage();
          break;
        case 1:
          page = FavoritesPage();
          break;
        case 2:
          page = ProfilePage();
          break;
        default:
          throw UnimplementedError('no widget for $selectedIndex');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Namer App'),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person),
                    label: Text('Profile'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          appState.toggleMenu(); // Toggle the menu state
        },
        child: Icon(appState.isMenuOpen ? Icons.close : Icons.menu),
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView.builder(
      itemCount: appState.favorites.length,
      itemBuilder: (context, index) {
        var pair = appState.favorites[index];
        return ListTile(
          leading: Icon(Icons.favorite),
          title: Text(pair.asLowerCase),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              appState.removeFavorite(pair);
            },
          ),
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder data for the profile
    var profileData = ProfileData(
      imageUrl:
          'https://pics.craiyon.com/2023-07-03/41ed16009b7842f9b1ab085853eba9f7.webp',
      name: 'Harsh Agrawal',
      email: 'harsha21@iitk.ac.in',
      city: 'Kanpur',
      rollNumber: '210405',
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(profileData.imageUrl),
          ),
          SizedBox(height: 16),
          Text('Name: ${profileData.name}'),
          Text('Email: ${profileData.email}'),
          Text('City: ${profileData.city}'),
          Text('Roll Number: ${profileData.rollNumber}'),
        ],
      ),
    );
  }
}

class ProfileData {
  final String imageUrl;
  final String name;
  final String email;
  final String city;
  final String rollNumber;

  ProfileData({
    required this.imageUrl,
    required this.name,
    required this.email,
    required this.city,
    required this.rollNumber,
});
}