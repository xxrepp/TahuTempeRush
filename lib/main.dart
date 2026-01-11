import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game/TahuTempeGame.dart';
import 'overlays/MainMenu.dart';
import 'overlays/GameUI.dart';
import 'overlays/ShopMenu.dart';
import 'overlays/GameOverMenu.dart';
import 'managers/CurrencyManager.dart';
import 'managers/AdManager.dart';
import 'managers/IAPManager.dart';
import 'managers/AudioManager.dart';
import 'managers/HapticManager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set portrait orientation only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Initialize all managers
  await CurrencyManager().init();
  await AdManager().init();
  await IAPManager().init();
  await AudioManager().init();
  await HapticManager().init();
  
  runApp(const TahuTempeRushApp());
}

class TahuTempeRushApp extends StatelessWidget {
  const TahuTempeRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TahuTempeRush',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final TahuTempeGame _game;
  Offset? _swipeStart;

  @override
  void initState() {
    super.initState();
    _game = TahuTempeGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapDown: _handleTap,
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        child: GameWidget(
          game: _game,
          initialActiveOverlays: const ['MainMenu'],
          overlayBuilderMap: {
            'MainMenu': (context, game) => MainMenu(game: _game),
            'GameUI': (context, game) => StreamBuilder<int>(
              stream: CurrencyManager().balanceStream,
              initialData: CurrencyManager().balance,
              builder: (context, snapshot) {
                return GameUI(
                  score: _game.score,
                  combo: _game.combo,
                  beans: snapshot.data ?? 0,
                );
              },
            ),
            'Shop': (context, game) => ShopMenu(game: _game),
            'GameOver': (context, game) => GameOverMenu(game: _game),
          },
        ),
      ),
    );
  }

  void _handleTap(TapDownDetails details) {
    if (_game.gameOver || !_game.overlays.isActive('GameUI')) return;
    
    // Single tap = single shot
    _game.player.shootSingle();
  }

  void _handlePanStart(DragStartDetails details) {
    _swipeStart = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_game.gameOver || !_game.overlays.isActive('GameUI')) return;
    if (_swipeStart == null) return;

    final delta = details.localPosition - _swipeStart!;
    
    // Detect upward swipe (dual shot)
    if (delta.dy < -30 && delta.dy.abs() > delta.dx.abs()) {
      _game.player.shootDual();
      _swipeStart = null; // Prevent multiple shots in one swipe
    }
  }
}
