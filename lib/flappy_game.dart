import 'dart:math';
import 'package:flame/events.dart'; 
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

void main() {
  runApp(GameWidget(game: FlappyGame()));
}

class FlappyGame extends FlameGame with TapCallbacks {
  // Variabel Aset
  Sprite? backgroundSprite;
  Sprite? pipeSprite;
  Sprite? birdSprite;

  // Variabel Burung/Roket
  double birdY = 300;
  double velocity = 0;
  final double gravity = 900;
  final double jumpforce = -350;

  // Variabel Pipa
  late double pipeX;
  double pipeGap = 220; 
  double pipeHeight = 200;

  // Status Game
  int score = 0;
  bool gameOver = false;

  @override
  Future<void> onLoad() async {
    pipeX = size.x;
    
    try {
      // Memuat semua gambar dari folder assets/images/
      backgroundSprite = await loadSprite('background.png');
      pipeSprite = await loadSprite('nazii.png');
      birdSprite = await loadSprite('rocket.png');
      print("Semua aset berhasil dimuat!");
    } catch (e) {
      print("Gagal memuat aset: $e. Pastikan file ada di assets/images/");
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (gameOver) return;

    // Logika Jatuh
    velocity += gravity * dt; 
    birdY += velocity * dt;
    
    // Gerakan Pipa
    pipeX -= 200 * dt;

    // Reset Pipa & Hitung Skor
    if (pipeX < -80) {
      pipeX = size.x;
      // Variasi tinggi pipa
      pipeHeight = Random().nextDouble() * (size.y - pipeGap - 150) + 75;
      score++;
    }

    // Cek Batas Atas/Bawah Layar
    if (birdY < 0 || birdY > size.y - 30) {
      triggerGameOver();
    }

    // Cek Tabrakan Pipa
    if (pipeX < 100 && pipeX + 80 > 40) {
      if (birdY < pipeHeight || birdY + 25 > pipeHeight + pipeGap) {
        triggerGameOver();
      }
    }
  }

  void triggerGameOver() {
    gameOver = true;
  }

  @override
  void render(Canvas canvas) {
    // 1. RENDER BACKGROUND
    if (backgroundSprite != null) {
      if (!gameOver) {
        backgroundSprite!.render(canvas, size: size);
      } else {
        // Efek Jumpscare Visual (Zoom + Red Filter)
        backgroundSprite!.render(
          canvas,
          position: Vector2(-size.x * 0.5, -size.y * 0.2), 
          size: size * 2.5, 
          overridePaint: Paint()
            ..colorFilter = const ColorFilter.mode(Colors.redAccent, BlendMode.modulate)
        );
      }
    }

    // 2. RENDER OBJEK (Hanya jika belum mati)
    if (!gameOver) {
      // Render Pipa
      if (pipeSprite != null) {
        double pipeWidth = 80;
        double logoHeight = 60;

        // Pipa Atas
        canvas.drawRect(Rect.fromLTWH(pipeX, 0, pipeWidth, pipeHeight), Paint()..color = Colors.red.withOpacity(0.8));
        pipeSprite!.render(canvas, position: Vector2(pipeX, pipeHeight - logoHeight), size: Vector2(pipeWidth, logoHeight));

        // Pipa Bawah
        canvas.drawRect(Rect.fromLTWH(pipeX, pipeHeight + pipeGap, pipeWidth, size.y), Paint()..color = Colors.red.withOpacity(0.8));
        pipeSprite!.render(canvas, position: Vector2(pipeX, pipeHeight + pipeGap), size: Vector2(pipeWidth, logoHeight));
      }

      // Render Roket
      if (birdSprite != null) {
        birdSprite!.render(
          canvas,
          position: Vector2(40, birdY),
          size: Vector2(60, 40),
        );
      }
      
      // Render Skor
      _drawText(canvas, 'Score: $score', 20, 50, fontSize: 28, color: Colors.white);
    } else {
      // Overlay saat Mati
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = Colors.black45);
      _drawText(canvas, "MATI KAU!", size.x / 2 - 100, size.y / 2 - 40, fontSize: 45, color: Colors.white);
      _drawText(canvas, "Tap to Restart", size.x / 2 - 80, size.y / 2 + 30, fontSize: 20, color: Colors.yellowAccent);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameOver) {
      restartGame();
    } else {
      velocity = jumpforce;
    }
  }

  void restartGame() {
    birdY = 300;
    velocity = 0;
    pipeX = size.x;
    score = 0;
    gameOver = false;
  }

  void _drawText(Canvas canvas, String text, double x, double y, {double fontSize = 24, Color color = Colors.white}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color, 
          fontSize: fontSize, 
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(blurRadius: 5, color: Colors.black, offset: Offset(2, 2))]
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(x, y));
  }
}