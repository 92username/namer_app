import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Função principal que inicia o aplicativo
void main() {
  runApp(MyApp());
}

// Widget principal do aplicativo
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Provedor de estado para o aplicativo
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor:
                  const Color.fromARGB(255, 255, 4, 4)), // Tema do aplicativo
        ),
        home: MyHomePage(), // Página inicial do aplicativo
      ),
    );
  }
}

// Classe que gerencia o estado do aplicativo
class MyAppState extends ChangeNotifier {
  // Par de palavras atual
  var current = WordPair.random();

  // Gera um novo par de palavras
  void getNext() {
    current = WordPair.random();
    notifyListeners(); // Notifica ouvintes sobre a mudança de estado
  }

  // Lista de favoritos
  var favorites = <WordPair>[];

  // Adiciona ou remove o par atual dos favoritos
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners(); // Notifica ouvintes sobre a mudança de estado
  }
}

// Página inicial do aplicativo
class MyHomePage extends StatefulWidget {
  var selectedIndex = 0; // Índice do destino selecionado

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (widget.selectedIndex) {
      case 0:
        page = GeneratorPage();

      case 1:
        page = FavoritesPage();

      default:
        throw UnimplementedError('no widget for ${widget.selectedIndex}');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
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
                ],
                selectedIndex: widget.selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    widget.selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page, // Página geradora de pares de palavras
              ),
            ),
          ],
        ),
      );
    });
  }
}

// Página que gera e exibe pares de palavras
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState =
        context.watch<MyAppState>(); // Observa o estado do aplicativo
    var pair = appState.current; // Par de palavras atual

    // Define o ícone com base nos favoritos
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
          BigCard(pair: pair), // Exibe o par de palavras em um cartão grande
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(); // Alterna o estado de favorito
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext(); // Gera um novo par de palavras
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

// pagina de favoritos
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

// Widget que exibe um par de palavras em um cartão grande
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Estilo de texto personalizado
    final style = theme.textTheme.displayMedium!.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onPrimary,
      fontSize: 35,
    );

    return Card(
      color: theme.colorScheme.primary, // Cor do cartão
      elevation: 10.0, // Aumenta a altura da sombra
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase, // Texto do par de palavras em minúsculas
          style: style, // Aplica o estilo de texto personalizado
          semanticsLabel:
              "${pair.first} ${pair.second}", // Rótulo semântico para acessibilidade
        ),
      ),
    );
  }
}
