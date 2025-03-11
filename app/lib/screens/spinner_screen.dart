import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:spinner_rota/storage/spinner_entry.dart';
import 'package:spinner_rota/storage/storage_providers.dart';

class SpinnerScreen extends ConsumerStatefulWidget {
  const SpinnerScreen({
    super.key,
  });

  @override
  ConsumerState<SpinnerScreen> createState() => _SpinnerScreenState();
}

class _SpinnerScreenState extends ConsumerState<SpinnerScreen> {
  StreamController<int> streamController = StreamController<int>.broadcast();
  final AudioPlayer audioPlayer = AudioPlayer();
  late ConfettiController confettiController;

  int currentSprintMeister = -1;

  int nextSprintMeister = -1;

  bool disableControls = false;

  bool randomMode = false;

  bool soundMuted = false;

  /// Picks the new meister. You need at least one present dev to do this!
  ///
  /// If random mode is activated, selects a random dev who is also not currently
  /// the sprint meister (can be used for fun stuff basically).
  int pickNextMeister(List<SpinnerEntry> allDevelopers) {
    int newMeister = currentSprintMeister;

    if (!allDevelopers.any((e) => e.isPresent)) {
      return -1;
    }

    if (randomMode) {
      List<SpinnerEntry> presentDevs = allDevelopers
          .where((e) =>
              e.isPresent && allDevelopers.indexOf(e) != currentSprintMeister)
          .toList();
      SpinnerEntry devSelected =
          presentDevs[Random().nextInt(presentDevs.length)];
      return allDevelopers.indexOf(devSelected);
    }

    newMeister++;
    while (newMeister != currentSprintMeister) {
      if (newMeister > allDevelopers.length - 1) {
        newMeister = 0;
      }
      if (allDevelopers[newMeister].isPresent) {
        return newMeister;
      }

      newMeister++;
    }

    return newMeister;
  }

  /// Activates the spinner as long as at least one dev is present.
  void onSpinnerActivated(List<SpinnerEntry> allDevelopers) {
    if (!allDevelopers.any((e) => e.isPresent)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Can\'t select a new meister'),
          content: const Text('At least one dev must be present!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        nextSprintMeister = pickNextMeister(allDevelopers);
        streamController.add(nextSprintMeister);
        disableControls = true;
      });
    }
  }

  @override
  void initState() {
    streamController = StreamController<int>.broadcast();
    confettiController =
        ConfettiController(duration: const Duration(seconds: 8));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(appStateNotifierProvider).when(
          data: (data) => Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(data.title),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    tooltip:
                        '${soundMuted ? 'Enable' : 'Disable'} sound effects',
                    onPressed: () => setState(() {
                      soundMuted = !soundMuted;
                      audioPlayer.setVolume(soundMuted ? 0 : 1);
                    }),
                    icon: Icon(soundMuted ? Icons.music_off : Icons.music_note),
                  ),
                )
              ],
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  ListView(
                    children: [
                      const SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          height: min(800, MediaQuery.of(context).size.width),
                          child: FortuneWheel(
                            animateFirst: false,
                            onAnimationStart: () {
                              audioPlayer.stop();
                              audioPlayer.play(AssetSource('wheel.mp3'));
                            },
                            onAnimationEnd: () {
                              confettiController.play();
                              audioPlayer.stop();
                              audioPlayer.play(AssetSource('applause.wav'));
                              setState(() {
                                currentSprintMeister = nextSprintMeister;
                                disableControls = false;
                              });
                            },
                            selected: streamController.stream,
                            items: List.generate(
                              data.entries.length,
                              (index) => FortuneItem(
                                child: Text(
                                  data.entries[index].nickName,
                                  style: TextStyle(
                                    fontSize: MediaQuery.textScalerOf(context)
                                        .scale(24),
                                    color: Color.fromARGB(
                                        !data.entries[index].isPresent
                                            ? 50
                                            : 255,
                                        255,
                                        255,
                                        255),
                                    decoration: !data.entries[index].isPresent
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                            ).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          height: 40,
                          child: IconButton.filled(
                            onPressed: disableControls
                                ? null
                                : () => onSpinnerActivated(data.entries),
                            icon: const Text(
                              'Spin to win!',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Divider(),
                      const SizedBox(height: 8.0),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Current Sprint-meister'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropdownButtonFormField<int>(
                          value: currentSprintMeister,
                          items: [
                            const DropdownMenuItem<int>(
                              value: -1,
                              child: Text('None'),
                            ),
                            ...List.generate(
                              data.entries.length,
                              (index) => DropdownMenuItem(
                                value: index,
                                child: Text(
                                  data.entries[index].nickName,
                                ),
                              ),
                            )
                          ],
                          onChanged: disableControls
                              ? null
                              : (value) => setState(() {
                                    currentSprintMeister = value ?? -1;
                                  }),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Divider(),
                      const SizedBox(height: 8.0),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Squad attendance'),
                      ),
                      ...List.generate(
                        data.entries.length,
                        (index) => CheckboxListTile(
                          title: Text(data.entries[index].nickName),
                          subtitle: Text(data.entries[index].name),
                          value: data.entries[index].isPresent,
                          onChanged: (value) => setState(() {
                            data.entries[index].isPresent = value ?? false;
                          }),
                          enabled: !disableControls,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Divider(),
                      const SizedBox(height: 8.0),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Bonus Settings'),
                      ),
                      ListTile(
                        title: const Text('Rrrrandom Moooode!'),
                        trailing: Switch(
                          value: randomMode,
                          onChanged: disableControls
                              ? null
                              : (value) => setState(() {
                                    randomMode = value;
                                  }),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: confettiController,
                      blastDirection: pi / 2,
                      maxBlastForce: 6,
                      minBlastForce: 3,
                      emissionFrequency: 0.03,
                      numberOfParticles: 10,
                      gravity: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          error: (e, stackTrace) => Scaffold(
            body: Center(
              child: Text('Error!\n $e'),
            ),
          ),
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
  }
}
