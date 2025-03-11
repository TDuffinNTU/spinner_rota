import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spinner_rota/screens/spinner_screen.dart';
import 'package:spinner_rota/storage/storage_providers.dart';
import 'package:spinner_rota/storage/theme_providers.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode:
          ref.watch(getDarkmodeProvider) ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData(
          colorSchemeSeed: ref.watch(getThemeColorProvider),
          brightness: Brightness.dark),
      color: ref.watch(getThemeColorProvider),
      theme: ThemeData(colorSchemeSeed: ref.watch(getThemeColorProvider)),
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
        title: const Text('Welcome To Spinner_Rota!'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ref.read(toggleDarkmodeProvider),
            icon: Icon(
              ref.read(getDarkmodeProvider) ? Icons.mode_night : Icons.sunny,
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: PopupMenuButton(
                tooltip: 'Set the app color',
                icon: const Icon(Icons.brush),
                constraints: BoxConstraints.loose(Size.infinite),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ColorPicker(
                      paletteType: PaletteType.hslWithSaturation,
                      pickerColor: ref.read(getThemeColorProvider),
                      portraitOnly: true,
                      enableAlpha: false,
                      labelTypes: const [],
                      onColorChanged: (color) => ref.read(
                        setThemeColorProvider(newCol: color),
                      ),
                    ),
                  )
                ],
              ))
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      body: Center(
        child: ref.watch(appStateNotifierProvider).when(
              data: (AppState data) => const LoadCsvButton(),
              error: (Object error, StackTrace stackTrace) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LoadCsvButton(),
                  const SizedBox(height: 8.0),
                  Card.filled(
                    color: Theme.of(context).colorScheme.errorContainer,
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Something went wrong...',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                          ),
                          const SizedBox(height: 8),
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
        builder: (context) => AlertDialog(
          title: const Text('About the Meta Row'),
          content: Column(
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'The meta row can be used for storing metadata about '
                          'the CSV file. Instead of the usual format:\n\n',
                    ),
                    TextSpan(
                      text: '"Name,Nickname,isPresent"',
                      style: TextStyle(
                        fontFamily: 'Natural Mono',
                        backgroundColor:
                            Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                    const TextSpan(
                      text: '\n\nThe first line may instead use:\n\n',
                    ),
                    TextSpan(
                      text: '"Title,CurrentMeister,ThemeColour"',
                      style: TextStyle(
                        fontFamily: 'Natural Mono',
                        backgroundColor:
                            Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                    const TextSpan(
                      text: '\n\nwhich will be applied to the next screen.\n\n',
                    ),
                  ],
                ),
              ),
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'WARNING: This meta row schema may change in the future!',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
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
          icon: const Icon(Icons.file_upload_outlined),
        ),
        const SizedBox(height: 8.0),
        FilledButton.tonalIcon(
          label: const Text('(Coming soon!) Save an example CSV...'),
          onPressed: null,
          icon: const Icon(Icons.save),
        ),
        const SizedBox(height: 8.0),
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
            const SizedBox(width: 8.0),
            IconButton.filledTonal(
              onPressed: _showMetaRowHelp,
              icon: const Icon(Icons.question_mark),
            )
          ],
        ),
      ],
    );
  }
}
