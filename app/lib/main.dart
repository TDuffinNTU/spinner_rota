import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spinner_rota/screens/spinner_screen.dart';
import 'package:spinner_rota/storage/storage_providers.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 236, 122, 8),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/spinner': (context) => const SpinnerScreen(),
      },
    );
  }
}

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    ref.listen(appStateNotifierProvider, (prev, next) {
      if (next is AsyncData && next.value != null) {
        Navigator.of(context).pushNamed('/spinner');
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Welcome To the jungle!'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      body: Center(
        child: ref.watch(appStateNotifierProvider).when(
              data: (AppState data) => LoadCsvButton(),
              error: (Object error, StackTrace stackTrace) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadCsvButton(),
                  const SizedBox(height: 8),
                  Text(
                    'Something went wrong...',
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.error),
                  ),
                  Card.filled(
                    color: Theme.of(context).colorScheme.errorContainer,
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SelectableText(
                            error.toString(),
                            style: TextStyle(
                              fontFamily: 'Natural Mono',
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => CircularProgressIndicator(
                color: Theme.of(context).progressIndicatorTheme.color,
              ),
            ),
      ),
    );
  }
}

class LoadCsvButton extends ConsumerStatefulWidget {
  const LoadCsvButton({super.key});

  @override
  ConsumerState<LoadCsvButton> createState() => _LoadCsvButtonState();
}

class _LoadCsvButtonState extends ConsumerState<LoadCsvButton> {
  bool hasMetaRow = false;

  void _showMetaRowHelp() {
    (
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('About the Meta Row'),
          content: Text(
              'The meta row can be used for storing metadata about the spinner file. TBD'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton.tonalIcon(
          label: const Text('Open your CSV...'),
          onPressed: () =>
              ref.read(appStateNotifierProvider.notifier).loadData(hasMetaRow),
          icon: const Icon(
            Icons.file_upload_outlined,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Contains meta row',
            ),
            Checkbox(
              value: hasMetaRow,
              onChanged: (value) => setState(() {
                hasMetaRow = value!;
              }),
            ),
            TextButton(
              onPressed: _showMetaRowHelp,
              child: const Icon(Icons.question_mark),
            )
          ],
        ),
      ],
    );
  }
}
